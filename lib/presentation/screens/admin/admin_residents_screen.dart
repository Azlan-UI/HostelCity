import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/resident_model.dart';
import '../../providers/admin_providers.dart';
import '../../providers/auth_providers.dart';
import '../../providers/hostel_providers.dart';
import '../../widgets/common/empty_state_widget.dart';

class AdminResidentsScreen extends ConsumerStatefulWidget {
  final String? initialHostelId;
  const AdminResidentsScreen({super.key, this.initialHostelId});

  @override
  ConsumerState<AdminResidentsScreen> createState() => _AdminResidentsScreenState();
}

class _AdminResidentsScreenState extends ConsumerState<AdminResidentsScreen> {
  String? _selectedHostelId;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedHostelId = widget.initialHostelId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Residents Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 88),
        child: Column(
          children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          if (_selectedHostelId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.filter_alt, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Filter: Specific hostel',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedHostelId = null);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                final hostelRepository = ref.watch(hostelRepositoryProvider);

                return FutureBuilder(
                  future: hostelRepository.getHostelsByAdmin(user.uid).first,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const EmptyStateWidget(
                        icon: Icons.home_work,
                        title: 'No Hostels',
                        message: 'You need to create a hostel first.',
                      );
                    }

                    final hostels = snapshot.data!;
                    return _buildResidentsList(hostels);
                  },
                );
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildResidentsList(List hostels) {
    // Collect residents from all hostels or selected hostel
    final List<Widget> residentWidgets = [];
    final hostelsToShow = _selectedHostelId != null
        ? hostels.where((h) => h.hostelId == _selectedHostelId).toList()
        : hostels;

    if (hostelsToShow.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.people,
        title: 'No Residents',
        message: 'No residents found.',
      );
    }

    for (final hostel in hostelsToShow) {
      final residentsAsync = ref.watch(residentsByHostelProvider(hostel.hostelId));

      residentsAsync.when(
        data: (residents) {
          // Apply search filter
          var filteredResidents = residents;
          if (_searchQuery.isNotEmpty) {
            filteredResidents = residents.where((r) {
              final name = r.userName?.toLowerCase() ?? '';
              return name.contains(_searchQuery);
            }).toList();
          }

          if (filteredResidents.isNotEmpty) {
            residentWidgets.add(
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hostel.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...filteredResidents.asMap().entries.map((entry) {
                      return FadeInUp(
                        delay: Duration(milliseconds: entry.key * 50),
                        child: _ResidentCard(
                          resident: entry.value,
                          hostelName: hostel.name,
                          onTap: () => _showResidentDetails(context, entry.value, hostel.name),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }
        },
        loading: () {},
        error: (e, s) {},
      );
    }

    if (residentWidgets.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'No Residents Found',
        message: 'No residents match your search criteria.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(residentsByHostelProvider);
      },
      child: ListView(
        children: residentWidgets,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final userAsync = ref.read(currentUserProvider);
    userAsync.whenData((user) {
      if (user == null) return;

      final hostelRepository = ref.read(hostelRepositoryProvider);

      hostelRepository.getHostelsByAdmin(user.userId).first.then((hostels) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Filter by Hostel'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String?>(
                  title: const Text('All Hostels'),
                  value: null,
                  groupValue: _selectedHostelId,
                  onChanged: (value) {
                    setState(() => _selectedHostelId = value);
                    Navigator.pop(context);
                  },
                ),
                ...hostels.map((hostel) => RadioListTile<String?>(
                      title: Text(hostel.name),
                      value: hostel.hostelId,
                      groupValue: _selectedHostelId,
                      onChanged: (value) {
                        setState(() => _selectedHostelId = value);
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      });
    });
  }

  void _showResidentDetails(BuildContext context, ResidentModel resident, String hostelName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ResidentDetailSheet(
        resident: resident,
        hostelName: hostelName,
      ),
    );
  }
}

class _ResidentCard extends StatelessWidget {
  final ResidentModel resident;
  final String hostelName;
  final VoidCallback onTap;

  const _ResidentCard({
    required this.resident,
    required this.hostelName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = resident.userName ?? 'Unknown';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  displayName.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            resident.userEmail ?? 'No email',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResidentDetailSheet extends ConsumerStatefulWidget {
  final ResidentModel resident;
  final String hostelName;

  const _ResidentDetailSheet({
    required this.resident,
    required this.hostelName,
  });

  @override
  ConsumerState<_ResidentDetailSheet> createState() => _ResidentDetailSheetState();
}

class _ResidentDetailSheetState extends ConsumerState<_ResidentDetailSheet> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final displayName = widget.resident.userName ?? 'Unknown';
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          displayName.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInfoSection('Hostel', widget.hostelName, Icons.home_work),
                    const SizedBox(height: 16),
                    _buildInfoSection('Room ID', widget.resident.roomId, Icons.door_front_door),
                    if (widget.resident.userEmail != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoSection('Email', widget.resident.userEmail!, Icons.email),
                    ],
                    if (widget.resident.userPhone != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoSection('Phone', widget.resident.userPhone!, Icons.phone),
                    ],
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      'Move-in Date',
                      DateFormatter.formatDate(widget.resident.moveInDate),
                      Icons.calendar_today,
                    ),
                    const SizedBox(height: 24),
                    // Contact actions
                    Row(
                      children: [
                        if (widget.resident.userPhone != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final uri = Uri(scheme: 'tel', path: widget.resident.userPhone!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text('Call'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        if (widget.resident.userPhone != null && widget.resident.userEmail != null)
                          const SizedBox(width: 12),
                        if (widget.resident.userEmail != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final uri = Uri(scheme: 'mailto', path: widget.resident.userEmail!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              icon: const Icon(Icons.email, size: 18),
                              label: const Text('Email'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (widget.resident.isActive) ...[
                      OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _markAsMovedOut,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.exit_to_app),
                        label: const Text('Mark as Moved Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.border.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This resident has moved out',
                                style: GoogleFonts.inter(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _markAsMovedOut() async {
    final displayName = widget.resident.userName ?? 'this resident';
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Move-out'),
        content: Text('Are you sure you want to mark $displayName as moved out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      final repository = ref.read(residentRepositoryProvider);
      await repository.markResidentMovedOut(widget.resident.residentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resident marked as moved out')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/complaint_model.dart';
import '../../../domain/enums/complaint_status.dart';
import '../../providers/admin_providers.dart';
import '../../providers/auth_providers.dart';
import '../../providers/hostel_providers.dart';
import '../../widgets/common/empty_state_widget.dart';

class AdminComplaintsScreen extends ConsumerStatefulWidget {
  final String? initialHostelId;
  const AdminComplaintsScreen({super.key, this.initialHostelId});

  @override
  ConsumerState<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends ConsumerState<AdminComplaintsScreen> {
  String? _selectedHostelId;
  ComplaintStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedHostelId = widget.initialHostelId;
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
        title: const Text('Complaints Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 88),
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
                return _buildComplaintsList(hostels);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildComplaintsList(List hostels) {
    // For now, show complaints from the first hostel or selected hostel
    final hostelId = _selectedHostelId ?? hostels.first.hostelId;
    
    final complaintsAsync = _selectedStatus != null
        ? ref.watch(complaintsByStatusProvider((hostelId, _selectedStatus!)))
        : ref.watch(complaintsByHostelProvider(hostelId));

    return Column(
      children: [
        if (_selectedHostelId != null || _selectedStatus != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(Icons.filter_alt, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Filters active: ${_selectedHostelId != null ? "Hostel" : ""} ${_selectedStatus != null ? _selectedStatus!.name : ""}',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedHostelId = null;
                      _selectedStatus = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        Expanded(
          child: complaintsAsync.when(
            data: (complaints) {
              if (complaints.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.check_circle_outline,
                  title: 'No Complaints',
                  message: 'There are no complaints matching your filters.',
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(complaintsByHostelProvider);
                  ref.invalidate(complaintsByStatusProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 50),
                      child: _ComplaintCard(
                        complaint: complaint,
                        onTap: () => _showComplaintDetails(context, complaint),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),

          ),
        ),
      ],
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
            title: const Text('Filter Complaints'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hostel', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButton<String?>(
                  value: _selectedHostelId,
                  isExpanded: true,
                  hint: const Text('All Hostels'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Hostels')),
                    ...hostels.map((hostel) => DropdownMenuItem(
                          value: hostel.hostelId,
                          child: Text(hostel.name),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedHostelId = value);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButton<ComplaintStatus?>(
                  value: _selectedStatus,
                  isExpanded: true,
                  hint: const Text('All Statuses'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Statuses')),
                    ...ComplaintStatus.values.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.name.toUpperCase()),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      });
    });
  }

  void _showComplaintDetails(BuildContext context, ComplaintModel complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ComplaintDetailSheet(complaint: complaint),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback onTap;

  const _ComplaintCard({
    required this.complaint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(complaint.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: statusColor, width: 4),
          top: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      complaint.description,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      complaint.status.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                complaint.description,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatDate(complaint.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    complaint.category,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.open:
        return AppColors.warning;
      case ComplaintStatus.inProgress:
        return AppColors.info;
      case ComplaintStatus.resolved:
        return AppColors.success;
      case ComplaintStatus.closed:
        return AppColors.textTertiary;
    }
  }
}

class _ComplaintDetailSheet extends ConsumerStatefulWidget {
  final ComplaintModel complaint;

  const _ComplaintDetailSheet({required this.complaint});

  @override
  ConsumerState<_ComplaintDetailSheet> createState() => _ComplaintDetailSheetState();
}

class _ComplaintDetailSheetState extends ConsumerState<_ComplaintDetailSheet> {
  late ComplaintStatus _currentStatus;
  final _notesController = TextEditingController();
  final _timeframeController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.complaint.status;
    _notesController.text = widget.complaint.adminNotes ?? '';
    _timeframeController.text = widget.complaint.estimatedResolutionTime ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _timeframeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.complaint.category,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          _getStatusIcon(_currentStatus),
                          color: _getStatusColor(_currentStatus),
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      'Description',
                      widget.complaint.description,
                      Icons.description,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      'Category',
                      widget.complaint.category,
                      Icons.category,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      'Submitted',
                      DateFormatter.formatDateTime(widget.complaint.createdAt),
                      Icons.calendar_today,
                    ),
                    // Student Info
                    if (widget.complaint.studentName != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        'Reported By',
                        widget.complaint.studentName!,
                        Icons.person,
                      ),
                    ],
                    if (widget.complaint.priority != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        'Priority',
                        widget.complaint.priority!,
                        Icons.flag,
                      ),
                    ],
                    if (widget.complaint.resolvedAt != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        'Resolved',
                        DateFormatter.formatDateTime(widget.complaint.resolvedAt!),
                        Icons.check_circle,
                      ),
                    ],

                    // Attached Photos
                    if (widget.complaint.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text('Attached Photos',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.complaint.imageUrls.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.complaint.imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.surfaceAlt,
                                    child: const Icon(Icons.broken_image, color: AppColors.textTertiary),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Update Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<ComplaintStatus>(
                      segments: ComplaintStatus.values.map((status) {
                        return ButtonSegment(
                          value: status,
                          label: Text(status.name.toUpperCase()),
                          icon: Icon(_getStatusIcon(status)),
                        );
                      }).toList(),
                      selected: {_currentStatus},
                      onSelectionChanged: (Set<ComplaintStatus> selected) {
                        setState(() {
                          _currentStatus = selected.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Resolution Timeframe
                    Text(
                      'Resolution Timeframe',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tell the student when this will be fixed. They will be notified.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _timeframeController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Within 24 hours, 2-3 days, By Friday...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timer),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Admin Notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Add notes for this complaint...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isUpdating ? null : _updateComplaint,
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Complaint'),
                    ),
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
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _updateComplaint() async {
    setState(() => _isUpdating = true);

    try {
      final repository = ref.read(complaintRepositoryProvider);
      final notes = _notesController.text.trim();
      final timeframe = _timeframeController.text.trim();

      // If timeframe is set, use the dedicated method
      if (timeframe.isNotEmpty) {
        await repository.setResolutionTimeframe(
          widget.complaint.complaintId,
          estimatedTime: timeframe,
          adminNotes: notes.isEmpty ? null : notes,
        );
      }

      // Always update status
      await repository.updateComplaintStatus(
        widget.complaint.complaintId,
        _currentStatus,
        adminNotes: notes.isEmpty ? null : notes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(timeframe.isNotEmpty
                ? 'Complaint updated — student will be notified of $timeframe ETA'
                : 'Complaint updated successfully'),
            backgroundColor: AppColors.success,
          ),
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
        setState(() => _isUpdating = false);
      }
    }
  }

  IconData _getStatusIcon(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.open:
        return Icons.report_problem;
      case ComplaintStatus.inProgress:
        return Icons.hourglass_empty;
      case ComplaintStatus.resolved:
        return Icons.check_circle;
      case ComplaintStatus.closed:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.open:
        return AppColors.warning;
      case ComplaintStatus.inProgress:
        return AppColors.info;
      case ComplaintStatus.resolved:
        return AppColors.success;
      case ComplaintStatus.closed:
        return AppColors.textTertiary;
    }
  }
}

// Provider for complaints by status
final complaintsByStatusProvider = StreamProvider.family<List<ComplaintModel>, (String, ComplaintStatus)>((ref, params) {
  final (hostelId, status) = params;
  return ref.watch(complaintRepositoryProvider).getComplaintsByStatus(hostelId, status);
});
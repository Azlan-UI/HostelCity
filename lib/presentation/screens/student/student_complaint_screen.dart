import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/complaint_model.dart';
import '../../../domain/enums/complaint_status.dart';
import '../../providers/auth_providers.dart';
import '../../providers/student_providers.dart';
import '../../providers/admin_providers.dart';
import '../../providers/hostel_providers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/auth_gate.dart';
import '../../../services/storage_service.dart';

class StudentComplaintScreen extends ConsumerStatefulWidget {
  /// Optional — if provided, the form pre-selects this hostel.
  /// If null, the screen auto-detects from the current resident profile.
  final String? hostelId;
  final String? hostelName;

  const StudentComplaintScreen({
    super.key,
    this.hostelId,
    this.hostelName,
  });

  @override
  ConsumerState<StudentComplaintScreen> createState() => _StudentComplaintScreenState();
}

class _StudentComplaintScreenState extends ConsumerState<StudentComplaintScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Maintenance';
  String _selectedPriority = 'Normal';
  bool _isSubmitting = false;

  // Image attachments
  final List<XFile> _attachedImages = [];
  final _imagePicker = ImagePicker();

  final List<String> _categories = [
    'Maintenance',
    'Cleanliness',
    'Food Quality',
    'Noise',
    'Security',
    'Internet/Wi-Fi',
    'Plumbing',
    'Electrical',
    'Other',
  ];

  final List<String> _priorities = ['Low', 'Normal', 'High', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Returns the hostelId — from args or from the current resident profile.
  String? _getHostelId() {
    if (widget.hostelId != null) return widget.hostelId;
    final resident = ref.read(currentResidentDisplayProvider);
    return resident?.hostelId;
  }

  /// Returns the hostelName — from args or from the hostel provider.
  String _getHostelName() {
    if (widget.hostelName != null) return widget.hostelName!;
    final resident = ref.read(currentResidentDisplayProvider);
    if (resident == null) return 'Your Hostel';
    final hostelAsync = ref.read(hostelByIdProvider(resident.hostelId));
    return hostelAsync.whenOrNull(data: (h) => h?.name) ?? 'Your Hostel';
  }

  Future<void> _pickImage() async {
    if (_attachedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _attachedImages.add(image));
    }
  }

  Future<void> _takePhoto() async {
    if (_attachedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _attachedImages.add(image));
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    final hostelId = _getHostelId();
    if (hostelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active stay found. Book a hostel first.')),
      );
      return;
    }

    final residentAsync = ref.read(currentResidentProvider);
    final resident = residentAsync.value;

    if (resident == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: resident profile not found.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider).value!;

      // Upload images if any
      List<String> imageUrls = [];
      if (_attachedImages.isNotEmpty) {
        final storageService = StorageService();
        for (int i = 0; i < _attachedImages.length; i++) {
          final url = await storageService.uploadComplaintImage(
            user.userId,
            _attachedImages[i],
          );
          imageUrls.add(url);
        }
      }

      final newComplaint = ComplaintModel(
        complaintId: '',
        residentId: resident.residentId,
        userId: user.userId,
        hostelId: hostelId,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        imageUrls: imageUrls,
        status: ComplaintStatus.open,
        priority: _selectedPriority,
        createdAt: DateTime.now(),
        studentName: user.name,
      );

      final repository = ref.read(complaintRepositoryProvider);
      await repository.createComplaint(newComplaint);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Complaint submitted successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Switch to history tab and clear form
        _descriptionController.clear();
        setState(() => _attachedImages.clear());
        _tabController.animateTo(0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting complaint: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: 'My Complaints'),
            Tab(icon: Icon(Icons.add_circle_outline), text: 'New Complaint'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildComplaintHistory(),
          _buildNewComplaintForm(),
        ],
      ),
    );
  }

  // ── Tab 1: Complaint History ──────────────────────────────────────────────

  Widget _buildComplaintHistory() {
    final complaintsAsync = ref.watch(studentComplaintsProvider);

    return complaintsAsync.when(
      data: (complaints) {
        if (complaints.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.check_circle_outline,
            title: 'No Complaints',
            message: 'You haven\'t filed any complaints yet.\nTap "New Complaint" to report an issue.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(studentComplaintsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index] as ComplaintModel;
              return FadeInUp(
                delay: Duration(milliseconds: index * 60),
                child: _buildComplaintHistoryCard(complaint),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _showComplaintDetails(BuildContext context, ComplaintModel complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ComplaintDetailSheet(complaint: complaint),
    );
  }

  Widget _buildComplaintHistoryCard(ComplaintModel complaint) {
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
        onTap: () => _showComplaintDetails(context, complaint),
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
                      complaint.category,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
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
              if (complaint.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.image_outlined, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${complaint.imageUrls.length} photo(s) attached',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Footer: Date + Resolution ETA
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatDate(complaint.createdAt),
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary),
                  ),
                  if (complaint.estimatedResolutionTime != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, size: 14, color: AppColors.info),
                    const SizedBox(width: 4),
                    Text(
                      'ETA: ${complaint.estimatedResolutionTime}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),

              // Admin response notification
              if (complaint.adminNotes != null && complaint.adminNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.support_agent, size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          complaint.adminNotes!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showComplaintDetail(ComplaintModel complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final statusColor = _getStatusColor(complaint.status);
          return Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category + Status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        complaint.category,
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        complaint.status.displayName,
                        style: GoogleFonts.inter(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                Text('Description', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textTertiary)),
                const SizedBox(height: 6),
                Text(complaint.description, style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: 20),

                // Date
                _buildDetailRow(Icons.calendar_today, 'Submitted', DateFormatter.formatDateTime(complaint.createdAt)),
                
                if (complaint.priority != null)
                  _buildDetailRow(Icons.flag, 'Priority', complaint.priority!),

                // Resolution Timeframe
                if (complaint.estimatedResolutionTime != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.info.withValues(alpha: 0.1), AppColors.accent.withValues(alpha: 0.05)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timer, color: AppColors.info, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Expected Resolution',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.info),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          complaint.estimatedResolutionTime!,
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],

                // Admin Notes
                if (complaint.adminNotes != null && complaint.adminNotes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.support_agent, color: AppColors.accent, size: 20),
                            const SizedBox(width: 8),
                            Text('Admin Response', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.accent)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(complaint.adminNotes!, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],

                // Resolved date
                if (complaint.resolvedAt != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.check_circle, 'Resolved', DateFormatter.formatDateTime(complaint.resolvedAt!)),
                ],

                // Attached images
                if (complaint.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Attached Photos', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textTertiary)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: complaint.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              complaint.imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surfaceAlt,
                                child: Icon(Icons.broken_image, color: AppColors.textTertiary),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Text('$label: ', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  // ── Tab 2: New Complaint Form ─────────────────────────────────────────────

  Widget _buildNewComplaintForm() {
    final hostelId = _getHostelId();
    final hostelName = _getHostelName();

    if (hostelId == null) {
      return const EmptyStateWidget(
        icon: Icons.home_work_outlined,
        title: 'No Active Stay',
        message: 'You need an active hostel stay to raise a complaint.\nBook a hostel first.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hostel identifier
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.home_work, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reporting issue for:',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            hostelName,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedCategory = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Priority
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Priority', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: _priorities.map((priority) {
                      return DropdownMenuItem(value: priority, child: Text(priority));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedPriority = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: CustomTextField(
                label: 'Description',
                hint: 'Describe the issue in detail — include location, what happened, when it started...',
                controller: _descriptionController,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a description';
                  }
                  if (value.length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),

            // Image Attachments
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.photo_camera, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Attach Photos', style: Theme.of(context).textTheme.labelLarge),
                      const Spacer(),
                      Text(
                        '${_attachedImages.length}/5',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add photos to help us understand the issue better',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),

                  // Attached images preview
                  if (_attachedImages.isNotEmpty)
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _attachedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.success),
                              color: AppColors.success.withValues(alpha: 0.1),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image, color: AppColors.success, size: 28),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Photo ${index + 1}',
                                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.success),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _attachedImages.removeAt(index)),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 14, color: AppColors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Add image buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library, size: 18),
                          label: const Text('Gallery'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Camera'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: CustomButton(
                text: 'Submit Complaint',
                onPressed: _submitComplaint,
                isLoading: _isSubmitting,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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
}

class _ComplaintDetailSheet extends StatelessWidget {
  final ComplaintModel complaint;

  const _ComplaintDetailSheet({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    Text(
                      complaint.category,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoSection('Description', complaint.description, Icons.description),
                    const SizedBox(height: 16),
                    _buildInfoSection('Status', complaint.status.name.toUpperCase(), Icons.info_outline),
                    const SizedBox(height: 16),
                    _buildInfoSection('Submitted', DateFormatter.formatDateTime(complaint.createdAt), Icons.calendar_today),
                    
                    if (complaint.adminNotes != null && complaint.adminNotes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildInfoSection('Admin Notes', complaint.adminNotes!, Icons.comment),
                    ],

                    if (complaint.estimatedResolutionTime != null && complaint.estimatedResolutionTime!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildInfoSection('Estimated Resolution', complaint.estimatedResolutionTime!, Icons.timer),
                    ],

                    if (complaint.resolvedAt != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoSection('Resolved', DateFormatter.formatDateTime(complaint.resolvedAt!), Icons.check_circle),
                    ],

                    if (complaint.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Attached Photos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: complaint.imageUrls.length,
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
                                  complaint.imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: AppColors.textTertiary),
                                ),
                              ),
                            );
                          },
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

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
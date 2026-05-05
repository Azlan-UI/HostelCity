import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/notice_model.dart';
import '../../../domain/enums/target_group.dart';
import '../../providers/admin_providers.dart';
import '../../providers/auth_providers.dart';
import '../../providers/hostel_providers.dart';
import '../../widgets/common/custom_button.dart';


class AdminPostNoticeScreen extends ConsumerStatefulWidget {
  const AdminPostNoticeScreen({super.key});

  @override
  ConsumerState<AdminPostNoticeScreen> createState() => _AdminPostNoticeScreenState();
}

class _AdminPostNoticeScreenState extends ConsumerState<AdminPostNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  
  String? _selectedHostelId;
  TargetGroup _selectedTargetGroup = TargetGroup.all;
  bool _isPosting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Notice'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please login'));
          }

          final hostelRepository = ref.watch(hostelRepositoryProvider);

          return FutureBuilder(
            future: hostelRepository.getHostelsByAdmin(user.userId).first,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final hostels = snapshot.hasData ? snapshot.data! : [];
              if (hostels.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        size: 80,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Hostels',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('You need to create a hostel first.'),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Important Announcements',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create and send notices to residents of your hostels',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Hostel Selection
                      Text(
                        'Select Hostel',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedHostelId,
                        decoration: InputDecoration(
                          hintText: 'Choose a hostel',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.home_work),
                        ),
                        items: hostels.map((hostel) {
                          return DropdownMenuItem<String>(
                            value: hostel.hostelId,
                            child: Text(hostel.name),
                          );
                        }).toList().cast<DropdownMenuItem<String>>(),
                        onChanged: (value) {
                          setState(() => _selectedHostelId = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a hostel';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Target Group Selection
                      Text(
                        'Target Audience',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TargetGroup>(
                        value: _selectedTargetGroup,
                        decoration: InputDecoration(
                          hintText: 'Who should see this notice?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.people),
                        ),
                        items: TargetGroup.values.map((group) {
                          return DropdownMenuItem(
                            value: group,
                            child: Text(_getTargetGroupLabel(group)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedTargetGroup = value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Title Field
                      Text(
                        'Notice Title',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Maintenance Notice',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          if (value.trim().length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Message Field
                      Text(
                        'Message',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Write your announcement here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 80),
                            child: Icon(Icons.message),
                          ),
                        ),
                        maxLines: 6,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a message';
                          }
                          if (value.trim().length < 10) {
                            return 'Message must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Preview Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.preview, size: 20, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Preview',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _titleController.text.isEmpty ? 'Notice Title' : _titleController.text,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _messageController.text.isEmpty
                                  ? 'Your message will appear here...'
                                  : _messageController.text,
                              style: GoogleFonts.inter(
                                color: _messageController.text.isEmpty
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.people, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  _getTargetGroupLabel(_selectedTargetGroup),
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Post Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isPosting ? null : _postNotice,
                          icon: _isPosting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(_isPosting ? 'Posting...' : 'Post Notice'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _getTargetGroupLabel(TargetGroup group) {
    switch (group) {
      case TargetGroup.all:
        return 'All Residents';
      case TargetGroup.floor:
        return 'Specific Floor';
      case TargetGroup.room:
        return 'Specific Room';
    }
  }

  Future<void> _postNotice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isPosting = true);

    try {
      final repository = ref.read(noticeRepositoryProvider);
      
      final notice = NoticeModel(
        noticeId: '',
        hostelId: _selectedHostelId!,
        title: _titleController.text.trim(),
        content: _messageController.text.trim(),
        createdBy: '', // Will be set by repository
        targetGroup: _selectedTargetGroup,
        createdAt: DateTime.now(),
      );

      await repository.createNotice(notice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notice posted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Clear form
        _titleController.clear();
        _messageController.clear();
        setState(() {
          _selectedHostelId = null;
          _selectedTargetGroup = TargetGroup.all;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting notice: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }
}
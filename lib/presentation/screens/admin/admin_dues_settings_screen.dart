import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/hostel_providers.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';


class AdminDuesSettingsScreen extends ConsumerStatefulWidget {
  final String hostelId;

  const AdminDuesSettingsScreen({super.key, required this.hostelId});

  @override
  ConsumerState<AdminDuesSettingsScreen> createState() => _AdminDuesSettingsScreenState();
}

class _AdminDuesSettingsScreenState extends ConsumerState<AdminDuesSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _securityFeeController = TextEditingController();
  final _deadlineDaysController = TextEditingController();
  final _dailyFineController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _securityFeeController.dispose();
    _deadlineDaysController.dispose();
    _dailyFineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostelAsync = ref.watch(hostelByIdProvider(widget.hostelId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dues & Fee Settings'),
      ),
      body: hostelAsync.when(
        data: (hostel) {
          if (hostel == null) {
            return const Center(child: Text('Hostel not found'));
          }

          // Initialize controllers with current values
          if (!_isLoading) {
            _securityFeeController.text = hostel.securityFee.toStringAsFixed(0);
            _deadlineDaysController.text = hostel.rentDeadlineDays.toString();
            _dailyFineController.text = hostel.dailyFineAmount.toStringAsFixed(0);
            _isLoading = true;
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      hostel.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure fees, deadlines, and fines for this hostel',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 32),

                    // Security Fee Card
                    _buildSectionCard(
                      context,
                      icon: Icons.security,
                      title: 'Security Fee',
                      description: 'One-time security deposit charged at the time of booking.',
                      child: CustomTextField(
                        label: 'Security Fee (PKR)',
                        hint: 'e.g. 5000',
                        controller: _securityFeeController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.payments,
                        validator: Validators.rent,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Rent Deadline Card
                    _buildSectionCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Rent Deadline',
                      description: 'Number of days after the start of each month by which rent must be paid.',
                      child: CustomTextField(
                        label: 'Deadline (Days)',
                        hint: 'e.g. 7',
                        controller: _deadlineDaysController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.timer,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final n = int.tryParse(value);
                          if (n == null || n < 1 || n > 28) return 'Enter 1-28 days';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Daily Fine Card
                    _buildSectionCard(
                      context,
                      icon: Icons.warning_amber,
                      title: 'Daily Fine',
                      description: 'Fine applied per day after the deadline passes without payment.',
                      child: CustomTextField(
                        label: 'Fine Per Day (PKR)',
                        hint: 'e.g. 100',
                        controller: _dailyFineController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.money_off,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final n = double.tryParse(value);
                          if (n == null || n < 0) return 'Enter a valid amount';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Info box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.info),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'These settings apply to all current and future residents of this hostel. Students will see the security fee and terms during booking.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    CustomButton(
                      text: 'Save Settings',
                      onPressed: _saveSettings,
                      isLoading: _isSaving,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final hostelRepo = ref.read(hostelRepositoryProvider);
      await hostelRepo.updateHostel(widget.hostelId, {
        'securityFee': double.parse(_securityFeeController.text),
        'rentDeadlineDays': int.parse(_deadlineDaysController.text),
        'dailyFineAmount': double.parse(_dailyFineController.text),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

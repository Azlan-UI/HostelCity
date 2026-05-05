import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/config/country_config.dart';
import '../../providers/auth_providers.dart';
import '../../providers/service_providers.dart';
import '../../../../domain/enums/payment_status.dart';
import '../../../../data/models/resident_model.dart';
import '../../../../data/models/dues_model.dart';
import '../../providers/student_providers.dart';
import '../../providers/admin_providers.dart';
import '../../providers/dues_providers.dart';


class PaymentGatewayDialog extends ConsumerStatefulWidget {
  final BookingModel booking;
  const PaymentGatewayDialog({super.key, required this.booking});

  @override
  ConsumerState<PaymentGatewayDialog> createState() => _PaymentGatewayDialogState();
}

class _PaymentGatewayDialogState extends ConsumerState<PaymentGatewayDialog> {
  PaymentMethod? _selectedMethod;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox();
        // Pakistan-only - use PKR currency
        final methods = _getAllPaymentMethods();

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Payment',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pay Rs.${widget.booking.rent.toInt()} to confirm your booking.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Text('Select Payment Method', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: methods.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final method = methods[index];
                      return _buildMethodTile(method);
                    },
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_selectedMethod == null || _isProcessing) ? null : _processPayment,
                    child: _isProcessing 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Confirm & Pay'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading user data'),
    );
  }

  Widget _buildMethodTile(PaymentMethod method) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(_getMethodIcon(method), color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 16),
            Text(_getMethodName(method), style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  List<PaymentMethod> _getAllPaymentMethods() {
    return [PaymentMethod.easypaisa, PaymentMethod.jazzcash, PaymentMethod.card];
  }

  List<PaymentMethod> _getMethodsForCountry(String code) {
    switch (code) {
      case 'PK': return [PaymentMethod.easypaisa, PaymentMethod.jazzcash, PaymentMethod.card];
      case 'IN': return [PaymentMethod.upi, PaymentMethod.wallet, PaymentMethod.card];
      case 'US':
      case 'UK': return [PaymentMethod.applePay, PaymentMethod.googlePay, PaymentMethod.card];
      default: return [PaymentMethod.card, PaymentMethod.wallet];
    }
  }

  String _getMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi: return 'UPI (GPay, PhonePe)';
      case PaymentMethod.easypaisa: return 'EasyPaisa';
      case PaymentMethod.jazzcash: return 'JazzCash';
      case PaymentMethod.applePay: return 'Apple Pay';
      case PaymentMethod.googlePay: return 'Google Pay';
      case PaymentMethod.card: return 'Credit / Debit Card';
      case PaymentMethod.wallet: return 'Digital Wallet';
    }
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi: return Icons.account_balance;
      case PaymentMethod.card: return Icons.credit_card;
      case PaymentMethod.wallet: return Icons.account_balance_wallet;
      default: return Icons.payment;
    }
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate gateway delay
    await Future.delayed(const Duration(seconds: 2));



    try {
      final user = ref.read(currentUserProvider).value!;
      final payment = PaymentModel(
        paymentId: '', // Assigned by repo
        bookingId: widget.booking.bookingId,
        hostelId: widget.booking.hostelId,
        userId: user.userId,
        amount: widget.booking.rent,
        currency: 'Rs.',
        status: PaymentStatus.paid,
        method: _selectedMethod!,
        transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        dueDate: DateTime.now(),
        paidDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await ref.read(paymentRepositoryProvider).processPayment(payment);

      // Create Resident Record
      final resident = ResidentModel(
        residentId: '', // Assigned by repo
        userId: user.userId,
        hostelId: widget.booking.hostelId,
        roomId: 'Pending Allocation', // Placeholder
        bedId: 'Pending Allocation', // Placeholder
        bookingId: widget.booking.bookingId,
        moveInDate: DateTime.now(),
        isActive: true,
        userName: user.name,
        userEmail: user.email,
        userPhone: user.phone ?? '',
      );
      await ref.read(residentRepositoryProvider).createResident(resident);

      // Create Initial Dues Record (Paid)
      final now = DateTime.now();
      final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final dues = DuesModel(
        duesId: '',
        studentId: user.userId,
        hostelId: widget.booking.hostelId,
        bookingId: widget.booking.bookingId,
        month: monthStr,
        rentAmount: widget.booking.rent,
        totalAmount: widget.booking.rent,
        dueDate: now,
        paidDate: now,
        status: DuesStatus.paid,
        createdAt: now,
        studentName: user.name,
        hostelName: widget.booking.hostelName,
        fineAmount: 0,
      );
      await ref.read(duesRepositoryProvider).createDues(dues);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful! Bed Reserved & Resident Record Created.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
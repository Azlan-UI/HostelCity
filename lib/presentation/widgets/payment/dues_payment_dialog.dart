import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/models/dues_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/service_providers.dart';
import '../../providers/dues_providers.dart';
import '../../../domain/enums/payment_status.dart';


class DuesPaymentDialog extends ConsumerStatefulWidget {
  final DuesModel dues;
  const DuesPaymentDialog({super.key, required this.dues});

  @override
  ConsumerState<DuesPaymentDialog> createState() => _DuesPaymentDialogState();
}

class _DuesPaymentDialogState extends ConsumerState<DuesPaymentDialog> {
  PaymentMethod? _selectedMethod;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pay Dues',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pay Rs.${widget.dues.totalAmount.toStringAsFixed(0)} for ${widget.dues.month}.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
             if (widget.dues.fineAmount > 0)
              Text(
                '(Includes fine of Rs.${widget.dues.fineAmount.toStringAsFixed(0)})',
                 style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
            const SizedBox(height: 24),
            Text('Select Payment Method', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _getAllPaymentMethods().length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final method = _getAllPaymentMethods()[index];
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
        bookingId: widget.dues.bookingId,
        hostelId: widget.dues.hostelId,
        userId: user.userId,
        amount: widget.dues.totalAmount,
        currency: 'Rs.',
        status: PaymentStatus.paid,
        method: _selectedMethod!,
        transactionId: 'TXN-DUES-${DateTime.now().millisecondsSinceEpoch}',
        dueDate: widget.dues.dueDate,
        paidDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Record Payment
      await ref.read(paymentRepositoryProvider).processPayment(payment);
      
      // Update Dues Status
      await ref.read(duesRepositoryProvider).updateDuesStatus(
        widget.dues.duesId, 
        DuesStatus.paid,
        fineAmount: widget.dues.fineAmount
      );
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dues Paid Successfully!')),
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedPayment = 'cash';
  final _amountController = TextEditingController();
  double _amountPaid = 0;
  
  @override
  void initState() {
    super.initState();
    final total = ref.read(cartProvider.notifier).total;
    _amountController.text = total.toInt().toString();
    _amountPaid = total;
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartProvider.notifier).total;
    final change = _amountPaid - cartTotal;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: Column(
        children: [
          // Cart items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('${item.quantity} x ${CurrencyFormatter.format(item.product.price)}'),
                    trailing: Text(
                      CurrencyFormatter.format(item.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Payment section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 18)),
                      Text(
                        CurrencyFormatter.format(cartTotal),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment method selection
                  const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _PaymentMethodButton(
                        icon: Icons.money,
                        label: 'Tunai',
                        isSelected: _selectedPayment == 'cash',
                        onTap: () => setState(() {
                          _selectedPayment = 'cash';
                          _amountPaid = cartTotal;
                          _amountController.text = cartTotal.toInt().toString();
                        }),
                      ),
                      const SizedBox(width: 8),
                      _PaymentMethodButton(
                        icon: Icons.qr_code,
                        label: 'QRIS',
                        isSelected: _selectedPayment == 'qris',
                        onTap: () => setState(() {
                          _selectedPayment = 'qris';
                          _amountPaid = cartTotal;
                          _amountController.text = cartTotal.toInt().toString();
                        }),
                      ),
                      const SizedBox(width: 8),
                      _PaymentMethodButton(
                        icon: Icons.account_balance,
                        label: 'Transfer',
                        isSelected: _selectedPayment == 'transfer',
                        onTap: () => setState(() {
                          _selectedPayment = 'transfer';
                          _amountPaid = cartTotal;
                          _amountController.text = cartTotal.toInt().toString();
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Amount paid (for cash)
                  if (_selectedPayment == 'cash') ...[
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Uang',
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _amountPaid = double.tryParse(value.replaceAll('.', '')) ?? 0;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    // Quick amount buttons
                    Wrap(
                      spacing: 8,
                      children: [
                        _QuickAmountButton(amount: cartTotal, onTap: () {
                          setState(() {
                            _amountPaid = cartTotal;
                            _amountController.text = cartTotal.toInt().toString();
                          });
                        }),
                        _QuickAmountButton(amount: (cartTotal / 1000).ceil() * 1000, onTap: () {
                          setState(() {
                            _amountPaid = (cartTotal / 1000).ceil() * 1000;
                            _amountController.text = ((cartTotal / 1000).ceil() * 1000).toInt().toString();
                          });
                        }),
                        _QuickAmountButton(amount: 20000, onTap: () {
                          setState(() {
                            _amountPaid = 20000;
                            _amountController.text = '20000';
                          });
                        }),
                        _QuickAmountButton(amount: 50000, onTap: () {
                          setState(() {
                            _amountPaid = 50000;
                            _amountController.text = '50000';
                          });
                        }),
                        _QuickAmountButton(amount: 100000, onTap: () {
                          setState(() {
                            _amountPaid = 100000;
                            _amountController.text = '100000';
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Change
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kembalian'),
                        Text(
                          CurrencyFormatter.format(change > 0 ? change : 0),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: change >= 0 ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // QRIS or Transfer info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedPayment == 'qris' ? Icons.qr_code : Icons.account_balance,
                            color: AppColors.primary,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedPayment == 'qris' ? 'Bayar dengan QRIS' : 'Transfer ke Rekening',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _selectedPayment == 'qris' 
                                    ? 'Tunjukkan kode QR ke customer'
                                    : 'Minta customer transfer ke rekening toko',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Pay button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_selectedPayment == 'cash' && _amountPaid >= cartTotal) || 
                               _selectedPayment != 'cash'
                        ? () => _processPayment(context, cartTotal)
                        : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _selectedPayment == 'cash' 
                          ? 'Bayar ${CurrencyFormatter.format(cartTotal)}'
                          : 'Konfirmasi Pembayaran',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _processPayment(BuildContext context, double total) async {
    try {
      final cart = ref.read(cartProvider);
      final change = _amountPaid - total;
      
      await ref.read(transactionsProvider.notifier).createTransaction(
        total: total,
        paymentMethod: _selectedPayment,
        amountPaid: _amountPaid,
        change: change > 0 ? change : 0,
      );
      
      if (context.mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 32),
                SizedBox(width: 8),
                Text('Berhasil!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: ${CurrencyFormatter.format(total)}'),
                Text('Metode: ${_selectedPayment == 'cash' ? 'Tunai' : _selectedPayment == 'qris' ? 'QRIS' : 'Transfer'}'),
                if (_selectedPayment == 'cash')
                  Text('Kembalian: ${CurrencyFormatter.format(change > 0 ? change : 0)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to kasir
                },
                child: const Text('Selesai'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textHint,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final double amount;
  final VoidCallback onTap;
  
  const _QuickAmountButton({required this.amount, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        CurrencyFormatter.format(amount),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

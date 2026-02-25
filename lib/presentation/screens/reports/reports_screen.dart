import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Penjualan'),
            Tab(text: 'Produk'),
            Tab(text: 'Stok'),
            Tab(text: 'Keuangan'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Dari',
                        prefixIcon: Icon(Icons.calendar_today, size: 18),
                      ),
                      child: Text(DateFormatter.formatShortDate(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Sampai',
                        prefixIcon: Icon(Icons.calendar_today, size: 18),
                      ),
                      child: Text(DateFormatter.formatShortDate(_endDate)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SalesReportTab(startDate: _startDate, endDate: _endDate),
                _ProductsReportTab(startDate: _startDate, endDate: _endDate),
                _StockReportTab(),
                _FinanceReportTab(startDate: _startDate, endDate: _endDate),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
}

class _SalesReportTab extends ConsumerWidget {
  final DateTime startDate;
  final DateTime endDate;
  
  const _SalesReportTab({required this.startDate, required this.endDate});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    
    return transactions.when(
      data: (transactionList) {
        final filtered = transactionList.where((t) => 
          t.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) && 
          t.createdAt.isBefore(endDate.add(const Duration(days: 1)))
        ).toList();
        
        final totalSales = filtered.fold(0.0, (sum, t) => sum + t.total);
        final transactionCount = filtered.length;
        final averageTransaction = transactionCount > 0 ? totalSales / transactionCount : 0.0;
        
        // Group by date
        final Map<String, List<dynamic>> byDate = {};
        for (var t in filtered) {
          final dateKey = DateFormatter.formatDate(t.createdAt);
          byDate[dateKey] = [...(byDate[dateKey] ?? []), t];
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Penjualan',
                      value: CurrencyFormatter.format(totalSales),
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Jumlah Transaksi',
                      value: '$transactionCount',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Rata-rata Transaksi',
                      value: CurrencyFormatter.format(averageTransaction),
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Daily breakdown
              Text(
                'Penjualan per Hari',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...byDate.entries.map((entry) {
                final dayTotal = entry.value.fold(0.0, (sum, t) => sum + (t as dynamic).total as double);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(entry.key),
                    subtitle: Text('${entry.value.length} transaksi'),
                    trailing: Text(
                      CurrencyFormatter.format(dayTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
              
              if (filtered.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Tidak ada data'),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _ProductsReportTab extends ConsumerWidget {
  final DateTime startDate;
  final DateTime endDate;
  
  const _ProductsReportTab({required this.startDate, required this.endDate});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    
    return products.when(
      data: (productList) {
        // Sort by stock
        final sortedProducts = List.of(productList)..sort((a, b) => a.stock.compareTo(b.stock));
        final lowStock = sortedProducts.where((p) => p.isLowStock && p.stock > 0).toList();
        final outOfStock = sortedProducts.where((p) => p.isOutOfStock).toList();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (outOfStock.isNotEmpty) ...[
                Text(
                  'Stok Habis (${outOfStock.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                ...outOfStock.map((p) => _StockItem(product: p, isCritical: true)),
                const SizedBox(height: 16),
              ],
              
              if (lowStock.isNotEmpty) ...[
                Text(
                  'Stok Menipis (${lowStock.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 8),
                ...lowStock.map((p) => _StockItem(product: p, isWarning: true)),
                const SizedBox(height: 16),
              ],
              
              if (outOfStock.isEmpty && lowStock.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, size: 48, color: AppColors.success),
                        SizedBox(height: 8),
                        Text('Semua stok aman!'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _StockReportTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    
    return products.when(
      data: (productList) {
        // Group by category
        final categories = ref.watch(categoriesProvider);
        
        return categories.when(
          data: (categoryList) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categoryList.length,
              itemBuilder: (context, index) {
                final category = categoryList[index];
                final categoryProducts = productList.where((p) => p.categoryId == category.id).toList();
                final totalStock = categoryProducts.fold(0, (sum, p) => sum + p.stock);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    title: Text(category.name),
                    subtitle: Text('${categoryProducts.length} produk, $totalStock stok'),
                    children: categoryProducts.map((p) => ListTile(
                      title: Text(p.name),
                      trailing: Text('${p.stock} ${p.unit}'),
                    )).toList(),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _FinanceReportTab extends ConsumerWidget {
  final DateTime startDate;
  final DateTime endDate;
  
  const _FinanceReportTab({required this.startDate, required this.endDate});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final products = ref.watch(productsProvider);
    
    return transactions.when(
      data: (transactionList) {
        final filtered = transactionList.where((t) => 
          t.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) && 
          t.createdAt.isBefore(endDate.add(const Duration(days: 1)))
        ).toList();
        
        final totalRevenue = filtered.fold(0.0, (sum, t) => sum + t.total);
        
        // Calculate estimated profit
        double totalCost = 0;
        for (var t in filtered) {
          // This would need transaction items to calculate properly
        }
        
        return products.when(
          data: (productList) {
            final totalInventoryValue = productList.fold(0.0, (sum, p) => sum + (p.costPrice * p.stock));
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryCard(
                    title: 'Total Pendapatan',
                    value: CurrencyFormatter.format(totalRevenue),
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'Nilai Inventori',
                    value: CurrencyFormatter.format(totalInventoryValue),
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'Estimasi Laba Kotor',
                    value: CurrencyFormatter.format(totalRevenue - totalInventoryValue),
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 24),
                  
                  // Payment method breakdown
                  Text(
                    'Metode Pembayaran',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ..._buildPaymentBreakdown(filtered),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
  
  List<Widget> _buildPaymentBreakdown(List<dynamic> transactions) {
    final Map<String, double> breakdown = {};
    for (var t in transactions) {
      final method = t.paymentMethod;
      breakdown[method] = (breakdown[method] ?? 0) + t.total;
    }
    
    return breakdown.entries.map((entry) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(
            entry.key == 'cash' ? Icons.money : 
            entry.key == 'qris' ? Icons.qr_code : Icons.account_balance,
            color: entry.key == 'cash' ? AppColors.cashColor :
            entry.key == 'qris' ? AppColors.qrisColor : AppColors.transferColor,
          ),
          title: Text(
            entry.key == 'cash' ? 'Tunai' : 
            entry.key == 'qris' ? 'QRIS' : 'Transfer',
          ),
          trailing: Text(
            CurrencyFormatter.format(entry.value),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }).toList();
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockItem extends StatelessWidget {
  final dynamic product;
  final bool isCritical;
  final bool isWarning;
  
  const _StockItem({
    required this.product,
    this.isCritical = false,
    this.isWarning = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isCritical ? Icons.error : Icons.warning,
          color: isCritical ? AppColors.error : AppColors.warning,
        ),
        title: Text(product.name),
        trailing: Text(
          '${product.stock} ${product.unit}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCritical ? AppColors.error : AppColors.warning,
          ),
        ),
      ),
    );
  }
}

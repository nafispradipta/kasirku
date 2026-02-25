import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/product_model.dart';
import 'payment_screen.dart';

class KasirScreen extends ConsumerWidget {
  const KasirScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartProvider.notifier).total;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir'),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Kosongkan Keranjang?'),
                    content: const Text('Semua item akan dihapus dari keranjang.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clearCart();
                          Navigator.pop(context);
                        },
                        child: const Text('Kosongkan', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Kosongkan', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search products
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari produk atau scan barcode...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    // Open scanner
                  },
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          
          // Categories
          SizedBox(
            height: 40,
            child: Consumer(
              builder: (context, ref, _) {
                final categories = ref.watch(categoriesProvider);
                final selectedCategory = ref.watch(selectedCategoryProvider);
                
                return categories.when(
                  data: (categoryList) => ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: const Text('Semua'),
                          selected: selectedCategory == null,
                          onSelected: (_) {
                            ref.read(selectedCategoryProvider.notifier).state = null;
                          },
                        ),
                      ),
                      ...categoryList.map((category) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(category.name),
                          selected: selectedCategory == category.id,
                          onSelected: (_) {
                            ref.read(selectedCategoryProvider.notifier).state = 
                              selectedCategory == category.id ? null : category.id;
                          },
                        ),
                      )),
                    ],
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Products grid
          Expanded(
            flex: cart.isEmpty ? 1 : 1,
            child: Consumer(
              builder: (context, ref, _) {
                final products = ref.watch(filteredProductsProvider);
                
                return products.when(
                  data: (productList) {
                    if (productList.isEmpty) {
                      return const Center(
                        child: Text('Produk tidak ditemukan'),
                      );
                    }
                    
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        final product = productList[index];
                        return _ProductGridItem(
                          product: product,
                          onTap: () {
                            if (product.stock > 0) {
                              ref.read(cartProvider.notifier).addItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} ditambahkan'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Stok produk habis'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                );
              },
            ),
          ),
          
          // Cart summary
          if (cart.isNotEmpty)
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
                    // Cart items preview
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cart.length > 5 ? 5 : cart.length,
                        itemBuilder: (context, index) {
                          final item = cart[index];
                          return Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.inventory_2, size: 20),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      ref.read(cartProvider.notifier).removeItem(item.product.id!);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${ref.watch(cartProvider.notifier).itemCount} item',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            Text(
                              CurrencyFormatter.format(cartTotal),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PaymentScreen()),
                            );
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text('BAYAR'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  
  const _ProductGridItem({
    required this.product,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: product.stock > 0 ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: product.stock > 0 ? 1 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: product.stock > 0 
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: product.stock > 0 ? AppColors.primary : AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(product.price),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (product.stock > 0 && product.stock <= 10)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Tinggal ${product.stock}',
                      style: const TextStyle(fontSize: 8, color: AppColors.warning),
                    ),
                  ),
                if (product.stock == 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Habis',
                      style: TextStyle(fontSize: 8, color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

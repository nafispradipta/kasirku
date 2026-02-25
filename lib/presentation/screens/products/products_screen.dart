import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProductDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    // Open barcode scanner
                  },
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          
          // Categories filter
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
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Products list
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final products = ref.watch(filteredProductsProvider);
                
                return products.when(
                  data: (productList) {
                    if (productList.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textHint),
                            SizedBox(height: 16),
                            Text('Belum ada produk'),
                            Text('Tambahkan produk pertama Anda'),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        final product = productList[index];
                        return _ProductCard(
                          product: product,
                          onTap: () => _showProductDetails(context, ref, product),
                          onEdit: () => _showEditProductDialog(context, ref, product),
                          onDelete: () => _confirmDelete(context, ref, product),
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showImportDialog(context),
        icon: const Icon(Icons.upload_file),
        label: const Text('Import Excel'),
      ),
    );
  }
  
  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final barcodeController = TextEditingController();
    final priceController = TextEditingController();
    final costController = TextEditingController();
    final stockController = TextEditingController();
    String selectedUnit = 'pcs';
    int? selectedCategory;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tambah Produk', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Produk *'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: barcodeController,
                  decoration: const InputDecoration(labelText: 'Barcode'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Harga Jual *',
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: costController,
                        decoration: const InputDecoration(
                          labelText: 'Harga Modal',
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stockController,
                        decoration: const InputDecoration(labelText: 'Stok'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedUnit,
                        decoration: const InputDecoration(labelText: 'Satuan'),
                        items: ['pcs', 'pack', 'kg', 'gram', 'liter', 'ml', 'dus', 'bal']
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedUnit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, _) {
                    final categories = ref.watch(categoriesProvider);
                    return categories.when(
                      data: (list) => DropdownButtonFormField<int>(
                        value: selectedCategory,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        items: list.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        )).toList(),
                        onChanged: (v) => setState(() => selectedCategory = v),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty || priceController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nama dan harga wajib diisi')),
                        );
                        return;
                      }
                      
                      final product = Product(
                        name: nameController.text,
                        barcode: barcodeController.text.isEmpty ? null : barcodeController.text,
                        price: double.tryParse(priceController.text) ?? 0,
                        costPrice: double.tryParse(costController.text) ?? 0,
                        stock: int.tryParse(stockController.text) ?? 0,
                        unit: selectedUnit,
                        categoryId: selectedCategory,
                      );
                      
                      await ref.read(productsProvider.notifier).addProduct(product);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Simpan'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showEditProductDialog(BuildContext context, WidgetRef ref, Product product) {
    final nameController = TextEditingController(text: product.name);
    final barcodeController = TextEditingController(text: product.barcode ?? '');
    final priceController = TextEditingController(text: product.price.toString());
    final costController = TextEditingController(text: product.costPrice.toString());
    final stockController = TextEditingController(text: product.stock.toString());
    String selectedUnit = product.unit;
    int? selectedCategory = product.categoryId;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Produk', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Produk *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: barcodeController,
                  decoration: const InputDecoration(labelText: 'Barcode'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Harga Jual *',
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: costController,
                        decoration: const InputDecoration(
                          labelText: 'Harga Modal',
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stockController,
                        decoration: const InputDecoration(labelText: 'Stok'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedUnit,
                        decoration: const InputDecoration(labelText: 'Satuan'),
                        items: ['pcs', 'pack', 'kg', 'gram', 'liter', 'ml', 'dus', 'bal']
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedUnit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, _) {
                    final categories = ref.watch(categoriesProvider);
                    return categories.when(
                      data: (list) => DropdownButtonFormField<int>(
                        value: selectedCategory,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        items: list.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        )).toList(),
                        onChanged: (v) => setState(() => selectedCategory = v),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty || priceController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nama dan harga wajib diisi')),
                        );
                        return;
                      }
                      
                      final updatedProduct = product.copyWith(
                        name: nameController.text,
                        barcode: barcodeController.text.isEmpty ? null : barcodeController.text,
                        price: double.tryParse(priceController.text) ?? 0,
                        costPrice: double.tryParse(costController.text) ?? 0,
                        stock: int.tryParse(stockController.text) ?? 0,
                        unit: selectedUnit,
                        categoryId: selectedCategory,
                      );
                      
                      await ref.read(productsProvider.notifier).updateProduct(updatedProduct);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Update'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showProductDetails(BuildContext context, WidgetRef ref, Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _DetailRow(label: 'Harga Jual', value: CurrencyFormatter.format(product.price)),
            _DetailRow(label: 'Harga Modal', value: CurrencyFormatter.format(product.costPrice)),
            _DetailRow(label: 'Stok', value: '${product.stock} ${product.unit}'),
            if (product.barcode != null) 
              _DetailRow(label: 'Barcode', value: product.barcode!),
            _DetailRow(label: 'Laba', value: CurrencyFormatter.format(product.profit)),
            _DetailRow(label: 'Margin', value: '${product.profitMargin.toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  void _confirmDelete(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(productsProvider.notifier).deleteProduct(product.id!);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import dari Excel'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih file Excel (.xlsx) untuk diimport.'),
            SizedBox(height: 8),
            Text('Format kolom: barcode, nama, harga, stok, kategori', 
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur import akan segera tersedia')),
              );
            },
            child: const Text('Pilih File'),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: product.isOutOfStock 
                    ? AppColors.error.withOpacity(0.1)
                    : product.isLowStock
                      ? AppColors.warning.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: product.isOutOfStock 
                    ? AppColors.error
                    : product.isLowStock
                      ? AppColors.warning
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.format(product.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: product.isOutOfStock 
                              ? AppColors.error.withOpacity(0.1)
                              : product.isLowStock
                                ? AppColors.warning.withOpacity(0.1)
                                : AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.isOutOfStock 
                              ? 'Habis'
                              : product.isLowStock
                                ? 'Tinggal ${product.stock}'
                                : 'Stok: ${product.stock}',
                            style: TextStyle(
                              fontSize: 10,
                              color: product.isOutOfStock 
                                ? AppColors.error
                                : product.isLowStock
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _DetailRow({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

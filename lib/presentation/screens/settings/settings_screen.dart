import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../../providers/app_providers.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final storeName = settings['store_name'] ?? 'Toko Saya';
    final storeAddress = settings['store_address'] ?? '';
    final storePhone = settings['store_phone'] ?? '';
    final taxRate = settings['tax_rate'] ?? '0';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          // Store info section
          _SectionHeader(title: 'Informasi Toko'),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Nama Toko'),
            subtitle: Text(storeName),
            onTap: () => _editSetting(context, ref, 'store_name', 'Nama Toko', storeName),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Alamat Toko'),
            subtitle: Text(storeAddress.isEmpty ? 'Belum diatur' : storeAddress),
            onTap: () => _editSetting(context, ref, 'store_address', 'Alamat Toko', storeAddress),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('No. Telepon Toko'),
            subtitle: Text(storePhone.isEmpty ? 'Belum diatur' : storePhone),
            onTap: () => _editSetting(context, ref, 'store_phone', 'No. Telepon', storePhone),
          ),
          
          const Divider(),
          
          // Tax settings
          _SectionHeader(title: 'Pajak'),
          ListTile(
            leading: const Icon(Icons.percent),
            title: const Text('Tarif PPN (%)'),
            subtitle: Text('$taxRate%'),
            onTap: () => _editSetting(context, ref, 'tax_rate', 'Tarif PPN', taxRate),
          ),
          
          const Divider(),
          
          // Data management
          _SectionHeader(title: 'Manajemen Data'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Database'),
            subtitle: const Text('Simpan semua data ke file'),
            onTap: () => _backupData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Database'),
            subtitle: const Text('Pulihkan data dari file backup'),
            onTap: () => _restoreData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export ke Excel'),
            subtitle: const Text('Export produk ke file Excel'),
            onTap: () => _exportToExcel(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import dari Excel'),
            subtitle: const Text('Tambah produk dari file Excel'),
            onTap: () => _importFromExcel(context),
          ),
          
          const Divider(),
          
          // Categories management
          _SectionHeader(title: 'Kategori Produk'),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Kelola Kategori'),
            subtitle: const Text('Tambah, edit, hapus kategori'),
            onTap: () => _showCategoriesDialog(context, ref),
          ),
          
          const Divider(),
          
          // About
          _SectionHeader(title: 'Tentang'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('KasirKu'),
            subtitle: const Text('Versi 1.0.0'),
            onTap: () => _showAboutDialog(context),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  void _editSetting(BuildContext context, WidgetRef ref, String key, String label, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).setSetting(key, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _backupData(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      final data = await db.exportAllData();
      
      final jsonString = jsonEncode(data);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      
      await Share.share(
        jsonString,
        subject: 'KasirKu Backup $timestamp',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup berhasil')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Future<void> _restoreData(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
          'Peringatan: Data yang ada akan ditimpa dengan data dari backup. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                
                if (result != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur restore dalam pengembangan')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Pilih File'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _exportToExcel(BuildContext context, WidgetRef ref) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur export Excel akan segera tersedia')),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  void _importFromExcel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import dari Excel'),
        content: const Text('Pilih file Excel (.xlsx) untuk import produk.\n\nFormat kolom: barcode, nama, harga, stok, kategori'),
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
  
  void _showCategoriesDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kelola Kategori', style: Theme.of(context).textTheme.headlineSmall),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addCategory(context, ref),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final categories = ref.watch(categoriesProvider);
                  
                  return categories.when(
                    data: (categoryList) => ListView.builder(
                      controller: scrollController,
                      itemCount: categoryList.length,
                      itemBuilder: (context, index) {
                        final category = categoryList[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _parseColor(category.color),
                            child: Text(
                              category.name[0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(category.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteCategory(context, ref, category),
                          ),
                        );
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Error')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _addCategory(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedColor = '#2196F3';
    
    final colors = ['#F44336', '#E91E63', '#9C27B0', '#673AB7', 
                    '#3F51B5', '#2196F3', '#03A9F4', '#00BCD4',
                    '#009688', '#4CAF50', '#8BC34A', '#CDDC39',
                    '#FFC107', '#FF9800', '#FF5722', '#795548'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Kategori'),
              ),
              const SizedBox(height: 16),
              const Text('Warna'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((color) => GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _parseColor(color),
                      shape: BoxShape.circle,
                      border: selectedColor == color 
                        ? Border.all(color: Colors.black, width: 2)
                        : null,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(categoriesProvider.notifier).addCategory(
                    _Category(name: nameController.text, color: selectedColor),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _confirmDeleteCategory(BuildContext context, WidgetRef ref, dynamic category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(categoriesProvider.notifier).deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'KasirKu',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 KasirKu - Aplikasi Kasir untuk UMKM',
      children: [
        const SizedBox(height: 16),
        const Text('Aplikasi kasir modern untuk usaha warung klontong dan UMKM.'),
        const SizedBox(height: 8),
        const Text('Fitur: Kasir, Produk, Supplier, Laporan'),
      ],
    );
  }
  
  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _Category {
  final String name;
  final String color;
  
  _Category({required this.name, required this.color});
}

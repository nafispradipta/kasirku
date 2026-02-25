# KasirKu - Aplikasi Kasir untuk UMKM

Aplikasi kasir modern dan mudah digunakan untuk usaha warung klontong dan UMKM.

## Fitur Utama

### 🏪 Modul Produk
- Tambah produk manual dengan barcode
- Scan barcode menggunakan kamera HP
- Import produk dari Excel/CSV
- 8 kategori produk predefined
- Kelola stok produk
- Notifikasi stok menipis

### 💰 Modul Kasir
- Tambah produk ke keranjang dengan cepat
- Edit kuantitas dan diskon per item
- Multiple payment methods:
  - Tunai (Cash)
  - QRIS (Static QR)
  - Transfer Bank Manual
- Hitung kembalian otomatis
- Riwayat transaksi

### 📦 Modul Supplier
- Data supplier lengkap
- Catatan hutang ke supplier
- Riwayat transaksi supplier

### 📊 Modul Laporan
- Penjualan harian, mingguan, bulanan
- Produk terlaris
- Laporan stok menipis
- Analisis keuangan

### ⚙️ Pengaturan
- Nama dan info toko
- Pengaturan pajak (PPN)
- Backup & restore database
- Export ke Excel
- Import dari Excel

## Tech Stack

| Komponen | Teknologi |
|----------|-----------|
| Framework | Flutter 3.x |
| State Management | Riverpod |
| Database | SQLite (sqflite) |
| Arsitektur | Clean Architecture |
| Target Platform | Android, iOS, Web, Desktop |

## Struktur Project

```
kasirku/
├── lib/
│   ├── core/
│   │   ├── constants/      # App constants, colors
│   │   ├── theme/         # App theme
│   │   └── utils/         # Helpers (currency, date)
│   ├── data/
│   │   ├── database/      # SQLite database
│   │   └── models/        # Data models
│   └── presentation/
│       ├── providers/     # Riverpod providers
│       └── screens/       # UI screens
└── assets/
    └── products/          # Predefined products
```

## Cara Install

### Prerequisites
- Flutter SDK 3.x
- Android SDK (untuk Android)
- Xcode (untuk iOS)

### Installasi

```bash
# Clone repository
git clone <repository-url>
cd kasirku

# Install dependencies
flutter pub get

# Run di Android
flutter run -d android

# Run di Web
flutter run -d chrome

# Build APK
flutter build apk --debug
```

## Cara Penggunaan

### 1. Setup Awal
1. Buka aplikasi
2. Masuk ke menu **Pengaturan**
3. Isi nama toko, alamat, dan nomor telepon
4. Tambahkan kategori produk jika diperlukan

### 2. Tambah Produk
- **Manual**: Menu Produk → (+) → Isi form produk
- **Scan Barcode**: Menu Produk → Scan barcode
- **Import Excel**: Menu Produk → Import Excel

### 3. Transaksi Penjualan
1. Buka menu **Kasir**
2. Cari produk atau scan barcode
3. Ketuk produk untuk masukkan ke keranjang
4. Edit kuantitas jika perlu
5. Klik **BAYAR**
6. Pilih metode pembayaran
7. Selesai!

### 4. Lihat Laporan
- Menu **Laporan** untuk melihat:
  - Penjualan per periode
  - Produk terlaris
  - Stok menipis
  - Analisis keuangan

## Payment Methods

### Cash (Tunai)
- Input jumlah uang yang diterima
- Kembalian dihitung otomatis
- Quick buttons untuk uang round

### QRIS
- Tampilkan QRIS static ke customer
- Customer scan dan transfer
- Kasir verifikasi bukti transfer
- Klik "Konfirmasi Pembayaran"

### Transfer Manual
- Customer transfer ke rekening toko
- Tunjukkan bukti transfer ke kasir
- Kasir verifikasi dan konfirmasi

## Database Schema

### Tables
- `products` - Data produk
- `categories` - Kategori produk
- `suppliers` - Data supplier
- `transactions` - Transaksi penjualan
- `transaction_items` - Item-item transaksi
- `settings` - Pengaturan aplikasi

## Development

### Menjalankan Tests
```bash
flutter test
```

### Build Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

## Troubleshooting

### Error: "Flutter command not found"
- Pastikan Flutter sudah di-install dan ada di PATH

### Error: "Android SDK not found"
- Install Android SDK
- Set ANDROID_HOME environment variable

### Error: "SQLite database error"
- Hapus app data dan coba lagi
- Cek permission storage

## Lisensi

MIT License - © 2024 KasirKu

## Kontak

Untuk pertanyaan dan support:
- Email: support@kasirku.app
- Website: www.kasirku.app

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

---

# 🚀 PANDUAN SETUP (Pindah Laptop)

Ikuti langkah-langkah ini ketika Anda pindah ke laptop baru:

## Langkah 1: Install Flutter SDK

### Windows:
1. Download Flutter SDK dari: https://docs.flutter.dev/get-started/install/windows
2. Extract file zip ke lokasi yang diinginkan, contoh: `C:\flutter`
3. Tambahkan Flutter ke PATH:
   - Buka **System Properties** → **Environment Variables**
   - Edit variabel **Path** → Tambah: `C:\flutter\bin`
4. Buka CMD baru, verifikasi dengan:
   ```bash
   flutter --version
   ```

### macOS:
```bash
# Via Homebrew
brew install flutter

# Atau manual
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
flutter --version
```

### Linux (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install curl unzip xz-utils zip libglu1-mesa
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
flutter --version
```

## Langkah 2: Install Android SDK

### Windows (Cara Mudah - Flutter Doctor Auto Install):
```bash
flutter doctor
# Flutter akan meminta install Android SDK jika belum ada
flutter doctor --android-license
```

### Windows (Manual):
1. Download Android Command Line Tools dari: https://developer.android.com/studio#command-line-tools-only
2. Buat folder: `C:\Android\cmdline-tools`
3. Extract ke dalam folder tersebut
4. Set environment variable:
   - `ANDROID_HOME = C:\Android\Sdk`
   - Tambah ke PATH: `%ANDROID_HOME%\cmdline-tools\latest\bin`
5. Install SDK components:
   ```bash
   sdkmanager --install "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```

### macOS:
```bash
# Install Xcode dari App Store (wajib untuk iOS)
# Atau via Homebrew
brew install android-sdk
```

## Langkah 3: Clone Project dari GitHub

```bash
# Clone repository
git clone https://github.com/nafispradipta/kasirku.git

# Masuk ke folder project
cd kasirku
```

## Langkah 4: Install Dependencies

```bash
# Install dependencies Flutter
flutter pub get
```

## Langkah 5: Verifikasi Setup

```bash
# Cek status Flutter
flutter doctor
```

Pastikan semua checklist hijau (✓). Jika ada yang merah:
- Ikuti instruksi di bagian Troubleshooting di bawah

## Langkah 6: Run Aplikasi

```bash
# Run di Android Emulator
flutter run -d emulator-5554

# Run di HP Android (USB Debugging aktif)
flutter run -d android

# Run di Web Browser
flutter run -d chrome

# Run di iOS (hanya macOS)
flutter run -d ios
```

---

## 📁 Struktur Project

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
├── assets/
│   └── products/          # Predefined products
└── android/               # Android platform files
```

---

## 🔧 Build APK

```bash
# Debug APK (untuk testing)
flutter build apk --debug

# Release APK (untuk distribute)
flutter build apk --release

# APK akan ada di: build/app/outputs/flutter-apk/
```

---

## 📱 Cara Penggunaan

### 1. Setup Awal
1. Buka aplikasi
2. Masuk ke menu **Pengaturan** (icon gear di pojok kanan atas)
3. Isi nama toko, alamat, dan nomor telepon
4. Tambahkan kategori produk jika diperlukan

### 2. Tambah Produk
- **Manual**: Menu Produk → (+) → Isi form produk
- **Scan Barcode**: Menu Produk → Scan barcode (icon kamera)
- **Import Excel**: Menu Produk → Import Excel

### 3. Transaksi Penjualan
1. Buka menu **Kasir** (icon kasir/calculator)
2. Cari produk atau scan barcode
3. Ketuk produk untuk masukkan ke keranjang
4. Edit kuantitas jika perlu
5. Klik **BAYAR**
6. Pilih metode pembayaran (Tunai/QRIS/Transfer)
7. Selesai!

### 4. Lihat Laporan
- Menu **Laporan** untuk melihat:
  - Penjualan per periode
  - Produk terlaris
  - Stok menipis
  - Analisis keuangan

---

## 💳 Payment Methods

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

---

## 🗄️ Database Schema

### Tables
- `products` - Data produk
- `categories` - Kategori produk
- `suppliers` - Data supplier
- `transactions` - Transaksi penjualan
- `transaction_items` - Item-item transaksi
- `settings` - Pengaturan aplikasi

---

## ⚠️ Troubleshooting

### Error: "Flutter command not found"
```bash
# Pastikan Flutter ada di PATH
echo $PATH          # Linux/Mac
echo %PATH%         # Windows

# Atau jalankan dengan path lengkap
C:\flutter\bin\flutter.exe --version
```

### Error: "Android SDK not found"
```bash
# Install Android SDK
flutter doctor --android-license

# Atau set ANDROID_HOME manually
export ANDROID_HOME=/path/to/android/sdk   # Linux/Mac
set ANDROID_HOME=C:\Android\Sdk           # Windows
```

### Error: "No devices available"
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>

# Atau cek connected devices
flutter devices
```

### Error: "Gradle failed" saat build
```bash
# Clean dan rebuild
flutter clean
flutter pub get
flutter build apk --debug
```

### Error: "Permission denied" (Linux)
```bash
# Tambahkan android SDK permissions
sudo chmod -R 777 ~/Android/Sdk
```

---

## 🔄 Cara Update Project dari GitHub

Jika ada perubahan dari collaborator atau Anda ingin sync:

```bash
# Pull latest changes
git pull origin master

# Atau fetch + merge
git fetch origin
git merge origin/master

# Install dependencies baru jika ada
flutter pub get

# Clean dan rebuild
flutter clean
flutter build apk --debug
```

---

## 💾 Backup & Restore

### Backup Database
1. Buka menu **Pengaturan**
2. Pilih **Backup Database**
3. File akan di-share/export

### Restore Database
1. Buka menu **Pengaturan**
2. Pilih **Restore Database**
3. Pilih file backup sebelumnya

---

## 📝 Catatan Penting

- **Flutter SDK TIDAK di-commit** ke git - harus di-download sendiri
- **Database tersimpan lokal** di HP - tidak ada cloud sync di versi ini
- **8 Kategori default** sudah ada: Mie Instan, Kopi & Minuman, Snack, Minuman Ringan, Sabun & Sampo, Obat-obatan, Bahan Pokok, Lainnya

---

## 📞 Support

Untuk pertanyaan dan bantuan:
- GitHub Issues: https://github.com/nafispradipta/kasirku/issues

---

## Lisensi

MIT License - © 2024 KasirKu

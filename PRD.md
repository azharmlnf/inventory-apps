```markdown
# Product Requirements Document (PRD) - Inventarisku

**Versi:** 1.0  
**Tanggal:** 17 September 2025  
**Penulis:** [Azhar Maulana Ferdiansyah /M. Gunawan Adi Winangun]

---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen ini menguraikan persyaratan produk untuk **Aplikasi Manajemen Inventaris Sederhana**, sebuah aplikasi mobile berbasis Flutter yang dirancang untuk membantu individu dan usaha kecil dalam melacak stok barang masuk dan keluar dengan mudah dan efisien. Aplikasi ini akan beroperasi sepenuhnya secara offline dengan penyimpanan data lokal, dan tidak memerlukan proses login atau registrasi.

### 1.2 Lingkup (MVP)
Lingkup awal (Minimum Viable Product - MVP) akan berfokus pada fungsionalitas inti untuk manajemen barang, pencatatan transaksi dasar, dan pelaporan sederhana. Fitur-fitur yang lebih canggih akan direncanakan untuk rilis berikutnya.

### 1.3 Target Pengguna
- **Individu/Pengguna Rumahan**: melacak barang pribadi atau koleksi.
- **Usaha Kecil/Mikro (UMKM)**: toko kecil, warung, penjual online.
- **Pemilik Gudang/Penyimpanan**: memantau barang di gudang.

### 1.4 Nilai Jual Unik (USP)
- **Kesederhanaan & Kemudahan Penggunaan**: antarmuka intuitif.
- **Ringan & Cepat**: performa optimal bahkan di perangkat lama.
- **Offline First**: berfungsi penuh tanpa internet.
- **Tanpa Login**: langsung pakai tanpa registrasi.
- **Gratis**: tidak ada biaya penggunaan.

---

## 2. Fitur & Fungsionalitas (MVP)

### 2.1 Manajemen Barang
- **[FR1.1] Tambah Barang**: detail meliputi nama, deskripsi, kuantitas awal, unit, harga beli, harga jual, gambar.
- **[FR1.2] Edit Barang**: ubah detail barang.
- **[FR1.3] Hapus Barang**: hapus barang (dengan konfirmasi).
- **[FR1.4] Daftar Barang**: tampilkan semua barang dengan nama, kuantitas, harga.
- **[FR1.5] Pencarian Barang**: cari berdasarkan nama.
- **[FR1.6] Pengurutan Barang**: urutkan (A-Z, Z-A).

### 2.2 Pencatatan Transaksi
- **[FR2.1] Tambah Transaksi Masuk**: pilih barang, kuantitas, tanggal, catatan.
- **[FR2.2] Tambah Transaksi Keluar**: pilih barang, kuantitas, tanggal, catatan.
- **[FR2.3] Update Kuantitas Otomatis**: stok diperbarui setelah transaksi.

### 2.3 Pelaporan Sederhana
- **[FR3.1] Ringkasan Stok**: daftar barang + kuantitas saat ini.
- **[FR3.2] Riwayat Transaksi**: daftar semua transaksi.
- **[FR3.3] Filter Riwayat Transaksi**: berdasarkan tipe transaksi atau rentang tanggal.

### 2.4 Ekspor & Impor Data
- **[FR4.1] Ekspor Data**: ekspor barang & transaksi ke CSV/Excel.
- **[FR4.2] Impor Data**: impor barang dari CSV/Excel.

### 2.5 Antarmuka Pengguna & Interaksi
- **[FR5.1] Dashboard/Menu Utama**: navigasi ke fitur utama.
- **[FR5.2] Detail Barang**: lihat detail barang, edit, atau tambah transaksi.

---

## 3. Desain & Antarmuka Pengguna (UI/UX)
- **[UX1.1] Intuitif**: desain minimalis & bersih.
- **[UX1.2] Konsisten**: UI & navigasi konsisten.
- **[UX1.3] Responsif**: dukung berbagai ukuran layar.
- **[UI1.1] Warna**: tema sederhana & netral (misal teal/abu-abu).
- **[UI1.2] Ikonografi**: ikon jelas & mudah dikenali.
- **[UI1.3] Feedback Visual**: notifikasi/indikator setelah aksi.

---

## 4. Persyaratan Non-Fungsional

### 4.1 Performa
- **[NFR1.1] Kecepatan**: responsif hingga ribuan item/transaksi.
- **[NFR1.2] Memori**: ringan, hemat sumber daya.

### 4.2 Skalabilitas
- **[NFR2.1] Data**: mampu menangani pertumbuhan data.

### 4.3 Keamanan
- **[NFR3.1] Data Lokal**: aman dari akses aplikasi lain.

### 4.4 Kompatibilitas
- **[NFR4.1] Platform**: Android (API level min tertentu), iOS (min versi tertentu).
- **[NFR4.2] Flutter**: gunakan versi stabil terbaru.

### 4.5 Maintainability
- **[NFR5.1] Clean Code**: arsitektur modular & clean.
- **[NFR5.2] Dokumentasi**: komentar kode memadai.

---

## 5. Model Data (Struktur Database)

### Entitas: Barang (Item)
- id (PK)
- nama (TEXT, NOT NULL)
- deskripsi (TEXT)
- kuantitas (INTEGER, NOT NULL, default 0)
- unit (TEXT, NOT NULL)
- harga_beli (REAL)
- harga_jual (REAL)
- gambar_path (TEXT)
- barcode (TEXT, UNIQUE)
- created_at (DATETIME)
- updated_at (DATETIME)

### Entitas: Transaksi (Transaction)
- id (PK)
- item_id (FK ke Barang.id)
- tipe (TEXT: MASUK/KELUAR)
- kuantitas (INTEGER, NOT NULL)
- tanggal (DATETIME, NOT NULL)
- catatan (TEXT)
- created_at (DATETIME)

---

## 6. Arsitektur Teknis & Peran Library
- **Flutter SDK**: framework utama.
- **State Management**: Provider atau Bloc (MVP gunakan Provider).
- **Database**: sqflite (SQLite). Alternatif: Hive/Isar.
- **Path Provider**: akses jalur penyimpanan.
- **Image Picker**: ambil foto atau pilih gambar.
- **CSV/Excel**: `csv` & `excel` package.
- **Share_plus**: berbagi file.

### Clean Architecture
- **Presentation Layer**: UI, state management.
- **Domain Layer**: entities, use cases, repository interfaces.
- **Data Layer**: implementasi repositori, database lokal.

---

## 7. Struktur Proyek


```bash
.
├── lib/
│ ├── main.dart
│ ├── app/ # Konfigurasi aplikasi, tema, routing
│ ├── core/ # Utilities, helpers, constants
│ ├── features/ # Modul per fitur
│ │ ├── item_management/
│ │ ├── transaction_history/
│ │ └── reports/
│ └── shared/ # Widget umum
├── pubspec.yaml
├── README.md

```

---


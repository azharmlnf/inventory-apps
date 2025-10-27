
# Product Requirements Document (PRD) - Inventarisku

**Versi:** 1.0  
**Tanggal:** 17 September 2025  
**Penulis:** [Azhar Maulana Ferdiansyah /M. Gunawan Adi Winangun]

---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen ini menguraikan persyaratan produk untuk **Aplikasi Manajemen Inventaris Sederhana**, sebuah aplikasi mobile berbasis Flutter yang dirancang untuk membantu individu dan usaha kecil dalam melacak stok barang masuk dan keluar dengan mudah dan efisien. Aplikasi ini akan beroperasi sepenuhnya secara offline dengan penyimpanan data lokal, dan tidak memerlukan proses login atau registrasi.

### 1.2 Lingkup Produk
Lingkup produk ini mencakup fungsionalitas inti untuk manajemen inventaris (fitur gratis) serta fitur-fitur premium seperti backup cloud dan penghapusan iklan. Aplikasi ini akan terus beroperasi secara offline sebagai prioritas utama, dengan opsi sinkronisasi cloud untuk fitur premium.

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

## 2. Fitur & Fungsionalitas

### 2.1 Fitur Gratis (MVP)

#### 2.1.1 Manajemen Barang
- **[FR1.1] Tambah, Ubah, Hapus, Lihat Barang**: Pengguna dapat mengelola detail barang secara manual.
- **[FR1.2] Input Stok, Kategori, Batas Restock**: Pengguna dapat memasukkan kuantitas stok, menetapkan kategori, dan menentukan batas minimum stok untuk pengingat.

#### 2.1.2 Kategori Produk
- **[FR1.3] Pengelompokan Barang**: Mengelompokkan barang berdasarkan kategori (misalnya: Elektronik, Dapur, Kantor).

#### 2.1.3 Pengingat Restock
- **[FR1.4] Notifikasi Otomatis**: Menerima notifikasi jika stok barang mencapai atau di bawah batas minimum yang ditentukan.

#### 2.1.4 Riwayat Aktivitas (Activity Log)
- **[FR1.5] Pencatatan Aktivitas Pengguna**: Menyimpan catatan aktivitas penting pengguna, seperti penambahan/pengurangan stok, dengan detail waktu dan barang terkait. Contoh: “Kamu menambahkan 5 stok untuk Barang A pada 27/10/2025, 14:21.”

#### 2.1.5 Grafik Stok Barang
- **[FR1.6] Visualisasi Stok**: Menampilkan grafik batang atau pie chart untuk memberikan gambaran visual stok per kategori.

### 2.2 Fitur Premium

#### 2.2.1 Backup ke Cloud (Firebase Storage)
- **[FRP1.1] Backup Data Manual**: Menyimpan seluruh data aplikasi ke Firebase Storage secara manual.
- **[FRP1.2] Backup Otomatis Harian**: (Akan dikembangkan) Fitur backup otomatis harian menggunakan Workmanager.

#### 2.2.2 Restore Data
- **[FRP1.3] Pemulihan Data**: Mengunduh dan memulihkan data dari cloud (Firebase Storage) ke penyimpanan lokal SQLite.

#### 2.2.3 Tanpa Iklan
- **[FRP1.4] Pengalaman Bebas Iklan**: Menghapus semua iklan banner dan interstitial dari aplikasi.

### 2.3 Pencatatan Transaksi (Dipertahankan dari sebelumnya, namun perlu disesuaikan jika ada perubahan)
- **[FR2.1] Tambah Transaksi Masuk**: pilih barang, kuantitas, tanggal, catatan.
- **[FR2.2] Tambah Transaksi Keluar**: pilih barang, kuantitas, tanggal, catatan.
- **[FR2.3] Update Kuantitas Otomatis**: stok diperbarui setelah transaksi.

### 2.4 Pelaporan Sederhana (Dipertahankan dari sebelumnya, namun perlu disesuaikan jika ada perubahan)
- **[FR3.1] Ringkasan Stok**: daftar barang + kuantitas saat ini.
- **[FR3.2] Riwayat Transaksi**: daftar semua transaksi.
- **[FR3.3] Filter Riwayat Transaksi**: berdasarkan tipe transaksi atau rentang tanggal.

### 2.5 Antarmuka Pengguna & Interaksi (Dipertahankan dari sebelumnya, namun perlu disesuaikan jika ada perubahan)
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

### Entitas: Riwayat Aktivitas (Activity Log)
- id (PK)
- timestamp (DATETIME, NOT NULL)
- description (TEXT, NOT NULL)
- item_id (FK ke Barang.id, nullable)
- user_id (FK ke User.id, opsional jika ada multi-user)
- type (TEXT: ADD_STOCK, REMOVE_STOCK, ADD_ITEM, EDIT_ITEM, DELETE_ITEM, etc.)

---

## 6. Arsitektur Teknis & Peran Library
- **Flutter SDK**: framework utama.
- **State Management**: Provider / Riverpod.
- **Database**: SQLite (sqflite package).
- **Chart Visualization**: fl_chart.
- **Cloud Backup**: Firebase Storage.
- **Ads Monetization**: Google AdMob.
- **In-App Purchase**: in_app_purchase Flutter plugin.
- **Local Notifications**: flutter_local_notifications.
- **Backup Scheduler**: workmanager (untuk backup otomatis harian).
- **Path Provider**: akses jalur penyimpanan.
- **Image Picker**: ambil foto atau pilih gambar.
- **CSV/Excel**: `csv` & `excel` package.
- **Share_plus**: berbagi file.

### Layered Architecture
- **Presentation Layer**: UI, state management.
- **Business Logic Layer**: entities, use cases, repository interfaces.
- **Data Layer**: implementasi repositori, database lokal, integrasi cloud.

## 7. Model Monetisasi

### 7.1 Iklan (Gratis)
- **[MON1.1] Banner & Interstitial Ads**: Menggunakan Google AdMob untuk menampilkan iklan banner dan interstitial pada versi gratis aplikasi.

### 7.2 Premium Upgrade
- **[MON2.1] Penghapusan Iklan**: Pengguna premium tidak akan melihat iklan.
- **[MON2.2] Fitur Backup Cloud**: Mengaktifkan fitur backup dan restore data ke/dari Firebase Storage.

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


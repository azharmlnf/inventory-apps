
# Product Requirements Document (PRD) - Inventarisku

**Versi:** 2.1  
**Tanggal:** 30 Oktober 2025  
**Penulis:** [Azhar Maulana Ferdiansyah /M. Gunawan Adi Winangun]

---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen ini menguraikan persyaratan produk untuk **Aplikasi Manajemen Inventaris "Inventarisku"**, sebuah aplikasi mobile berbasis Flutter yang dirancang untuk membantu individu dan usaha kecil dalam melacak stok barang. Aplikasi ini beroperasi dengan **database online (Appwrite)** untuk memungkinkan **akses multi-perangkat** melalui proses **login**.

### 1.2 Lingkup Produk
Lingkup produk mencakup fungsionalitas inti untuk manajemen inventaris yang datanya tersinkronisasi secara online. Aplikasi memerlukan pengguna untuk login untuk mengakses data mereka. Model monetisasi didasarkan pada iklan untuk versi gratis dan opsi berlangganan premium untuk pengalaman bebas iklan.

### 1.3 Target Pengguna
- **Usaha Kecil/Mikro (UMKM)**: toko kecil, warung, atau penjual online yang membutuhkan data inventaris yang dapat diakses oleh beberapa karyawan atau dari perangkat yang berbeda.
- **Tim atau Organisasi Kecil**: mengelola aset atau persediaan internal.
- **Pengguna Individu**: melacak barang pribadi di beberapa perangkat (misalnya, ponsel dan tablet).

### 1.4 Nilai Jual Unik (USP)
- **Sinkronisasi Cloud & Multi-Perangkat**: Akses data inventaris Anda di mana saja dan kapan saja.
- **Login Mudah**: Registrasi dan Login menggunakan Email/Password.
- **Antarmuka Intuitif**: Desain yang sederhana dan mudah digunakan, bahkan untuk pengguna non-teknis.
- **Model Freemium yang Jelas**: Gunakan secara gratis dengan iklan, atau tingkatkan ke premium untuk menghilangkan iklan.

---

## 2. Fitur & Fungsionalitas

### 2.1 Autentikasi Pengguna
- **[FR0.1] Registrasi Pengguna**: Pengguna dapat mendaftar menggunakan email dan password.
- **[FR0.2] Login Pengguna**: Pengguna dapat masuk menggunakan email dan password yang terdaftar.
- **[FR0.3] Manajemen Sesi**: Aplikasi akan menjaga pengguna tetap login hingga mereka secara eksplisit keluar.
- **[FR0.4] Logout**: Pengguna dapat keluar dari akun mereka.

### 2.2 Fitur Gratis (MVP)
*Semua fitur ini memerlukan koneksi internet dan status login.*

#### 2.2.1 Manajemen Barang
- **[FR1.1] Tambah, Ubah, Hapus, Lihat Barang**: Pengguna dapat mengelola detail barang yang terkait dengan akun/workspace mereka.
- **[FR1.2] Input Stok, Kategori, Batas Restock**: Pengguna dapat memasukkan kuantitas stok, menetapkan kategori, dan menentukan batas minimum stok.

#### 2.2.2 Kategori Produk
- **[FR1.3] Pengelompokan Barang**: Mengelompokkan barang berdasarkan kategori.

#### 2.2.3 Pengingat Restock
- **[FR1.4] Notifikasi Otomatis**: Menerima notifikasi jika stok barang mencapai atau di bawah batas minimum yang ditentukan. (Implementasi bisa via push notification atau notifikasi lokal yang dipicu oleh data online).

#### 2.2.4 Riwayat Aktivitas (Activity Log)
- **[FR1.5] Pencatatan Aktivitas**: Menyimpan catatan aktivitas penting yang dilakukan oleh pengguna dalam workspace mereka.

#### 2.2.5 Grafik Stok Barang
- **[FR1.6] Visualisasi Stok**: Menampilkan grafik visual stok per kategori.

#### 2.2.6 Pencatatan Transaksi
- **[FR2.1] Tambah Transaksi Masuk & Keluar**: Mencatat pergerakan barang.
- **[FR2.2] Update Kuantitas Otomatis**: Stok diperbarui secara real-time di database cloud setelah transaksi.

#### 2.2.7 Pelaporan Sederhana
- **[FR3.1] Ringkasan Stok & Riwayat Transaksi**: Menampilkan daftar barang dan semua transaksi yang tercatat.

### 2.3 Fitur Premium

#### 2.3.1 Tanpa Iklan
- **[FRP1.1] Pengalaman Bebas Iklan**: Dengan membeli versi premium, semua iklan banner dan interstitial akan dihilangkan dari aplikasi.

---

## 3. Desain & Antarmuka Pengguna (UI/UX)
- **[UX1.1] Halaman Login/Registrasi**: Antarmuka yang bersih untuk login dan registrasi menggunakan email/password.
- **[UX1.2] Konsistensi**: UI dan navigasi yang konsisten di seluruh aplikasi.
- **[UX1.3] Responsif**: Mendukung berbagai ukuran layar.
- **[UI1.1] Halaman Pengaturan**: Menyertakan detail akun pengguna dan tombol Logout.

---

## 4. Persyaratan Non-Fungsional

### 4.1 Performa
- **[NFR1.1] Kecepatan**: Waktu respons yang cepat untuk operasi data, dengan indikator loading yang jelas saat berinteraksi dengan server.
- **[NFR1.2] Offline-Support (Opsional, Pasca-MVP)**: Aplikasi mungkin menyimpan cache data secara lokal untuk memungkinkan beberapa operasi saat offline, dan menyinkronkannya kembali saat online.

### 4.2 Skalabilitas
- **[NFR2.1] Data**: Arsitektur backend (Appwrite) harus mampu menangani pertumbuhan jumlah pengguna dan data.

### 4.3 Keamanan
- **[NFR3.1] Keamanan Data**: Data pengguna diisolasi dan diamankan menggunakan aturan akses (permissions) di Appwrite. Hanya pengguna yang terautentikasi yang dapat mengakses data mereka.

### 4.4 Ketersediaan
- **[NFR4.1] Ketergantungan Jaringan**: Fitur inti memerlukan koneksi internet untuk berinteraksi dengan backend Appwrite.

---

## 5. Model Data (Struktur Database Appwrite)

*Setiap koleksi akan memiliki Aturan Akses (Permissions) untuk memastikan hanya pengguna yang relevan yang dapat mengakses data.*

### Entitas: Pengguna (Users - Disediakan oleh Appwrite)
- id (PK, Appwrite User ID)
- nama
- email

### Entitas: Barang (Items)
- id (PK, Appwrite Document ID)
- `user_id` (FK ke Users)
- nama (TEXT, NOT NULL)
- deskripsi (TEXT)
- kuantitas (INTEGER, NOT NULL, default 0)
- unit (TEXT, NOT NULL)
- harga_beli (REAL)
- harga_jual (REAL)
- gambar_id (FK ke Appwrite Storage)
- barcode (TEXT, UNIQUE)

### Entitas: Transaksi (Transactions)
- id (PK, Appwrite Document ID)
- `user_id` (FK ke Users)
- `item_id` (FK ke Items)
- tipe (TEXT: MASUK/KELUAR)
- kuantitas (INTEGER, NOT NULL)
- tanggal (DATETIME, NOT NULL)
- catatan (TEXT)

### Entitas: Riwayat Aktivitas (ActivityLogs)
- id (PK, Appwrite Document ID)
- `user_id` (FK ke Users)
- timestamp (DATETIME, NOT NULL)
- description (TEXT, NOT NULL)
- `item_id` (FK ke Items, opsional)

---

## 6. Arsitektur Teknis & Peran Library
- **Flutter SDK**: Framework utama.
- **State Management**: Provider / Riverpod.
- **Backend as a Service (BaaS)**: **Appwrite** (untuk Database, Autentikasi, dan Storage file).
- **Autentikasi**: `appwrite`.
- **Chart Visualization**: `fl_chart`.
- **Ads Monetization**: `google_mobile_ads`.
- **In-App Purchase**: `in_app_purchase`.
- **Lainnya**: `path_provider`, `image_picker`, `csv`, `share_plus`.

### Layered Architecture
- **Presentation Layer**: UI, state management (termasuk status login).
- **Business Logic Layer**: Services yang berinteraksi dengan Appwrite.
- **Data Layer**: Implementasi repository yang membungkus Appwrite SDK untuk operasi data.

## 7. Model Monetisasi

### 7.1 Iklan (Gratis)
- **[MON1.1] Banner & Interstitial Ads**: Menampilkan iklan pada versi gratis.

### 7.2 Premium Upgrade
- **[MON2.1] Penghapusan Iklan**: Pengguna dapat membayar (langganan atau sekali bayar) untuk menghilangkan semua iklan dari aplikasi.

---

## 8. Struktur Proyek (Diusulkan)


```bash
.
├── lib/
│ ├── main.dart
│ ├── app/                     # Konfigurasi aplikasi, tema, routing
│ ├── core/                    # Utilitas, konstanta, Appwrite client
│ ├── features/                # Modul per fitur
│ │ ├── auth/                  # Login, Logout
│ │ ├── item_management/
│ │ └── ...
│ └── ...
├── pubspec.yaml
├── README.md

```

---


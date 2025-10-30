# Software Requirements Specification (SRS) — Inventarisku

**Versi:** 2.1  
**Tanggal:** 30 Oktober 2025  
**Penulis:** [Azhar Maulana Ferdiansyah /M. Gunawan Adi Winangun]
---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen ini bertujuan untuk menjelaskan spesifikasi perangkat lunak aplikasi **Inventarisku**, sebuah aplikasi manajemen inventaris berbasis Flutter yang terhubung ke backend **Appwrite**. Dokumen ini akan menjadi acuan bagi tim pengembang, desainer, dan stakeholder dalam proses desain, implementasi, dan pengujian.

### 1.2 Ruang Lingkup Produk
Inventarisku adalah aplikasi mobile online untuk mencatat barang, transaksi keluar/masuk, serta menyediakan laporan sederhana. Fungsi inti aplikasi bergantung pada koneksi ke server Appwrite untuk semua operasi data (CRUD). Pengguna diwajibkan untuk **login** untuk mengakses data. Model monetisasi adalah freemium, di mana fitur premium satu-satunya adalah **menghilangkan iklan**.

### 1.3 Definisi, Akronim, dan Singkatan
- **MVP**: Minimum Viable Product
- **CRUD**: Create, Read, Update, Delete
- **Appwrite**: Backend as a Service (BaaS) yang digunakan untuk database, autentikasi, dan storage.
- **BaaS**: Backend as a Service

### 1.4 Referensi
- Dokumentasi Appwrite: https://appwrite.io/docs
- Dokumentasi Flutter: https://docs.flutter.dev

---

## 2. Deskripsi Umum

### 2.1 Perspektif Produk
Inventarisku adalah aplikasi klien yang bergantung pada backend Appwrite. Aplikasi ini berjalan di Android/iOS dan memerlukan koneksi internet untuk fungsionalitas penuh. Semua data disimpan dan dikelola oleh Appwrite.

### 2.2 Fungsi Produk
- **Autentikasi Pengguna**: Registrasi dan login melalui email/password.
- **Manajemen Barang**: CRUD data barang yang terikat pada akun pengguna.
- **Kategori & Transaksi**: Pengelompokan barang dan pencatatan pergerakan stok.
- **Notifikasi & Laporan**: Peringatan stok rendah dan laporan dasar.
- **Ekspor Data**: Kemampuan untuk mengekspor data ke format CSV.
- **Monetisasi**: Gratis dengan iklan, dengan opsi premium untuk menghilangkan iklan.

### 2.3 Karakteristik Pengguna
- **Pengguna Bisnis Kecil**: Pemilik atau staf toko yang perlu mengakses data inventaris dari beberapa lokasi atau perangkat.
- **Tim**: Anggota tim yang berbagi tanggung jawab mengelola aset bersama.
- **Karakteristik Umum**: Membutuhkan solusi inventaris yang tersinkronisasi, mudah diakses, dan aman.

### 2.4 Batasan Umum
- **Ketergantungan Internet**: Fungsionalitas inti aplikasi tidak dapat berjalan tanpa koneksi internet.
- **Manajemen Pengguna Terpusat**: Pengelolaan pengguna (pembuatan, autentikasi) sepenuhnya ditangani oleh Appwrite.

### 2.5 Asumsi dan Ketergantungan
- Pengguna memiliki alamat email yang valid.
- Appwrite SDK untuk Flutter tersedia dan kompatibel.

---

## 3. Persyaratan Spesifik

### 3.1 Persyaratan Fungsional

#### 3.1.1 Autentikasi Pengguna
- **[F-AUTH-1]** Sistem harus menyediakan form registrasi dengan email dan password.
- **[F-AUTH-2]** Sistem harus menyediakan form login dengan email dan password.
- **[F-AUTH-3]** Sistem harus menjaga pengguna tetap login hingga mereka secara eksplisit keluar.
- **[F-AUTH-4]** Sistem harus menyediakan fungsionalitas logout.

#### 3.1.2 Manajemen Barang
- **[F-ITEM-1]** Pengguna yang sudah login dapat menambah, mengedit, dan menghapus data barang milik mereka.
- **[F-ITEM-2]** Setiap data barang harus terasosiasi dengan akun pengguna yang membuatnya.

#### 3.1.3 Kategori & Transaksi
- **[F-TRX-1]** Sistem harus memungkinkan pengguna membuat transaksi masuk/keluar yang secara otomatis memperbarui kuantitas barang di database Appwrite.

*(Persyaratan fungsional lain seperti Laporan, Grafik, dll., tetap sama seperti versi sebelumnya tetapi dengan implementasi yang mengarah ke Appwrite.)*

#### 3.1.4 Fitur Premium
- **[F-PREM-1]** **Tanpa Iklan**: Pengguna premium tidak akan melihat iklan banner maupun interstitial dalam aplikasi. Fitur backup/restore data **dihapus**.

#### 3.1.5 Monetisasi
- **[F-MON-1]** Aplikasi versi gratis akan menampilkan iklan (Google AdMob).
- **[F-MON-2]** Pengguna dapat melakukan pembelian dalam aplikasi untuk meningkatkan ke status premium dan menghilangkan iklan.

### 3.2 Persyaratan Non-Fungsional
- **Performa:** Aplikasi harus memberikan feedback visual (seperti loading indicator) saat melakukan operasi jaringan ke Appwrite.
- **Keamanan:** **[NFR-SEC-1]** Semua data pengguna harus dilindungi oleh aturan akses (permissions) di Appwrite. Pengguna hanya dapat membaca/menulis data milik mereka sendiri. **[NFR-SEC-2]** Komunikasi antara aplikasi dan server Appwrite harus melalui koneksi aman (HTTPS).
- **Kompatibilitas:** Android (API min 24/Android 7.0+), iOS (13+).
- **Ketersediaan:** Aplikasi sangat bergantung pada ketersediaan layanan Appwrite dan koneksi internet pengguna.

---

### 3.3 Persyaratan Antarmuka Eksternal

#### 3.3.1 Antarmuka Pengguna (GUI)
- **Halaman Login/Registrasi:** Antarmuka sederhana untuk input email dan password, serta tombol untuk login dan registrasi.
- **Dashboard Utama:** Sama seperti sebelumnya, tetapi semua data diambil dari Appwrite.
- **Halaman Pengaturan:** Diubah untuk menampilkan informasi pengguna yang sedang login (nama, email) dan tombol **Logout**. Opsi backup/restore data dihilangkan.

#### 3.3.2 Antarmuka Perangkat Lunak
- **Plugin Flutter Pihak Ketiga:**
  - `appwrite`: Untuk semua interaksi backend (database, auth, storage).
  - `flutter_web_auth_2`: Untuk menangani redirect OAuth (jika diperlukan untuk fitur lain di masa depan).
  - `provider` / `riverpod`: State management.
  - `google_mobile_ads`: Monetisasi iklan.
  - `in_app_purchase`: Pembelian dalam aplikasi.

#### 3.3.3 Antarmuka Komunikasi
- Komunikasi jaringan (HTTPS) ke endpoint Appwrite adalah wajib untuk semua fungsi inti.
- Komunikasi ke Google AdMob (untuk iklan).

---

### 3.4 Persyaratan Database (Appwrite)

#### 3.4.1 Struktur Koleksi (Collections)
- **Koleksi `items`**:
  - `user_id` (string, Wajib, terindeks)
  - `name`, `description`, `qty`, `unit`, `buy_price`, `sell_price`, `min_qty`, `image_id`
- **Koleksi `categories`**:
  - `user_id` (string, Wajib, terindeks)
  - `name`
- **Koleksi `transactions`**:
  - `user_id` (string, Wajib, terindeks)
  - `item_id`, `type`, `date`, `qty`, `note`
- **Koleksi `activity_logs`**:
  - `user_id` (string, Wajib, terindeks)
  - `timestamp`, `description`, `item_id`, `type`

#### 3.4.2 Aturan Akses (Permissions)
- Untuk setiap dokumen di semua koleksi, hak akses tulis/hapus (`write/delete`) hanya diberikan kepada pengguna yang `user_id`-nya cocok dengan ID pengguna yang membuat dokumen.
- Hak akses baca (`read`) bisa diberikan pada level pengguna yang sama, atau level tim jika ada fitur multi-user di masa depan.


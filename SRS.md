# Software Requirements Specification (SRS) — Inventarisku

**Versi:** 1.0  
**Tanggal:** 17 September 2025  
**Penulis:** [Azhar Maulana Ferdiansyah /M. Gunawan Adi Winangun]
---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen ini bertujuan untuk menjelaskan spesifikasi perangkat lunak aplikasi **Inventarisku**, yaitu aplikasi manajemen inventaris sederhana berbasis Flutter. Dokumen ini akan menjadi acuan bagi tim pengembang, desainer, dan stakeholder dalam proses desain, implementasi, dan pengujian.

### 1.2 Ruang Lingkup Produk
Inventarisku adalah aplikasi mobile untuk mencatat barang, transaksi keluar/masuk, serta menyediakan laporan sederhana. Aplikasi ini ditujukan untuk penggunaan offline dengan penyimpanan data lokal (SQLite), dengan opsi fitur premium untuk backup dan restore data ke cloud (Firebase Storage) serta pengalaman tanpa iklan.



### 1.3 Definisi, Akronim, dan Singkatan
- **MVP**: Minimum Viable Product  
- **CRUD**: Create, Read, Update, Delete  
- **CSV**: Comma-Separated Values (format file)  
- **SQLite**: Database relasional embedded  
- **UX/UI**: User Experience / User Interface  

### 1.4 Referensi
- Brainstorming PRD — Inventarisku (Dokumen internal).
- Referensi aplikasi *Barang dan Persediaan* (Chester Software, Playstore).
- Dokumentasi Flutter: https://docs.flutter.dev
- Dokumentasi sqflite: https://pub.dev/packages/sqflite

### 1.5 Ikhtisar Dokumen
Dokumen ini terbagi menjadi:  
- **Bab 1:** Pendahuluan (konteks & ruang lingkup).  
- **Bab 2:** Deskripsi umum produk.  
- **Bab 3:** Persyaratan spesifik (fungsional, non-fungsional, antarmuka, database).  

---

## 2. Deskripsi Umum

### 2.1 Perspektif Produk
Inventarisku adalah aplikasi standalone yang berjalan di perangkat Android/iOS, bekerja penuh secara offline. Semua data disimpan di perangkat lokal dan dapat diekspor ke file CSV/Excel.

### 2.2 Fungsi Produk
- Manajemen barang (tambah, edit, hapus, daftar, cari, urutkan, input stok, kategori, batas restock).
- Pengelompokan barang berdasarkan kategori.
- Pengingat restock otomatis.
- Pencatatan riwayat aktivitas pengguna (Activity Log).
- Visualisasi stok barang melalui grafik.
- Pencatatan transaksi masuk/keluar.
- Laporan sederhana: stok & riwayat transaksi.
- Ekspor & impor data (CSV/Excel).
- Antarmuka intuitif & sederhana.
- **Fitur Premium:** Backup data ke cloud (Firebase Storage), restore data dari cloud, dan pengalaman tanpa iklan.

### 2.3 Karakteristik Pengguna
- **UMKM/toko kecil**: manajemen stok sederhana.
- **Pengguna rumahan**: melacak barang pribadi.
- **Pemilik gudang kecil**: memantau stok tanpa sistem ERP kompleks.
- **Karakteristik umum**: Non-teknis, membutuhkan aplikasi ringan, mudah, tanpa login.

### 2.4 Batasan Umum
- Hanya mendukung **1 user / 1 perangkat**.
- Beroperasi tanpa internet.
- Data hilang jika aplikasi dihapus tanpa backup manual.
- File ekspor dalam format standar CSV/Excel (tidak terenkripsi).

### 2.5 Asumsi dan Ketergantungan
- Pengguna mampu menggunakan smartphone Android/iOS.
- Flutter SDK versi terbaru yang stabil tersedia.
- Plugin pihak ketiga (sqflite, provider, csv/excel) tersedia dan kompatibel.

---

## 3. Persyaratan Spesifik

### 3.1 Persyaratan Fungsional

#### 3.1.1 Manajemen Barang
- Tambah barang dengan detail (nama, deskripsi, qty, unit, harga beli/jual, gambar, kategori, batas minimum stok).
- Edit & hapus barang.
- Pencarian & pengurutan barang.
- Daftar barang dengan ringkasan qty & harga.

#### 3.1.2 Kategori Produk
- Membuat, mengedit, dan menghapus kategori untuk pengelompokan barang.

#### 3.1.3 Pengingat Restock
- Sistem harus memberikan notifikasi otomatis kepada pengguna jika stok barang mencapai atau berada di bawah batas minimum yang telah ditentukan.

#### 3.1.4 Riwayat Aktivitas (Activity Log)
- Sistem harus mencatat setiap aktivitas penting pengguna terkait perubahan stok atau data barang (misalnya, penambahan/pengurangan stok, penambahan/pengeditan/penghapusan barang) dengan timestamp dan deskripsi yang jelas.

#### 3.1.5 Grafik Stok Barang
- Sistem harus mampu menampilkan visualisasi stok barang dalam bentuk grafik (batang atau pie chart) berdasarkan kategori.

#### 3.1.6 Transaksi
- Tambah transaksi masuk (IN).
- Tambah transaksi keluar (OUT).
- Update otomatis kuantitas barang.
- Catat tanggal, catatan, kuantitas.

#### 3.1.7 Laporan
- Ringkasan stok (qty terkini).
- Riwayat transaksi (dengan filter tanggal/tipe).
- Ekspor laporan ke CSV/Excel.

#### 3.1.8 Ekspor & Impor
- Ekspor data barang & transaksi.
- Impor barang dari file CSV/Excel.

#### 3.1.9 Fitur Premium
- **Backup ke Cloud (Firebase Storage)**: Pengguna premium dapat melakukan backup data secara manual ke Firebase Storage. (Fitur backup otomatis harian akan dikembangkan di versi mendatang).
- **Restore Data**: Pengguna premium dapat mengunduh dan memulihkan data dari Firebase Storage ke penyimpanan lokal.
- **Tanpa Iklan**: Pengguna premium tidak akan melihat iklan banner maupun interstitial dalam aplikasi.

#### 3.1.10 Monetisasi
- Versi 1.0: Gratis dengan iklan.
- Versi premium: Menghapus iklan dan mengaktifkan fitur backup cloud.

---

### 3.2 Persyaratan Non-Fungsional
- **Performa:** aplikasi harus cepat & responsif (bahkan dengan ribuan item/transaksi).
- **Keamanan:** data hanya tersimpan lokal & tidak dapat diakses aplikasi lain. Data cloud backup harus diamankan sesuai standar Firebase.
- **Kompatibilitas:** Android (API min 24/Android 7.0+), iOS (13+).
- **Maintainability:** arsitektur berlapis (Layered Architecture).
- **Usability:** antarmuka intuitif, mudah digunakan tanpa pelatihan.
- **Portabilitas:** dapat berjalan di Android & iOS dengan minimal perubahan.
- **Reliabilitas:** database harus aman dari korupsi dengan mekanisme transaksi. Cloud backup harus memiliki mekanisme penanganan error dan retry.
- **Ketersediaan:** Fitur inti aplikasi harus berfungsi penuh secara offline. Fitur backup/restore cloud memerlukan koneksi internet.

---

### 3.3 Persyaratan Antarmuka Eksternal

#### 3.3.1 Antarmuka Pengguna (GUI)
- **Dashboard utama:** navigasi ke Barang, Transaksi, Laporan, Ekspor/Impor, Pengaturan, dan menampilkan ringkasan stok/grafik.
- **Halaman Barang:** daftar, detail barang, aksi tambah/edit/hapus, input batas restock.
- **Halaman Transaksi:** input transaksi masuk/keluar.
- **Halaman Laporan:** ringkasan stok, riwayat transaksi dengan filter, tampilan grafik stok.
- **Halaman Pengaturan:** preferensi aplikasi, backup/restore data (lokal & cloud), pengaturan notifikasi restock, opsi premium (tanpa iklan).

#### 3.3.2 Antarmuka Perangkat Keras
- Kamera smartphone (opsional) untuk scan barcode atau foto barang.
- Penyimpanan internal perangkat (database & file ekspor).

#### 3.3.3 Antarmuka Perangkat Lunak
- Plugin Flutter pihak ketiga:
  - `sqflite` (database)
  - `provider` / `riverpod` (state management)
  - `fl_chart` (visualisasi grafik)
  - `firebase_storage` (cloud backup)
  - `google_mobile_ads` (monetisasi iklan)
  - `in_app_purchase` (pembelian dalam aplikasi)
  - `flutter_local_notifications` (notifikasi lokal)
  - `workmanager` (penjadwalan tugas latar belakang)
  - `path_provider`, `file_picker` (manajemen file)
  - `image_picker`, `flutter_image_compress` (gambar)
  - `mobile_scanner` (barcode scanning, jika diimplementasikan)
  - `csv`, `excel` (ekspor/impor)
  - `share_plus` (berbagi file)

#### 3.3.4 Antarmuka Komunikasi
- Komunikasi jaringan diperlukan untuk fitur backup/restore cloud (Firebase Storage) dan menampilkan iklan (Google AdMob).

---

### 3.4 Persyaratan Database

#### 3.4.1 Skema Database
- **Tabel `items`**  
  - id (PK)  
  - code (unik, opsional)  
  - name  
  - description  
  - category_id (FK → categories)  
  - unit  
  - buy_price  
  - sell_price  
  - qty (stok terkini)  
  - min_qty  
  - image_path  
  - created_at, updated_at  

- **Tabel `categories`**  
  - id (PK)  
  - name  
  - parent_id (nullable, FK ke categories.id)  

- **Tabel `transactions`**  
  - id (PK)  
  - type (in/out)  
  - date  
  - partner (supplier/pelanggan, opsional)  
  - note  
  - total_amount  
  - created_at  

- **Tabel `transaction_lines`**  
  - id (PK)  
  - transaction_id (FK → transactions.id)  
  - item_id (FK → items.id)  
  - qty  
  - unit_price  
  - subtotal  

- **Tabel `stock_movements`**  
  - id (PK)  
  - item_id (FK → items.id)  
  - change (integer, positif = masuk, negatif = keluar)  
  - source (transaction_id atau manual adjustment)  
  - date  
  - note  

- **Tabel `activity_logs`**
  - id (PK)
  - timestamp (DATETIME, NOT NULL)
  - description (TEXT, NOT NULL)
  - item_id (FK → items.id, nullable)
  - type (TEXT: ADD_STOCK, REMOVE_STOCK, ADD_ITEM, EDIT_ITEM, DELETE_ITEM, etc.)

#### 3.4.2 Relasi
- Satu `item` bisa muncul di banyak `transaction_lines`.  
- Satu `transaction` memiliki banyak `transaction_lines`.  
- `stock_movements` merekam perubahan stok untuk keperluan audit/log.  



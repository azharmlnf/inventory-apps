### Checklist Timeline Pengembangan "Inventarisku" (7 Minggu)

#### Minggu 1: Setup Proyek dan UI/UX
*   [x] Desain UI/UX dasar (prototipe web).
*   [x] Inisialisasi proyek Flutter baru.
*   [x] Konfigurasi Git repository.
*   [x] Setup struktur folder (layered architecture).
*   [x] Tambahkan dependensi utama (Provider/Riverpod, sqflite, dll).

#### Minggu 2: Implementasi CRUD Dasar & UI (Tanpa FK)
*   [x] Definisikan skema tabel `items`, `categories`, `transactions`, `transaction_lines`, `stock_movements`, `activity_logs`.
*   **CRUD Kategori (Flutter):**
    *   [ ] Buat model `Category` (Dart class).
    *   [ ] Implementasi service/use case untuk operasi CRUD `Category`.
    *   [ ] Buat `CategoryListPage` (Flutter Widget) untuk menampilkan daftar kategori.
    *   [ ] Buat `CategoryFormPage` (Flutter Widget) untuk tambah/edit kategori.
    *   [ ] Integrasikan state management (Riverpod) untuk `Category`.
    *   [ ] Tambahkan validasi input sederhana untuk form kategori.
*   **CRUD Transaksi (Flutter):**
    *   [ ] Buat model `Transaction` (Dart class).
    *   [ ] Implementasi service/use case untuk operasi CRUD `Transaction`.
    *   [ ] Buat `TransactionListPage` (Flutter Widget) untuk menampilkan daftar transaksi.
    *   [ ] Buat `TransactionFormPage` (Flutter Widget) untuk tambah/edit transaksi (termasuk input bukti pembayaran opsional).
    *   [ ] Integrasikan state management (Riverpod) untuk `Transaction`.
    *   [ ] Tambahkan validasi input sederhana untuk form transaksi.
*   **Riwayat Aktivitas (Flutter):**
    *   [ ] Buat model `ActivityLog` (Dart class).
    *   [ ] Implementasi service/use case untuk mencatat dan mengambil `ActivityLog`.
    *   [ ] Buat `ActivityLogPage` (Flutter Widget) untuk menampilkan riwayat aktivitas.
    *   [ ] Integrasikan state management (Riverpod) untuk `ActivityLog`.

#### Minggu 3: Implementasi CRUD Barang & Stok (dengan FK)
*   **CRUD Barang (Flutter):**
    *   [ ] Buat model `Item` (Dart class).
    *   [ ] Implementasi service/use case untuk operasi CRUD `Item`.
    *   [ ] Buat `ItemListPage` (Flutter Widget) untuk menampilkan daftar barang dengan pencarian dan pengurutan.
    *   [ ] Buat `ItemFormPage` (Flutter Widget) untuk tambah/edit barang (termasuk input stok, kategori, batas restock, gambar).
    *   [ ] Integrasikan state management (Riverpod) untuk `Item`.
    *   [ ] Tambahkan validasi input sederhana untuk form barang.
*   **Manajemen Stok & Detail Transaksi (Flutter):**
    *   [ ] Buat model `StockMovement` dan `TransactionLine` (Dart class).
    *   [ ] Implementasi service/use case untuk mencatat `StockMovement` dan `TransactionLine` saat transaksi terjadi.
    *   [ ] Pastikan kuantitas barang diperbarui secara otomatis setelah transaksi.
    *   [ ] Integrasikan state management (Riverpod) untuk `StockMovement` dan `TransactionLine`.

#### Minggu 4: Fitur Notifikasi & Pelaporan Dasar
*   **Pengingat Restock (Flutter):**
    *   [ ] Implementasi logika untuk mendeteksi stok rendah berdasarkan `min_qty`.
    *   [ ] Integrasi `flutter_local_notifications` untuk menampilkan notifikasi stok rendah.
    *   [ ] Buat UI untuk pengaturan notifikasi (misalnya, di halaman Pengaturan).
*   **Pelaporan Sederhana (Flutter):**
    *   [ ] Buat `ReportPage` (Flutter Widget) untuk menampilkan ringkasan stok.
    *   [ ] Implementasi logika untuk filter riwayat transaksi berdasarkan tipe dan rentang tanggal.
    *   [ ] Integrasikan state management (Riverpod) untuk data laporan.

#### Minggu 5: Fitur Grafik Stok & Ekspor/Impor Data
*   **Grafik Stok Barang (Flutter):**
    *   [ ] Integrasi `fl_chart` library.
    *   [ ] Implementasi logika untuk mengambil dan mengagregasi data stok per kategori.
    *   [ ] Buat widget grafik (batang/pie chart) untuk menampilkan visualisasi stok.
    *   [ ] Integrasikan state management (Riverpod) untuk data grafik.
*   **Ekspor & Impor Data (Flutter):**
    *   [ ] Implementasi service/use case untuk ekspor data barang & transaksi ke CSV.
    *   [ ] Implementasi service/use case untuk impor data barang dari CSV.
    *   [ ] Buat UI untuk tombol ekspor/impor di halaman Laporan.
    *   [ ] Integrasi `share_plus` untuk membagikan file ekspor.

#### Minggu 6: Implementasi Monetisasi & Cloud Backup
*   **Monetisasi Iklan (Flutter):**
    *   [ ] Integrasi Google AdMob (`google_mobile_ads`) untuk menampilkan iklan banner.
    *   [ ] Implementasi logika untuk menampilkan/menyembunyikan iklan interstitial.
*   **Fitur Premium (Flutter):**
    *   [ ] Integrasi `in_app_purchase` Flutter plugin untuk pembelian premium.
    *   [ ] Implementasi logika untuk mengaktifkan status premium (bebas iklan, fitur cloud).
    *   [ ] Implementasi service/use case untuk backup data manual ke Firebase Storage (`firebase_storage`).
    *   [ ] Implementasi service/use case untuk restore data dari Firebase Storage.
    *   [ ] Buat UI untuk tombol backup/restore dan status premium di halaman Pengaturan.

#### Minggu 7: Testing, Dokumentasi, dan Persiapan Rilis
*   **Testing (Flutter):**
    *   [ ] Tulis dan jalankan Unit Test untuk semua service/use case.
    *   [ ] Tulis dan jalankan Widget Test untuk komponen UI utama.
    *   [ ] Lakukan User Acceptance Testing (UAT) dengan pengguna.
*   **Stabilisasi & Optimasi:**
    *   [ ] Perbaikan bug yang ditemukan selama testing.
    *   [ ] Optimasi performa aplikasi (responsif & ringan).
*   **Dokumentasi & Rilis:**
    *   [ ] Finalisasi dokumentasi teknis (komentar kode, README).
    *   [ ] Siapkan aset aplikasi (ikon, splash screen).
    *   [ ] Konfigurasi aplikasi untuk rilis di Google Play Store dan Apple App Store.
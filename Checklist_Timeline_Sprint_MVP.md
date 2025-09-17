### Checklist Timeline Sprint untuk MVP "Inventarisku"

#### Sprint 0: Fondasi & Penyiapan Proyek (Minggu 1-2)  
*Tujuan: Menyiapkan kerangka kerja, arsitektur, dan alat pengembangan.*

- [ ] **Inisialisasi Proyek:**
  - [ ] Buat proyek Flutter baru
  - [ ] Inisialisasi Git repository
- [ ] **Manajemen Dependensi:**
  - [ ] Tambahkan dependensi utama ke `pubspec.yaml`  
        (flutter, provider/riverpod, freezed, drift/hive/isar, go_router, logger, dll)
- [ ] **Struktur Proyek:**
  - [ ] Buat struktur direktori sesuai Clean Architecture (`app`, `core`, `features`, `shared`)
- [ ] **Konfigurasi Database:**
  - [ ] Buat file definisi database (`app_database.dart`)
  - [ ] Definisikan skema tabel `items` dan `transactions`
  - [ ] Jalankan *build runner* untuk generate kode otomatis
- [ ] **Konfigurasi Dasar Aplikasi:**
  - [ ] Siapkan `main.dart` dengan Provider/Scope
  - [ ] Konfigurasi `GoRouter` dengan rute placeholder  
        (Dashboard, Barang, Transaksi)
  - [ ] Buat file tema dasar (AppTheme) untuk light & dark mode

---

#### Sprint 1: Manajemen Barang Dasar (Minggu 3-4)  
*Tujuan: Mengimplementasikan fitur CRUD barang.*

- [ ] **Entitas & Use Case:**
  - [ ] Buat entity `Item`
  - [ ] Buat use case untuk tambah, edit, hapus barang
- [ ] **Repository & Data Source:**
  - [ ] Implementasi repository barang
  - [ ] Implementasi data source lokal
- [ ] **UI & State Management:**
  - [ ] Halaman daftar barang
  - [ ] Form tambah/edit barang
  - [ ] Aksi hapus barang dengan konfirmasi
- [ ] **Fitur Tambahan:**
  - [ ] Upload/ambil gambar barang
  - [ ] Validasi input sederhana

---

#### Sprint 2: Transaksi Masuk & Keluar (Minggu 5-6)  
*Tujuan: Menangani pencatatan barang masuk & keluar.*

- [ ] **Entitas & Use Case:**
  - [ ] Buat entity `Transaction`
  - [ ] Buat use case tambah transaksi masuk & keluar
- [ ] **Repository & Data Source:**
  - [ ] Implementasi repository transaksi
  - [ ] Sinkronisasi kuantitas barang otomatis setelah transaksi
- [ ] **UI & State Management:**
  - [ ] Halaman tambah transaksi masuk
  - [ ] Halaman tambah transaksi keluar
  - [ ] Integrasi dengan detail barang

---

#### Sprint 3: Pelaporan & Riwayat (Minggu 7-8)  
*Tujuan: Memberikan visibilitas stok & riwayat transaksi.*

- [ ] **Ringkasan Stok:**
  - [ ] Halaman ringkasan stok
- [ ] **Riwayat Transaksi:**
  - [ ] Halaman riwayat transaksi (tanggal, barang, tipe, qty)
  - [ ] Filter transaksi berdasarkan tipe
  - [ ] Filter transaksi berdasarkan rentang tanggal
- [ ] **UI Enhancement:**
  - [ ] Pencarian barang
  - [ ] Sorting daftar barang

---

#### Sprint 4: Ekspor & Impor Data (Minggu 9-10)  
*Tujuan: Memungkinkan pengguna mencadangkan & memulihkan data.*

- [ ] **Ekspor Data:**
  - [ ] Ekspor barang & transaksi ke CSV
  - [ ] Ekspor ke Excel (opsional)
- [ ] **Impor Data:**
  - [ ] Impor barang dari CSV
  - [ ] Validasi format data saat impor
- [ ] **Integrasi Sharing:**
  - [ ] Gunakan share_plus untuk membagikan file ekspor

---

#### Sprint 5: Peningkatan UX & Testing (Minggu 11-12)  
*Tujuan: Menyelesaikan polish UI/UX, testing, dan stabilisasi.*

- [ ] **UI/UX:**
  - [ ] Desain akhir dashboard
  - [ ] Feedback visual (snackbar, toast, loading indicator)
  - [ ] Ikonografi & tema warna konsisten
- [ ] **Pengaturan:**
  - [ ] Menu pengaturan sederhana (reset data, tentang aplikasi)
- [ ] **Testing:**
  - [ ] Unit test use cases
  - [ ] Widget test untuk UI
  - [ ] UAT (User Acceptance Testing)
- [ ] **Stabilisasi:**
  - [ ] Fix bug
  - [ ] Review performa (responsif & ringan)

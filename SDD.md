
# Software Design Document (SDD) — Inventarisku

**Versi:** 1.0  
**Tanggal:** 17 September 2025  
**Penulis:** [Azhar Maulana Ferdiansyah /M. Gunawan Adi Winangun]  

---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen ini menjelaskan desain teknis aplikasi **Inventarisku**.  
Tujuannya adalah untuk memberikan panduan detail kepada tim pengembang mengenai struktur arsitektur, komponen, database, serta strategi error handling yang akan digunakan dalam implementasi.

### 1.2 Ruang Lingkup
SDD ini mencakup:
- Arsitektur sistem berbasis **Layered Architecture** dengan integrasi layanan cloud dan tugas latar belakang.
- Desain komponen rinci per lapisan (Presentation, Business Logic, Data Access).
- Skema database (SQLite), aturan integritas, strategi migrasi.
- Penanganan error.
- Struktur proyek Flutter yang diperbarui.
- Diagram arsitektur untuk visualisasi.

---

## 2. Desain Arsitektur Sistem

### 2.1 Tinjauan Arsitektur
Inventarisku dibangun menggunakan pola **Layered Architecture** dengan tiga lapisan utama, ditambah integrasi dengan layanan cloud (Firebase Storage) untuk fitur premium dan penjadwalan tugas latar belakang (Workmanager) untuk backup otomatis:
1.  **Presentation Layer** → Menyediakan antarmuka pengguna (UI), menangani input pengguna, dan mengelola state.
2.  **Business Logic Layer (Service Layer)** → Berisi logika bisnis aplikasi, validasi, dan koordinasi antar data model.
3.  **Data Access Layer** → Bertanggung jawab untuk mengakses dan mengelola data, baik dari database lokal (SQLite) maupun sumber data eksternal (Firebase Storage).

### 2.2 Diagram Arsitektur (High Level)

```bash
+-------------------------+
|  Antarmuka Pengguna     |
| (Pages, Widgets, State) |
+-------------------------+
            | ^
            v |
+-------------------------+
| Business Logic Layer    |
|       (Services)        |
+-------------------------+
            | ^
            v |
+-------------------------+
|   Data Access Layer     |
| (Repositories, DAOs)    |
+-------------------------+
            | ^
            v |
+-------------------------+   +-------------------------+
|   Data Sources          |   |   Cloud Services        |
| (SQLite, Local Files)   |---| (Firebase Storage)      |
+-------------------------+   +-------------------------+
            ^ |
            | v
            +-------------------------+
            |   Background Tasks      |
            | (Workmanager, Notifikasi)|
            +-------------------------+
```

### 2.3 Deskripsi Lapisan

#### Presentation Layer
*   Terdiri dari UI Flutter (pages, widgets).
*   State management menggunakan Provider atau Riverpod untuk memisahkan logika tampilan dari logika bisnis.
*   Meneruskan event dari pengguna ke Business Logic Layer.
*   Menampilkan data yang diterima dari Business Logic Layer.

#### Business Logic Layer (Service Layer)
*   Berisi kelas-kelas *service* yang mengimplementasikan semua logika bisnis.
*   Mengatur alur kerja aplikasi dan validasi data.
*   Memanggil metode di Data Access Layer untuk mengambil atau menyimpan data.
*   Tidak bergantung pada framework UI (Flutter).

#### Data Access Layer
*   Implementasi dari pola Repository dan Data Access Object (DAO).
*   Menyediakan API sederhana untuk Business Logic Layer dalam mengakses data.
*   Menyembunyikan detail implementasi sumber data (misalnya, apakah data berasal dari SQLite, file, atau Firebase Storage).
*   Berisi implementasi SQLite (sqflite) dan kelas Repository.

---

## 3. Desain Komponen Rinci

### 3.1 Presentation Layer

**Halaman (Pages):**
*   `DashboardPage` → Navigasi ke fitur-fitur inti, menampilkan ringkasan stok dan grafik.
*   `ItemListPage`, `ItemDetailPage`, `ItemFormPage` → Untuk manajemen barang, termasuk input batas restock.
*   `TransactionListPage`, `TransactionFormPage` → Untuk manajemen transaksi.
*   `ReportPage` → Untuk melihat laporan dan grafik stok.
*   `ActivityLogPage` → Menampilkan riwayat aktivitas pengguna.
*   `SettingsPage` → Untuk pengaturan aplikasi, termasuk opsi backup/restore dan notifikasi.

**Komponen (Widgets):**
*   Widget yang dapat digunakan kembali seperti `CustomButton`, `StyledListTile`, `ConfirmationDialog`.
*   Provider/Riverpod untuk mengelola state dari setiap fitur.
*   Widget khusus untuk menampilkan grafik (menggunakan `fl_chart`).

### 3.2 Business Logic Layer (Services)

**Services:**
*   `ItemService` → Mengandung logika bisnis untuk manajemen item (tambah, ubah, hapus, cari item, update stok, set batas restock).
*   `TransactionService` → Mengandung logika untuk membuat transaksi baru dan memperbarui stok item.
*   `CategoryService` → Mengandung logika untuk manajemen kategori.
*   `ReportService` → Menghasilkan data untuk laporan dan grafik stok.
*   `ActivityLogService` → Mengelola pencatatan dan pengambilan riwayat aktivitas pengguna.
*   `NotificationService` → Mengelola notifikasi restock dan notifikasi lokal lainnya.
*   `BackupService` → Mengelola proses backup dan restore data ke/dari cloud (Firebase Storage).
*   `MonetizationService` → Mengelola logika terkait iklan dan pembelian dalam aplikasi (premium unlock).

### 3.3 Data Access Layer

**Repositories:**
*   `ItemRepository` → Implementasi CRUD untuk data item, berinteraksi dengan `ItemDao`.
*   `TransactionRepository` → Implementasi untuk menyimpan data transaksi, berinteraksi dengan `TransactionDao`.
*   `CategoryRepository` → Implementasi CRUD untuk data kategori, berinteraksi dengan `CategoryDao`.
*   `ActivityLogRepository` → Implementasi untuk menyimpan dan mengambil riwayat aktivitas, berinteraksi dengan `ActivityLogDao`.

**Data Access Objects (DAO - sqflite):**
*   `ItemDao` → Menyediakan metode untuk operasi database pada tabel `items`.
*   `TransactionDao` → Menyediakan metode untuk operasi database pada tabel `transactions` dan `transaction_lines`.
*   `CategoryDao` → Menyediakan metode untuk operasi database pada tabel `categories`.
*   `ActivityLogDao` → Menyediakan metode untuk operasi database pada tabel `activity_logs`.

### 3.4 Model

*   **Item** → `id, name, description, qty, unit, price, imagePath, categoryId, minQty`.
*   **Transaction** → `id, type (IN/OUT), date, partner, note, lines[]`.
*   **TransactionLine** → `id, transactionId, itemId, qty, price, subtotal`.
*   **Category** → `id, name, parentId`.
*   **ActivityLog** → `id, timestamp, description, itemId, type`.

---

## 4. Desain Data (Database)

### Implementasi

Database menggunakan **SQLite (sqflite)**.

### Skema Utama

* **items** → menyimpan data barang.
* **categories** → mengelompokkan barang.
* **transactions** → menyimpan transaksi masuk/keluar.
* **transaction_lines** → detail barang per transaksi.
* **stock_movements** → log perubahan stok.
* **activity_logs** → menyimpan riwayat aktivitas pengguna.

### Relasi

* 1 kategori → banyak item.
* 1 transaksi → banyak transaction\_lines.
* 1 item → banyak transaction\_lines.

### Aturan Integritas

* Foreign key aktif.
* Cascade delete untuk konsistensi data.
* Unique constraint pada kode barang (opsional).

### Migrasi

* Drift migration: setiap perubahan struktur dicatat.
* Contoh: tambah kolom `min_qty` di tabel items → `ALTER TABLE`.

---

## 5. Strategi Penanganan Error (Error Handling)

### Alur
1.  **Data Access Layer** menangkap error spesifik (misalnya, `SQLiteException` dari Drift, error jaringan).
2.  Error ini kemudian "dibungkus" atau diubah menjadi exception yang lebih umum dan relevan dengan aplikasi, seperti `DataAccessException` atau `RecordNotFoundException`.
3.  **Business Logic Layer** menangani exception dari Data Access Layer. Di sini, logika penanganan error seperti *retry* atau *fallback* dapat diimplementasikan. Jika perlu, exception dapat dilempar kembali ke Presentation Layer.
4.  **Presentation Layer** menangkap exception dari Business Logic Layer dan menampilkan pesan yang mudah dipahami kepada pengguna (misalnya, melalui Snackbar, Dialog, atau halaman error).

### Tipe Exception
*   `DataAccessException`: Gagal mengakses atau memodifikasi data (misalnya, query gagal, koneksi database terputus).
*   `ValidationException`: Input dari pengguna tidak valid (misalnya, kuantitas negatif, format email salah).
*   `BusinessRuleException`: Pelanggaran aturan bisnis (misalnya, mencoba menghapus item yang masih terkait dengan transaksi).
*   `UnexpectedException`: Untuk error yang tidak terduga.

### Penanganan
*   Gunakan blok `try-catch` di setiap lapisan untuk menangani exception dari lapisan di bawahnya.
*   Tampilkan pesan error yang jelas dan informatif di UI.

---

## 6. Struktur Proyek (Direktori)

```bash
.
├── lib/
│   ├── main.dart
│   ├── app/                     # Konfigurasi aplikasi, tema, routing
│   │   ├── app_router.dart
│   │   └── app_theme.dart
│   ├── core/                    # Utilitas, konstanta, dan kelas dasar
│   │   ├── errors/              # Exceptions kustom
│   │   ├── constants/
│   │   ├── utils/
│   │   └── services/            # Layanan inti seperti notifikasi, backup, monetisasi
│   ├── data/
│   │   ├── daos/                # Data Access Objects (sqflite)
│   │   ├── models/              # Model data untuk database
│   │   └── repositories/        # Implementasi Repository
│   ├── domain/
│   │   ├── models/              # Model utama aplikasi (Entities)
│   │   └── services/            # Kelas-kelas Service (Logika Bisnis)
│   ├── presentation/
│   │   ├── pages/               # Halaman-halaman UI
│   │   ├── widgets/             # Widget yang dapat digunakan kembali
│   │   └── providers/           # State management (Provider/Riverpod)
│   ├── features/                # Modul per fitur
│   │   ├── item_management/
│   │   ├── transaction_history/
│   │   ├── reports/
│   │   ├── activity_log/
│   │   ├── notifications/
│   │   ├── backup/
│   │   └── charts/
│   └── shared/                  # Widget atau kode yang digunakan di banyak tempat
├── pubspec.yaml
├── README.md
```

---



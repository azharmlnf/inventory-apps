
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
- Arsitektur sistem berbasis **Layered Architecture**.
- Desain komponen rinci per lapisan (Presentation, Business Logic, Data Access).
- Skema database, aturan integritas, strategi migrasi.
- Penanganan error.
- Struktur proyek Flutter.
- Diagram arsitektur untuk visualisasi.

---

## 2. Desain Arsitektur Sistem

### 2.1 Tinjauan Arsitektur
Inventarisku dibangun menggunakan pola **Layered Architecture** dengan tiga lapisan utama:
1.  **Presentation Layer** → Menyediakan antarmuka pengguna (UI), menangani input pengguna, dan mengelola state.
2.  **Business Logic Layer (Service Layer)** → Berisi logika bisnis aplikasi, validasi, dan koordinasi antar data model.
3.  **Data Access Layer** → Bertanggung jawab untuk mengakses dan mengelola data, baik dari database lokal (SQLite/Drift) maupun sumber data eksternal.

### 2.2 Diagram Arsitektur (High Level)

```bash
+-------------------------+
|  Antarmuka Pengguna     |
| (Pages, Widgets, State) |
+-------------------------+
            |
            v
+-------------------------+
| Business Logic Layer    |
|       (Services)        |
+-------------------------+
            |
            v
+-------------------------+
|   Data Access Layer     |
| (Repositories, DAOs)    |
+-------------------------+
            |
            v
+-------------------------+
|   Data Sources          |
| (Drift, SQLite, API)    |
+-------------------------+
```

### 2.3 Deskripsi Lapisan

#### Presentation Layer
*   Terdiri dari UI Flutter (pages, widgets).
*   State management menggunakan Provider/Riverpod untuk memisahkan logika tampilan dari logika bisnis.
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
*   Menyembunyikan detail implementasi sumber data (misalnya, apakah data berasal dari SQLite, file, atau jaringan).
*   Berisi implementasi Drift (DAO) dan kelas Repository.

---

## 3. Desain Komponen Rinci

### 3.1 Presentation Layer

**Halaman (Pages):**
*   `DashboardPage` → Navigasi ke fitur-fitur inti.
*   `ItemListPage`, `ItemDetailPage`, `ItemFormPage` → Untuk manajemen barang.
*   `TransactionListPage`, `TransactionFormPage` → Untuk manajemen transaksi.
*   `ReportPage` → Untuk melihat laporan.
*   `SettingsPage` → Untuk pengaturan aplikasi.

**Komponen (Widgets):**
*   Widget yang dapat digunakan kembali seperti `CustomButton`, `StyledListTile`, `ConfirmationDialog`.
*   Provider/Notifier untuk mengelola state dari setiap fitur.

### 3.2 Business Logic Layer (Services)

**Services:**
*   `ItemService` → Mengandung logika bisnis untuk manajemen item (tambah, ubah, hapus, cari item).
*   `TransactionService` → Mengandung logika untuk membuat transaksi baru dan memperbarui stok item.
*   `CategoryService` → Mengandung logika untuk manajemen kategori.
*   `ReportService` → Menghasilkan data untuk laporan.

### 3.3 Data Access Layer

**Repositories:**
*   `ItemRepository` → Implementasi CRUD untuk data item, berinteraksi dengan `ItemDao`.
*   `TransactionRepository` → Implementasi untuk menyimpan data transaksi, berinteraksi dengan `TransactionDao`.
*   `CategoryRepository` → Implementasi CRUD untuk data kategori, berinteraksi dengan `CategoryDao`.

**Data Access Objects (DAO - Drift):**
*   `ItemDao` → Menyediakan metode untuk operasi database pada tabel `items`.
*   `TransactionDao` → Menyediakan metode untuk operasi database pada tabel `transactions` dan `transaction_lines`.
*   `CategoryDao` → Menyediakan metode untuk operasi database pada tabel `categories`.

### 3.4 Model

*   **Item** → `id, name, description, qty, unit, price, imagePath, categoryId`.
*   **Transaction** → `id, type (IN/OUT), date, partner, note, lines[]`.
*   **TransactionLine** → `id, transactionId, itemId, qty, price, subtotal`.
*   **Category** → `id, name, parentId`.

---

## 4. Desain Data (Database)

### Implementasi

Database menggunakan **Drift (SQLite)**.

### Skema Utama

* **items** → menyimpan data barang.
* **categories** → mengelompokkan barang.
* **transactions** → menyimpan transaksi masuk/keluar.
* **transaction\_lines** → detail barang per transaksi.
* **stock\_movements** → log perubahan stok.

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
│   │   └── utils/
│   ├── data/
│   │   ├── daos/                # Data Access Objects (Drift)
│   │   ├── models/              # Model data untuk database (jika berbeda dari domain model)
│   │   └── repositories/        # Implementasi Repository
│   ├── domain/
│   │   ├── models/              # Model utama aplikasi (Entities)
│   │   └── services/            # Kelas-kelas Service (Logika Bisnis)
│   ├── presentation/
│   │   ├── pages/               # Halaman-halaman UI
│   │   ├── widgets/             # Widget yang dapat digunakan kembali
│   │   └── providers/           # State management (Providers/Notifiers)
│   └── shared/                  # Widget atau kode yang digunakan di banyak tempat
├── pubspec.yaml
├── README.md
```

---




# Software Design Document (SDD) — Inventarisku

**Versi:** 1.0  
**Tanggal:** 17 September 2025  
**Penulis:** [Nama Anda/Kolaborasi AI]  

---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen ini menjelaskan desain teknis aplikasi **Inventarisku**.  
Tujuannya adalah untuk memberikan panduan detail kepada tim pengembang mengenai struktur arsitektur, komponen, database, serta strategi error handling yang akan digunakan dalam implementasi.

### 1.2 Ruang Lingkup
SDD ini mencakup:
- Arsitektur sistem berbasis **Clean Architecture**.  
- Desain komponen rinci per lapisan (Presentation, Domain, Data).  
- Skema database, aturan integritas, strategi migrasi.  
- Penanganan error.  
- Struktur proyek Flutter.  
- Diagram arsitektur untuk visualisasi.  

---

## 2. Desain Arsitektur Sistem

### 2.1 Tinjauan Arsitektur
Inventarisku dibangun menggunakan pola **Clean Architecture** dengan tiga lapisan utama:
1. **Presentation Layer** → Menyediakan antarmuka pengguna, menangani event, dan menampilkan state.  
2. **Domain Layer** → Berisi entitas, use case, dan kontrak repository (logika bisnis murni).  
3. **Data Layer** → Menyediakan implementasi repository, data source (Drift/SQLite), serta mapping DTO ↔ Entity.  

### 2.2 Diagram Arsitektur (High Level)



```bash
+-------------------------+
|  Antarmuka Pengguna     |
|        (UI)             |
+-------------------------+
            |
            v
+-------------------------+
|   State Management      |
|      (Riverpod)         |
+-------------------------+
            |
            v
+-------------------------+
|   Use Cases (Domain)    |
+-------------------------+
            |
            v
+-------------------------+
| Repository Interfaces   |
|       (Domain)          |
+-------------------------+
            ^
            | (Implementasi)
            |
+-------------------------+
|   Repositories (Data)   |
+-------------------------+
            |
            v
+-------------------------+
| Local Data Source       |
|       (Drift)           |
+-------------------------+
            |
            v
+-------------------------+
|   SQLite Database       |
+-------------------------+

```
### 2.3 Deskripsi Lapisan

#### Presentation Layer

* UI Flutter (pages, widgets).
* State management menggunakan Provider/ChangeNotifier.
* Routing dengan AppRouter.

#### Domain Layer

* Entities immutable (menggunakan Freezed).
* Use cases mengatur logika bisnis.
* Kontrak repository sebagai interface ke Data Layer.

#### Data Layer

* Implementasi repository.
* Data source berbasis Drift (SQLite wrapper).
* Mapper untuk konversi Entity ↔ DTO ↔ Database model.

---

## 3. Desain Komponen Rinci

### 3.1 Presentation Layer

**Halaman utama:**

* DashboardPage → navigasi ke fitur inti.
* ItemListPage, ItemDetailPage, ItemFormPage.
* TransactionListPage, TransactionFormPage.
* ReportPage.
* SettingsPage.

**Komponen lain:**

* Widgets reusable (buttons, list tiles, dialog).
* Provider untuk state tiap fitur.

### 3.2 Domain Layer

#### Entities (Freezed)

* **Item** → id, name, description, qty, unit, price, imagePath, categoryId.
* **Transaction** → id, type (IN/OUT), date, partner, note, lines\[].
* **TransactionLine** → id, transactionId, itemId, qty, price, subtotal.
* **Category** → id, name, parentId.

#### Abstract Repositories (Contracts)

* `ItemRepository`
* `TransactionRepository`
* `CategoryRepository`

### 3.3 Data Layer

#### Repository Implementations

* `ItemRepositoryImpl` → implementasi CRUD untuk item.
* `TransactionRepositoryImpl` → simpan transaksi + update qty item.
* `CategoryRepositoryImpl` → manajemen kategori.

#### Data Sources (Drift)

* `ItemDao` → operasi pada tabel `items`.
* `TransactionDao` → operasi pada tabel `transactions`.
* `TransactionLineDao` → operasi pada tabel `transaction_lines`.
* `CategoryDao` → operasi pada tabel `categories`.

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

1. Data Layer menangkap error (database, parsing, file).
2. Error dipetakan ke domain-level `Failure`.
3. Presentation Layer menampilkan pesan user-friendly.

### Tipe Error

* **DatabaseFailure** → gagal query, constraint violation.
* **ValidationFailure** → input tidak valid (qty < 0).
* **FileFailure** → gagal impor/ekspor file.
* **UnexpectedFailure** → error umum.

### Penanganan

* Gunakan `try-catch` di Data Layer.
* Return `Either<Failure, Success>` di Use Case.
* Snackbar/alert di UI untuk user feedback.

---

## 6. Struktur Proyek (Direktori)

```bash
.
├── lib/
│   ├── main.dart
│   ├── app/                     # Konfigurasi aplikasi, tema, routing
│   │   ├── app_router.dart
│   │   └── app_theme.dart
│   ├── core/                    # Utils, constants, failures
│   │   ├── errors/
│   │   ├── constants/
│   │   └── utils/
│   ├── features/
│   │   ├── item_management/
│   │   │   ├── data/            # DTO, repos, datasources
│   │   │   ├── domain/          # Entities, usecases, contracts
│   │   │   └── presentation/    # UI (pages, widgets, providers)
│   │   ├── transaction/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── category/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── reports/
│   └── shared/                  # Widgets reusable
├── pubspec.yaml
├── README.md
```

---



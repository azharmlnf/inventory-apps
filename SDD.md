
# Software Design Document (SDD) — Inventarisku

**Versi:** 2.0  
**Tanggal:** 30 Oktober 2025  
**Penulis:** [Azhar Maulana Ferdiansyah /M. Gunawan Adi Winangun]

---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen ini menjelaskan desain teknis aplikasi **Inventarisku** versi 2.0, yang beralih ke arsitektur online menggunakan **Appwrite** sebagai backend. Tujuannya adalah memandu implementasi teknis dari sistem yang tersinkronisasi secara cloud.

### 1.2 Ruang Lingkup
SDD ini mencakup:
- Arsitektur sistem berbasis **Layered Architecture** dengan **Appwrite** sebagai pusat.
- Desain komponen rinci, termasuk autentikasi dan operasi data online.
- Skema koleksi database di Appwrite.
- Struktur proyek Flutter yang telah disesuaikan.

---

## 2. Desain Arsitektur Sistem

### 2.1 Tinjauan Arsitektur
Inventarisku versi 2.0 mengadopsi pola **Layered Architecture** yang terhubung ke **Appwrite** sebagai Backend as a Service (BaaS). Arsitektur lokal-sentris (SQLite) sepenuhnya digantikan.
1.  **Presentation Layer**: Mengelola UI, state (termasuk status autentikasi), dan input pengguna.
2.  **Business Logic Layer (Service Layer)**: Berisi logika bisnis yang kini juga menangani logika terkait sesi pengguna.
3.  **Data Access Layer**: Bertanggung jawab untuk berkomunikasi dengan Appwrite SDK untuk semua kebutuhan data.
4.  **Appwrite Backend**: Menyediakan layanan Autentikasi, Database (koleksi dokumen), dan Storage (untuk file gambar).

### 2.2 Diagram Arsitektur (High Level)

```mermaid
graph TD
    subgraph Flutter App
        A[Presentation Layer <br> (UI, State, Login Page)]
        B[Business Logic Layer <br> (Services)]
        C[Data Access Layer <br> (Repositories)]
    end

    subgraph " "
        D{Appwrite SDK}
    end

    subgraph Appwrite Cloud
        E[Authentication <br> (Google OAuth)]
        F[Database <br> (Collections)]
        G[Storage <br> (File Buckets)]
    end

    A -- User Events --> B
    B -- Calls Methods --> C
    C -- Uses --> D
    D -- HTTPS Requests --> E
    D -- HTTPS Requests --> F
    D -- HTTPS Requests --> G
    
    B -- Updates State --> A
```

### 2.3 Deskripsi Lapisan

#### Presentation Layer
*   Terdiri dari UI Flutter, termasuk halaman baru `LoginPage` dan `SplashScreen` (untuk memeriksa status login).
*   State management (Provider/Riverpod) dipakai untuk mengelola state global seperti status autentikasi pengguna dan data yang diambil dari server.
*   Halaman `SettingsPage` diubah untuk menampilkan detail pengguna dan tombol **Logout**.

#### Business Logic Layer (Service Layer)
*   Services (misal, `ItemService`) kini beroperasi berdasarkan `userId` yang sedang login.
*   Menambahkan `AuthService` yang bertanggung jawab atas logika login, logout, dan manajemen sesi pengguna.

#### Data Access Layer
*   DAO berbasis SQLite digantikan oleh **Repositories** yang menggunakan **Appwrite SDK**.
*   Menyembunyikan detail implementasi Appwrite, seperti nama koleksi dan penanganan ID dokumen. Contoh: `ItemRepository` akan memanggil `databases.createDocument(...)` dari Appwrite SDK.

---

## 3. Desain Komponen Rinci

### 3.1 Presentation Layer

**Halaman (Pages) Baru/Diubah:**
*   `SplashScreenPage`: Halaman awal untuk memeriksa apakah ada sesi login yang aktif. Jika ya, arahkan ke dashboard. Jika tidak, arahkan ke halaman login.
*   `LoginPage`: Menampilkan tombol "Login dengan Google".
*   `SettingsPage`: Menampilkan informasi pengguna (nama/email dari akun Google) dan tombol Logout. Menghilangkan semua UI terkait backup/restore.

### 3.2 Business Logic Layer (Services)

**Services Baru/Diubah:**
*   `AuthService`: Mengelola alur kerja autentikasi. Memanggil `AuthRepository` untuk berinteraksi dengan Appwrite.
*   `ItemService`, `TransactionService`, dll.: Setiap metode yang mengakses data kini memerlukan `userId` atau mengambilnya dari state global untuk memfilter data di Appwrite.
*   `BackupService`: **Dihapus**.

### 3.3 Data Access Layer

**Repositories Baru/Diubah:**
*   `AuthRepository`: Implementasi untuk login/logout menggunakan Appwrite SDK (`account.createOAuth2Session`, `account.deleteSession`).
*   `ItemRepository`: Implementasi CRUD ke koleksi `items` di Appwrite, menggunakan filter (`Query.equal('userId', ...)`) untuk memastikan isolasi data.
*   *(Semua DAO dan repository berbasis sqflite **dihapus**)*.

---

## 4. Desain Data (Database Appwrite)

### Implementasi
Database menggunakan **Appwrite Databases**. Data diorganisir dalam *collections* (mirip tabel) dan *documents* (mirip baris).

### Skema Koleksi
Sesuai dengan ERD yang diperbarui, koleksi utama adalah `users`, `stores`, `items`, `categories`, `transactions`, dan `activity_logs`. Setiap koleksi (kecuali `users`) akan memiliki atribut `userId` dan/atau `storeId` untuk relasi dan keamanan.

### Aturan Akses (Permissions)
*   Setiap dokumen yang dibuat akan diberi *permission* pada level dokumen.
*   Contoh: Dokumen di koleksi `items` akan memiliki permission `read("user:USER_ID")` dan `write("user:USER_ID")`. Ini memastikan hanya pengguna yang membuat data yang dapat membaca dan memodifikasinya.

---

## 5. Strategi Penanganan Error (Error Handling)

### Alur
1.  **Data Access Layer** menangkap `AppwriteException` dari Appwrite SDK.
2.  Exception ini dapat dianalisis berdasarkan `code` dan `type` untuk memberikan pesan error yang lebih spesifik (misalnya, 'Koneksi Gagal', 'Tidak Punya Akses', 'Dokumen Tidak Ditemukan').
3.  Error ini dibungkus menjadi exception domain (misal, `NetworkException`, `UnauthorizedException`) dan dilempar ke lapisan atas.
4.  **Presentation Layer** menampilkan pesan yang sesuai kepada pengguna (misalnya, Snackbar "Tidak ada koneksi internet").

---

## 6. Struktur Proyek (Direktori)

```bash
.
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app_router.dart
│   │   └── app_theme.dart
│   ├── core/
│   │   ├── config/              # Konfigurasi Appwrite (endpoint, project_id)
│   │   ├── services/            # Klien Appwrite terpusat
│   │   └── errors/              # Exceptions kustom
│   ├── data/
│   │   ├── models/              # Model data (konversi dari/ke JSON)
│   │   └── repositories/        # Implementasi Repository Appwrite
│   ├── domain/
│   │   ├── models/              # Entitas domain
│   │   └── services/            # Logika Bisnis
│   ├── presentation/
│   │   ├── pages/
│   │   ├── widgets/
│   │   └── providers/           # State management
│   ├── features/                # Modul per fitur
│   │   ├── auth/                # Halaman & state untuk Login/Logout
│   │   ├── item_management/
│   │   └── ...
│   └── shared/
├── pubspec.yaml
```
---



### Checklist Timeline Pengembangan "Stoklog" v2.1 (7 Minggu)

#### Minggu 1: Setup Proyek & Autentikasi
*   **Setup Backend & Frontend:**
    *   [x] Konfigurasi proyek baru di Appwrite (Auth, Database, Storage).
    *   [x] Inisialisasi proyek Flutter, konfigurasi Git, dan struktur folder.
    *   [x] Tambahkan dependensi utama: `flutter_riverpod`, `appwrite`, `google_mobile_ads`.
*   **Implementasi Autentikasi (Email/Password):**
    *   [x] Buat `AuthRepository` dan `AuthService`.
    *   [x] Buat `LoginPage` dengan form input email dan password untuk login dan registrasi.
    *   [x] Implementasikan alur registrasi pengguna dengan email dan password Appwrite (`account.create()`).
    *   [x] Implementasikan alur login pengguna dengan email dan password Appwrite (`account.createEmailSession()`).
    *   [x] Implementasikan alur Logout (`account.deleteSession()`).
    *   [x] Buat `SplashScreen` untuk mengarahkan pengguna berdasarkan status login.
    *   [x] Perbarui UI prototipe (`ui ux`) untuk menyertakan halaman login/registrasi manual.
    *   [x] **Perbaikan**: Notifikasi error login, Show/Hide Password, dan label input yang lebih jelas.

#### Minggu 2: Implementasi CRUD Dasar (Online)
*   **Setup Appwrite Collections:**
    *   [x] Definisikan dan buat koleksi di Appwrite: `categories`, `transactions`, `activity_logs` dengan atribut dan permission yang sesuai.
*   **CRUD Kategori (Online):**
    *   [x] Buat `CategoryRepository` yang terhubung ke Appwrite.
    *   [x] Implementasikan service dan UI (Widget) untuk operasi CRUD `Category` yang terikat pada `userId`.
    *   [x] Integrasikan state management (Riverpod) untuk data kategori dari Appwrite.
    *   [x] **Perbaikan**: Refaktorisasi pola `.family` untuk data user-specific.

#### Minggu 3: Implementasi CRUD Barang & Stok (Online)
*   **Setup Appwrite Collection:**
    *   [x] Definisikan dan buat koleksi `items` di Appwrite.
*   **CRUD Barang (Online):**
    *   [x] Buat `ItemRepository` yang terhubung ke Appwrite.
    *   [x] Implementasikan UI (`ItemListPage`, `ItemFormPage`) untuk operasi CRUD `Item`.
    *   [x] Pastikan kuantitas barang di Appwrite diperbarui secara otomatis setelah transaksi.
    *   [x] Integrasikan state management (Riverpod) untuk data `Item`.
    *   [x] **Perbaikan**: Refaktorisasi pola `.family` untuk data user-specific dan label form yang lebih jelas.

#### Minggu 4: Fitur Notifikasi & Pelaporan Dasar
*   **Pengingat Restock:**
    *   [x] Implementasikan logika di sisi klien untuk mendeteksi stok rendah dari data yang diambil dari Appwrite.
    *   [x] Integrasi `flutter_local_notifications` untuk menampilkan notifikasi stok rendah.
*   **Pelaporan Sederhana:**
    *   [x] Buat `ReportPage` untuk menampilkan ringkasan stok.
    *   [x] Implementasikan query ke Appwrite untuk memfilter riwayat transaksi.
    *   [x] **Perbaikan**: Refaktorisasi pola `.family` untuk data user-specific dan penanganan tampilan data yang lebih baik.

#### Minggu 5: Fitur Grafik Stok & Ekspor Data
*   **Grafik Stok Barang:**
    *   [x] Integrasi `fl_chart` library.
    *   [x] Implementasikan logika untuk mengambil dan mengagregasi data stok per kategori dari Appwrite.
    *   [x] Buat widget grafik untuk menampilkan visualisasi stok.
    *   [x] **Perbaikan**: Refaktorisasi pola `.family` untuk data user-specific.
*   **Ekspor Data:**
    *   [x] Implementasikan service untuk mengambil data barang & transaksi dari Appwrite dan mengonversinya ke format CSV.
    *   [x] Integrasi `share_plus` untuk membagikan file ekspor.
    *   [x] **Perbaikan**: Refaktorisasi pola `.family` untuk data user-specific.

#### Minggu 6: Implementasi Monetisasi via Google Play Billing (Validasi Sisi Klien)

> **Catatan:** Implementasi ini menggunakan model langganan (subscription) sesuai kebijakan Google Play Store. Arsitektur saat ini menggunakan validasi di sisi klien (client-side) untuk kemudahan implementasi. Verifikasi di sisi server bisa ditambahkan di masa depan.

*   **Langkah 1: Konfigurasi di Google Play Console**
    *   [x] **Play Console:** Buat aplikasi Anda di [Google Play Console](https://play.google.com/console).
    *   [x] **Play Console:** Di bawah menu "Monetize", temukan **License testing** dan tambahkan email penguji.
    *   [x] **Play Console:** Di bawah menu "Monetize", buka **Subscriptions** dan buat produk langganan baru.
        *   [x] Beri **Product ID** yang unik (ID yang digunakan: `premium_no_ads`).
        *   [x] Tambahkan **Base Plans** untuk siklus penagihan (ID yang digunakan: `premium-monthly`, `premium-yearly`).
        *   [x] Isi detail produk (nama, deskripsi, harga) dan aktifkan.

*   **Langkah 2: Implementasi Frontend di Aplikasi Flutter**
    *   [x] Tambahkan package `in_app_purchase` ke `pubspec.yaml`.
    *   [x] Buat `InAppPurchaseService` dan `Provider` (Riverpod) untuk mengelola logika IAP (In-App Purchase).
    *   [x] **Inisialisasi:** Layanan IAP diinisialisasi saat aplikasi pertama kali dijalankan untuk memantau status pembelian secara terus-menerus.
    *   [x] **Ambil Produk:** Saat halaman langganan dimuat, aplikasi memanggil `InAppPurchase.instance.queryProductDetails()` dengan Product ID (`premium_no_ads`).
    *   [x] **Tampilkan UI:** Aplikasi menampilkan detail produk (harga, nama) yang diterima dari Play Store, atau menampilkan halaman status jika pengguna sudah premium.
    *   [x] **Mulai Pembelian:** Saat tombol "Beli" ditekan, aplikasi memanggil `InAppPurchase.instance.buyNonConsumable()` dengan `PurchaseParam` yang sesuai.
    *   [x] **Proses Pembelian:** Di dalam listener `purchaseStream`:
        *   [x] Jika status adalah `PurchaseStatus.purchased` atau `PurchaseStatus.restored`:
            *   [x] Panggil `InAppPurchase.instance.completePurchase(updated)` untuk finalisasi transaksi dengan Google.
            *   [x] Perbarui status `isPremium` di `AuthRepository` dan state aplikasi untuk mengaktifkan fitur premium.
            *   [x] Atasi *race condition* untuk memastikan status premium tersinkronisasi dengan benar saat berganti akun di perangkat yang sama.
        *   [x] Jika statusnya `PurchaseStatus.error`, tampilkan pesan error.
    *   [x] **Restore Purchase:** Sediakan tombol "Pulihkan Pembelian" yang memanggil `InAppPurchase.instance.restorePurchases()`. Alur pemulihan ditangani oleh listener `purchaseStream` yang sama.
    *   [x] **Perbaikan**: Halaman status premium telah diperbarui agar lebih informatif dan estetik.

#### Minggu 7: Testing, Dokumentasi, dan Persiapan Rilis
*   **Testing:**
    *   [ ] Tulis Unit Test untuk services dan repositories (bisa menggunakan mock).
    *   [ ] Tulis Widget Test untuk komponen UI utama, termasuk alur login dan halaman dashboard.
    *   [ ] Lakukan User Acceptance Testing (UAT).
*   **Stabilisasi & Optimasi:**
    *   [x] Perbaikan bug berdasarkan hasil testing. (Semua bug kritis telah diperbaiki: race condition sesi, data basi, circular dependency, navigator error, type cast error).
    *   [x] Optimasi query Appwrite dan responsivitas UI. (Manajemen state dengan Riverpod `.family` secara signifikan meningkatkan reaktivitas dan performa).
*   **Dokumentasi & Rilis:**
    *   [ ] Finalisasi dokumentasi teknis.
    *   [ ] Siapkan aset aplikasi dan konfigurasi untuk rilis di App Store/Play Store.
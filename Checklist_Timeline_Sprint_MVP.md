### Checklist Timeline Pengembangan "Inventarisku" v2.1 (7 Minggu)

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

#### Minggu 2: Implementasi CRUD Dasar (Online)
*   **Setup Appwrite Collections:**
    *   [x] Definisikan dan buat koleksi di Appwrite: `categories`, `transactions`, `activity_logs` dengan atribut dan permission yang sesuai.
*   **CRUD Kategori (Online):**
    *   [x] Buat `CategoryRepository` yang terhubung ke Appwrite.
    *   [x] Implementasikan service dan UI (Widget) untuk operasi CRUD `Category` yang terikat pada `userId`.
    *   [x] Integrasikan state management (Riverpod) untuk data kategori dari Appwrite.
*   **CRUD Transaksi (Online):**
    *   [x] Buat `TransactionRepository` yang terhubung ke Appwrite.
    *   [x] Implementasikan service dan UI (Widget) untuk operasi CRUD `Transaction`, memastikan setiap transaksi terikat pada `userId`.
*   **Riwayat Aktivitas (Online):**
    *   [x] Implementasikan service untuk mencatat `ActivityLog` di Appwrite setiap kali ada aksi penting.

#### Minggu 3: Implementasi CRUD Barang & Stok (Online)
*   **Setup Appwrite Collection:**
    *   [x] Definisikan dan buat koleksi `items` di Appwrite.
*   **CRUD Barang (Online):**
    *   [x] Buat `ItemRepository` yang terhubung ke Appwrite.
    *   [x] Implementasikan UI (`ItemListPage`, `ItemFormPage`) untuk operasi CRUD `Item`.
    *   [x] Pastikan kuantitas barang di Appwrite diperbarui secara otomatis setelah transaksi.
    *   [x] Integrasikan state management (Riverpod) untuk data `Item`.

#### Minggu 4: Fitur Notifikasi & Pelaporan Dasar
*   **Pengingat Restock:**
    *   [x] Implementasikan logika di sisi klien untuk mendeteksi stok rendah dari data yang diambil dari Appwrite.
    *   [x] Integrasi `flutter_local_notifications` untuk menampilkan notifikasi stok rendah.
*   **Pelaporan Sederhana:**
    *   [x] Buat `ReportPage` untuk menampilkan ringkasan stok.
    *   [x] Implementasikan query ke Appwrite untuk memfilter riwayat transaksi.

#### Minggu 5: Fitur Grafik Stok & Ekspor Data
*   **Grafik Stok Barang:**
    *   [x] Integrasi `fl_chart` library.
    *   [x] Implementasikan logika untuk mengambil dan mengagregasi data stok per kategori dari Appwrite.
    *   [x] Buat widget grafik untuk menampilkan visualisasi stok.
*   **Ekspor Data:**
    *   [x] Implementasikan service untuk mengambil data barang & transaksi dari Appwrite dan mengonversinya ke format CSV.
    *   [x] Integrasi `share_plus` untuk membagikan file ekspor.

#### Minggu 6: Implementasi Monetisasi via Google Play Billing

> **Catatan:** Implementasi ini menggantikan metode pembayaran eksternal (seperti Stripe) dan mengikuti kebijakan Google Play Store untuk pembelian item digital. Arsitektur ini menggunakan validasi sisi server (server-side validation) untuk keamanan.

*   **Arsitektur Sistem:**
    1.  **Frontend (Flutter):** Aplikasi menggunakan package `in_app_purchase` untuk mengambil daftar produk dari Google Play Store dan memulai alur pembelian.
    2.  **Google Play:** Menampilkan UI pembayaran standar kepada pengguna dan memproses transaksi.
    3.  **Frontend (Flutter):** Setelah pembayaran berhasil, aplikasi menerima `PurchaseDetails` yang berisi `purchaseToken`.
    4.  **Backend (Appwrite Function):** Aplikasi mengirim `purchaseToken` dan `productId` dari `PurchaseDetails` ke sebuah Appwrite Function baru yang akan kita buat (mis: `verify-google-play-purchase`).
    5.  **Google Play Developer API:** Appwrite Function berkomunikasi dengan Google Play Developer API untuk memverifikasi keaslian dan status `purchaseToken`. Ini adalah langkah keamanan krusial untuk mencegah penipuan.
    6.  **Backend (Appwrite Database):** Setelah token terverifikasi, Appwrite Function akan mengupdate data pengguna di Appwrite (misalnya, `prefs` atau koleksi `profiles`) untuk memberikan status "Premium".
    7.  **Frontend (Flutter):** Aplikasi memanggil `InAppPurchase.instance.completePurchase()` untuk memberitahu Google Play bahwa produk telah diberikan ke pengguna. Ini dilakukan **hanya setelah** backend berhasil memvalidasi dan memberikan status premium.

*   **Langkah 1: Konfigurasi di Google Play Console & Google Cloud Console**
    *   [ ] **Play Console:** Buat aplikasi Anda di [Google Play Console](https://play.google.com/console).
    *   [ ] **Play Console:** Di bawah menu "Monetize", temukan **License testing** dan tambahkan email penguji. Penguji ini dapat membeli item tanpa dikenakan biaya.
    *   [ ] **Play Console:** Di bawah menu "Monetize", buka **In-app products** dan buat produk baru (tipe: "One-time product").
        *   Beri **Product ID** yang unik (mis: `premium_upgrade_v1`). ID ini akan digunakan di kode Flutter.
        *   Isi detail produk (nama, deskripsi, harga) dan aktifkan.
    *   [ ] **Google Cloud Console:** Tautkan proyek Google Cloud Anda dengan akun Play Console (Play Console > Setup > API Access).
    *   [ ] **Google Cloud Console:** Aktifkan **Google Play Developer API**.
    *   [ ] **Google Cloud Console:** Buat **Service Account**. Beri peran "Service Account User". Buat JSON key untuk service account ini dan unduh filenya. Konten dari file JSON ini akan digunakan sebagai *environment variable* di Appwrite Function.

*   **Langkah 2: Backend dengan Appwrite Function (`verify-google-play-purchase`)**
    *   [ ] Buat Appwrite Function baru (Node.js atau Dart).
    *   [ ] Tambahkan *environment variables* di Settings function:
        *   `GOOGLE_SERVICE_ACCOUNT_JSON`: Salin seluruh konten dari file JSON yang diunduh pada langkah sebelumnya.
        *   `APPWRITE_API_KEY`: API Key Appwrite dengan scope `users.read` dan `users.write`.
        *   `APPWRITE_ENDPOINT`, `APPWRITE_PROJECT_ID`.
    *   [ ] Tulis kode function yang:
        *   Menerima `userId`, `purchaseToken`, dan `productId` dari aplikasi Flutter.
        *   Menggunakan library Google API (mis: `googleapis` untuk Node.js) dan kredensial dari `GOOGLE_SERVICE_ACCOUNT_JSON` untuk membuat client API.
        *   Memanggil `androidpublisher.purchases.products.get()` dengan `packageName`, `productId`, dan `purchaseToken`.
        *   Memverifikasi bahwa `purchaseState` adalah `0` (Purchased) dan `consumptionState` adalah `0` (Not yet consumed).
        *   Jika valid, gunakan Appwrite Admin SDK untuk mengupdate Preferences pengguna menjadi `{ "isPremium": true }`.
        *   Mengembalikan status sukses atau gagal ke aplikasi Flutter.

*   **Langkah 3: Frontend di Aplikasi Flutter**
    *   [ ] Tambahkan package `in_app_purchase` ke `pubspec.yaml`.
    *   [ ] Buat sebuah `PurchaseService` atau `Provider` (Riverpod) untuk mengelola logika IAP (In-App Purchase).
    *   [ ] **Inisialisasi:** Dengarkan stream `InAppPurchase.instance.purchaseStream` untuk memantau status pembelian.
    *   [ ] **Ambil Produk:** Saat `PremiumPage` dimuat, panggil `InAppPurchase.instance.queryProductDetails()` dengan Product ID (`premium_upgrade_v1`) yang sudah dibuat.
    *   [ ] **Tampilkan UI:** Tampilkan detail produk (harga, nama) yang diterima dari Play Store.
    *   [ ] **Mulai Pembelian:** Saat tombol "Upgrade" ditekan, panggil `InAppPurchase.instance.buyNonConsumable()` dengan `PurchaseParam` yang sesuai.
    *   [ ] **Proses Pembelian:** Di dalam listener `purchaseStream`:
        *   Jika status `updated.status` adalah `PurchaseStatus.purchased`:
            *   Tampilkan UI loading.
            *   Panggil Appwrite Function `verify-google-play-purchase` dengan membawa `purchaseToken`.
            *   Jika function merespons sukses:
                *   Panggil `InAppPurchase.instance.completePurchase(updated)`.
                *   Refresh state aplikasi untuk mengaktifkan fitur premium.
            *   Jika gagal, tampilkan pesan error.
        *   Jika statusnya `PurchaseStatus.error`, tampilkan error.
        *   Jika statusnya `PurchaseStatus.restored`, lakukan proses validasi yang sama seperti `purchased`.
    *   [ ] **Restore Purchase:** Sediakan tombol "Restore Purchases" yang memanggil `InAppPurchase.instance.restorePurchases()` untuk pengguna yang menginstal ulang aplikasi atau pindah perangkat.

*   **Langkah 4: Testing & Rilis**
    *   [ ] Login di perangkat Android dengan akun penguji yang didaftarkan di Play Console.
    *   [ ] Jalankan aplikasi dalam mode rilis (`flutter run --release`). Pembelian sandbox terkadang tidak bekerja di mode debug.
    *   [ ] Lakukan alur pembelian dari awal hingga akhir.
    *   [ ] Verifikasi bahwa status premium pengguna terupdate di Appwrite dan UI aplikasi berubah.
    *   [ ] Setelah yakin, unggah aplikasi (AAB) ke Play Console untuk rilis internal/terbuka.

#### Minggu 7: Testing, Dokumentasi, dan Persiapan Rilis
*   **Testing:**
    *   [ ] Tulis Unit Test untuk services dan repositories (bisa menggunakan mock).
    *   [ ] Tulis Widget Test untuk komponen UI utama, termasuk alur login dan halaman dashboard.
    *   [ ] Lakukan User Acceptance Testing (UAT).
*   **Stabilisasi & Optimasi:**
    *   [ ] Perbaikan bug berdasarkan hasil testing.
    *   [x] Optimasi query Appwrite dan responsivitas UI.
*   **Dokumentasi & Rilis:**
    *   [ ] Finalisasi dokumentasi teknis.
    *   [ ] Siapkan aset aplikasi dan konfigurasi untuk rilis di App Store/Play Store.
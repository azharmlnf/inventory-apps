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

#### Minggu 6: Implementasi Monetisasi via Stripe (Alternatif)

> **PERINGATAN KERAS:** Metode ini digunakan untuk tujuan pembelajaran dan **melanggar kebijakan Google Play & Apple App Store** untuk membuka fitur digital. Menggunakan alur pembayaran eksternal seperti ini membawa **risiko sangat tinggi aplikasi ditolak atau dihapus** jika dipublikasikan.

*   **Arsitektur Sistem:**
    1.  **Frontend:** Aplikasi Flutter memulai permintaan upgrade.
    2.  **Backend 1:** Aplikasi memanggil **Appwrite Function #1** untuk membuat link pembayaran.
    3.  **Stripe:** Appwrite Function #1 berkomunikasi dengan Stripe untuk membuat Sesi Checkout dan mendapatkan URL.
    4.  **Frontend:** Aplikasi menerima URL Sesi Checkout dan membukanya di WebView/Browser.
    5.  **Stripe:** Setelah pengguna membayar, Stripe mengirim notifikasi (webhook) ke backend.
    6.  **Backend 2:** **Appwrite Function #2** menerima webhook, memverifikasinya, dan mengupdate status premium pengguna di database Appwrite.

*   **Langkah 1: Konfigurasi Stripe**
    *   [ ] Buat akun di Stripe (otomatis sudah ada mode testing/live).
    *   [ ] Dapatkan **Publishable Key** dan **Secret Key** (dalam mode testing) dari dasbor Stripe.
    *   [ ] Di dasbor Stripe (Developers -> Webhooks), buat **Webhook Endpoint** baru. URL ini akan menjadi URL publik dari Appwrite Function #2.

*   **Langkah 2: Backend dengan Appwrite Functions**
    *   **Function #1: `create-stripe-checkout`**
        *   [ ] Buat Appwrite Function baru (Node.js atau Dart).
        *   [ ] Simpan Stripe **Secret Key** Anda dengan aman di *environment variables* function, **bukan** di dalam kode.
        *   [ ] Tulis kode yang:
            *   Menerima `userId` dan `amount` dari aplikasi Flutter.
            *   Membuat parameter Sesi Checkout Stripe, termasuk `client_reference_id` untuk menyimpan `userId`.
            *   Menggunakan `stripe` npm package untuk membuat sesi.
            *   Mengembalikan `url` dari Sesi Checkout yang diterima dari Stripe ke aplikasi Flutter.
    *   **Function #2: `handle-stripe-webhook`**
        *   [ ] Buat Appwrite Function baru (Node.js atau Dart).
        *   [ ] Simpan **Webhook Signing Secret** dari Stripe di *environment variables* function.
        *   [ ] Tulis kode yang:
            *   Menerima notifikasi `POST` dari Stripe.
            *   Melakukan verifikasi *signature* untuk memastikan notifikasi valid dan aman.
            *   Mendengarkan event `checkout.session.completed`, lalu ambil `client_reference_id` (yang berisi `userId`) dari objek sesi.
            *   Menggunakan Appwrite Admin SDK untuk mencari pengguna berdasarkan `userId` dan mengupdate **Preferences** mereka menjadi `{ "isPremium": true }`.

*   **Langkah 3: Frontend di Aplikasi Flutter**
    *   [ ] Pasang package `url_launcher` untuk membuka URL di browser eksternal.
    *   [ ] Di `home_page.dart` (atau halaman premium), buat fungsi `upgradeViaStripe()`.
    *   [ ] Fungsi ini akan memanggil Appwrite Function #1 (`create-stripe-checkout`) dengan membawa User ID.
    *   [ ] Setelah menerima `url` sesi dari function, gunakan `url_launcher` untuk membuka URL tersebut.
    *   [ ] Tambahkan UI untuk memberitahu pengguna bahwa pembayaran sedang diproses dan status akan ter-update secara otomatis.

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
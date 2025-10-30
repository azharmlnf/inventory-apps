### Checklist Timeline Pengembangan "Inventarisku" v2.0 (7 Minggu)

#### Minggu 1: Setup Proyek & Autentikasi
*   **Setup Backend & Frontend:**
    *   [ ] Konfigurasi proyek baru di Appwrite (Auth, Database, Storage).
    *   [ ] Inisialisasi proyek Flutter, konfigurasi Git, dan struktur folder.
    *   [ ] Tambahkan dependensi utama: `flutter_riverpod`, `appwrite`, `google_sign_in`, `google_mobile_ads`.
*   **Implementasi Autentikasi:**
    *   [ ] Buat `AuthRepository` dan `AuthService`.
    *   [ ] Buat `LoginPage` dengan tombol "Login dengan Google".
    *   [ ] Implementasikan alur login OAuth2 dengan Google melalui Appwrite.
    *   [ ] Implementasikan alur Logout.
    *   [ ] Buat `SplashScreen` untuk mengarahkan pengguna berdasarkan status login.
    *   [ ] Perbarui UI prototipe (`ui ux`) untuk menyertakan halaman login.

#### Minggu 2: Implementasi CRUD Dasar (Online)
*   **Setup Appwrite Collections:**
    *   [ ] Definisikan dan buat koleksi di Appwrite: `categories`, `transactions`, `activity_logs` dengan atribut dan permission yang sesuai.
*   **CRUD Kategori (Online):**
    *   [ ] Buat `CategoryRepository` yang terhubung ke Appwrite.
    *   [ ] Implementasikan service dan UI (Widget) untuk operasi CRUD `Category` yang terikat pada `userId`.
    *   [ ] Integrasikan state management (Riverpod) untuk data kategori dari Appwrite.
*   **CRUD Transaksi (Online):**
    *   [ ] Buat `TransactionRepository` yang terhubung ke Appwrite.
    *   [ ] Implementasikan service dan UI (Widget) untuk operasi CRUD `Transaction`, memastikan setiap transaksi terikat pada `userId`.
*   **Riwayat Aktivitas (Online):**
    *   [ ] Implementasikan service untuk mencatat `ActivityLog` di Appwrite setiap kali ada aksi penting.

#### Minggu 3: Implementasi CRUD Barang & Stok (Online)
*   **Setup Appwrite Collection:**
    *   [ ] Definisikan dan buat koleksi `items` di Appwrite.
*   **CRUD Barang (Online):**
    *   [ ] Buat `ItemRepository` yang terhubung ke Appwrite.
    *   [ ] Implementasikan UI (`ItemListPage`, `ItemFormPage`) untuk operasi CRUD `Item`.
    *   [ ] Pastikan kuantitas barang di Appwrite diperbarui secara otomatis setelah transaksi.
    *   [ ] Integrasikan state management (Riverpod) untuk data `Item`.

#### Minggu 4: Fitur Notifikasi & Pelaporan Dasar
*   **Pengingat Restock:**
    *   [ ] Implementasikan logika di sisi klien untuk mendeteksi stok rendah dari data yang diambil dari Appwrite.
    *   [ ] Integrasi `flutter_local_notifications` untuk menampilkan notifikasi stok rendah.
    *   [ ] (Opsional) Jelajahi Appwrite Functions untuk push notification di masa depan.
*   **Pelaporan Sederhana:**
    *   [ ] Buat `ReportPage` untuk menampilkan ringkasan stok.
    *   [ ] Implementasikan query ke Appwrite untuk memfilter riwayat transaksi.

#### Minggu 5: Fitur Grafik Stok & Ekspor Data
*   **Grafik Stok Barang:**
    *   [ ] Integrasi `fl_chart` library.
    *   [ ] Implementasikan logika untuk mengambil dan mengagregasi data stok per kategori dari Appwrite.
    *   [ ] Buat widget grafik untuk menampilkan visualisasi stok.
*   **Ekspor Data:**
    *   [ ] Implementasikan service untuk mengambil data barang & transaksi dari Appwrite dan mengonversinya ke format CSV.
    *   [ ] Integrasi `share_plus` untuk membagikan file ekspor.

#### Minggu 6: Implementasi Monetisasi
*   **Monetisasi Iklan:**
    *   [ ] Integrasi Google AdMob (`google_mobile_ads`) untuk menampilkan iklan banner.
    *   [ ] Tampilkan iklan hanya jika pengguna bukan premium.
*   **Fitur Premium (Hapus Iklan):**
    *   [ ] Integrasi `in_app_purchase` Flutter plugin.
    *   [ ] Implementasikan logika untuk mengelola status premium pengguna.
    *   [ ] Sembunyikan semua iklan jika status pengguna adalah premium.
*   **(Tugas backup/restore cloud DIHAPUS karena tidak relevan lagi).**

#### Minggu 7: Testing, Dokumentasi, dan Persiapan Rilis
*   **Testing:**
    *   [ ] Tulis Unit Test untuk services dan repositories (bisa menggunakan mock).
    *   [ ] Tulis Widget Test untuk komponen UI utama.
    *   [ ] Lakukan User Acceptance Testing (UAT).
*   **Stabilisasi & Optimasi:**
    *   [ ] Perbaikan bug berdasarkan hasil testing.
    *   [ ] Optimasi query Appwrite dan responsivitas UI.
*   **Dokumentasi & Rilis:**
    *   [ ] Finalisasi dokumentasi teknis.
    *   [ ] Siapkan aset aplikasi dan konfigurasi untuk rilis di App Store/Play Store.

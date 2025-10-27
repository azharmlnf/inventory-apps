### Checklist Timeline Pengembangan "Inventarisku" (7 Minggu)

#### Minggu 1: Setup Proyek dan ui ux
*   [x] desain ui ux
*   [x] Inisialisasi proyek Flutter baru.
*   [x] Konfigurasi Git repository.
*   [x] Setup struktur folder (layered architecture).
*   [x] Tambahkan dependensi utama (Provider/Riverpod, sqflite, dll).

#### Minggu 2: Implementasi Database & Repository Pattern
*   [x] Definisikan skema tabel `items`, `categories`, `transactions`, `transaction_lines`, `stock_movements`, `activity_logs`.
*   [ ] Implementasi fitur CRUD untuk entitas `Item`.
*   [ ] Implementasi fitur CRUD untuk entitas `Category`.

#### Minggu 3: CRUD Barang dan Kategori
*   [ ] Implementasi fitur CRUD untuk entitas `Category` (logika bisnis/service layer).
*   [ ] Halaman daftar barang dengan pencarian dan pengurutan.
*   [ ] Form tambah/edit barang dengan input stok, kategori, dan batas restock.
*   [ ] Halaman manajemen kategori.
*   [ ] Form tambah/edit transaksi dengan input bukti pembayaran (opsional).

#### Minggu 4: Fitur Restock Notification + Activity Log
*   [ ] Implementasi logika pengingat restock.
*   [ ] Integrasi `flutter_local_notifications` untuk notifikasi restock.
*   [ ] Implementasi pencatatan riwayat aktivitas (Activity Log).
*   [ ] Halaman untuk menampilkan Activity Log.

#### Minggu 5: Fitur Grafik Chart Stok
*   [ ] Integrasi `fl_chart` library.
*   [ ] Implementasi logika untuk mengambil data stok per kategori.
*   [ ] Buat halaman atau widget untuk menampilkan grafik batang/pie chart stok.

#### Minggu 6: Implementasi Monetisasi (Iklan + Premium Unlock)
*   [ ] Integrasi Google AdMob untuk iklan banner dan interstitial.
*   [ ] Implementasi logika untuk menampilkan/menyembunyikan iklan.
*   [ ] Integrasi `in_app_purchase` Flutter plugin.
*   [ ] Implementasi logika untuk Premium Unlock (menghapus iklan, mengaktifkan backup cloud).
*   [ ] Implementasi backup manual ke Firebase Storage.

#### Minggu 7: Testing, Dokumentasi, dan Persiapan Rilis
*   [ ] Unit test untuk Business Logic Layer (Services).
*   [ ] Widget test untuk komponen UI utama.
*   [ ] User Acceptance Testing (UAT).
*   [ ] Perbaikan bug dan optimasi performa.
*   [ ] Finalisasi dokumentasi teknis dan pengguna.
*   [ ] Persiapan aset dan konfigurasi untuk rilis di Google Play Store.

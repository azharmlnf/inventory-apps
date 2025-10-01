/* FILE: script.js */

// Menjalankan skrip setelah seluruh dokumen HTML selesai dimuat
document.addEventListener('DOMContentLoaded', function() {

    // --- DATA DUMMY (Akan diganti API di aplikasi nyata) ---
    let dataBarang = [
        { kode: 'BRG001', nama: 'Buku Tulis', kuantitas: 50, unit: 'Pcs', harga: 5000 },
        { kode: 'BRG002', nama: 'Pensil 2B', kuantitas: 100, unit: 'Pcs', harga: 2000 },
        { kode: 'BRG003', nama: 'Kertas A4', kuantitas: 5, unit: 'Rim', harga: 50000 },
    ];

    // --- PEMILIHAN ELEMEN DOM ---
    const navLinks = document.querySelectorAll('.nav-link');
    const pages = document.querySelectorAll('.page-content');
    const tabelBarangBody = document.getElementById('tabel-barang-body');
    const totalBarangElement = document.getElementById('total-barang');
    
    // Elemen yang berhubungan dengan Modal
    const modal = document.getElementById('modal-tambah-barang');
    const btnTambahBarang = document.getElementById('btn-tambah-barang');
    const btnTutupModal = document.getElementById('btn-tutup-modal');
    const formTambahBarang = document.getElementById('form-tambah-barang');

    // --- FUNGSI UTAMA ---

    /**
     * Menampilkan halaman berdasarkan ID dan menyembunyikan halaman lainnya.
     * @param {string} pageId - ID dari elemen halaman yang akan ditampilkan.
     */
    const tampilkanHalaman = (pageId) => {
        pages.forEach(page => page.classList.add('hidden'));
        navLinks.forEach(link => link.classList.remove('active'));

        document.getElementById(pageId)?.classList.remove('hidden');
        document.querySelector(`.nav-link[data-page='${pageId}']`)?.classList.add('active');
    };

    /**
     * Me-render data dari array `dataBarang` ke dalam tabel HTML.
     */
    const renderTabelBarang = () => {
        tabelBarangBody.innerHTML = ''; // Kosongkan tabel sebelum diisi
        dataBarang.forEach(item => {
            const baris = `
                <tr>
                    <td>${item.kode}</td>
                    <td>${item.nama}</td>
                    <td>${item.kuantitas}</td>
                    <td>${item.unit}</td>
                    <td>${item.harga}</td>
                    <td>
                        <button>Edit</button>
                        <button>Hapus</button>
                    </td>
                </tr>
            `;
            tabelBarangBody.insertAdjacentHTML('beforeend', baris);
        });
        totalBarangElement.textContent = dataBarang.length; // Update total barang di dashboard
    };
    
    // --- FUNGSI MODAL ---
    const bukaModal = () => modal.classList.remove('hidden');
    const tutupModal = () => modal.classList.add('hidden');

    // --- PENANGAN EVENT (EVENT LISTENERS) ---

    // 1. Navigasi Sidebar
    navLinks.forEach(link => {
        link.addEventListener('click', (event) => {
            event.preventDefault();
            const pageId = link.getAttribute('data-page');
            tampilkanHalaman(pageId);
        });
    });

    // 2. Tombol untuk membuka modal
    btnTambahBarang.addEventListener('click', bukaModal);

    // 3. Tombol (X) untuk menutup modal
    btnTutupModal.addEventListener('click', tutupModal);

    // 4. Menutup modal jika klik di area luar konten modal
    modal.addEventListener('click', (event) => {
        if (event.target === modal) {
            tutupModal();
        }
    });

    // 5. Submit form untuk menambah barang baru
    formTambahBarang.addEventListener('submit', (event) => {
        event.preventDefault(); 
        const barangBaru = {
            kode: document.getElementById('kode').value,
            nama: document.getElementById('nama').value,
            kuantitas: parseInt(document.getElementById('kuantitas').value),
            unit: document.getElementById('unit').value,
            harga: parseInt(document.getElementById('harga').value)
        };
        dataBarang.push(barangBaru);
        renderTabelBarang();
        formTambahBarang.reset();
        tutupModal();
    });

    // --- INISIALISASI APLIKASI ---
    tampilkanHalaman('dashboard'); // Tampilkan halaman dashboard saat pertama kali dibuka
    renderTabelBarang(); // Render data awal ke dalam tabel

});
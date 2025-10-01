/* FILE: script.js */

document.addEventListener('DOMContentLoaded', function() {

    // --- DATA DUMMY ---
    let dataBarang = [
        { kode: 'BRG001', nama: 'Buku Tulis', kuantitas: 85, unit: 'Pcs', harga: 5000 },
        { kode: 'BRG002', nama: 'Pensil 2B', kuantitas: 100, unit: 'Pcs', harga: 2000 },
        { kode: 'BRG003', nama: 'Kertas A4', kuantitas: 10, unit: 'Rim', harga: 50000 },
        { kode: 'BRG004', nama: 'Spidol', kuantitas: 30, unit: 'Box', harga: 80000 }
    ];
    let dataTransaksi = [
        { tipe: 'masuk', namaBarang: 'Buku Tulis', jumlah: 50, tanggal: '2023-10-27' },
        { tipe: 'keluar', namaBarang: 'Pensil 2B', jumlah: 20, tanggal: '2023-10-27' },
        { tipe: 'keluar', namaBarang: 'Buku Tulis', jumlah: 15, tanggal: '2023-10-26' },
        { tipe: 'masuk', namaBarang: 'Kertas A4', jumlah: 5, tanggal: '2023-10-25' },
    ];

    // --- PEMILIHAN ELEMEN DOM ---
    const navLinks = document.querySelectorAll('.nav-link');
    const pages = document.querySelectorAll('.page-content');
    const barangListContainer = document.getElementById('barang-list-container');
    const totalBarangElement = document.getElementById('total-barang');
    const transaksiListContainer = document.getElementById('transaksi-list-container');
    const chartContainer = document.getElementById('chart-container');
    
    // Elemen Modal
    const modal = document.getElementById('modal-tambah-barang');
    const btnTambahBarang = document.getElementById('btn-tambah-barang');
    const btnTutupModal = document.getElementById('btn-tutup-modal');
    const formTambahBarang = document.getElementById('form-tambah-barang');

    // --- FUNGSI-FUNGSI RENDER ---
    const tampilkanHalaman = (pageId) => {
        pages.forEach(page => page.classList.add('hidden'));
        navLinks.forEach(link => link.classList.remove('active'));
        document.getElementById(pageId)?.classList.remove('hidden');
        document.querySelector(`.nav-link[data-page='${pageId}']`)?.classList.add('active');
        window.scrollTo(0, 0);
    };

    const renderListBarang = () => { /* ... (fungsi ini tidak berubah) ... */
        barangListContainer.innerHTML = '';
        dataBarang.forEach(item => {
            const itemCard = document.createElement('div');
            itemCard.className = 'barang-item';
            itemCard.innerHTML = `
                <div class="item-header"><h3>${item.nama}</h3><span class="kode-barang">${item.kode}</span></div>
                <div class="item-details">
                    <div>Stok: <span>${item.kuantitas} ${item.unit}</span></div>
                    <div>Harga: <span>Rp ${item.harga}</span></div>
                </div>
                <div class="item-actions"><button>Edit</button><button>Hapus</button></div>`;
            barangListContainer.appendChild(itemCard);
        });
        totalBarangElement.textContent = dataBarang.length;
    };

    const renderListTransaksi = () => {
        transaksiListContainer.innerHTML = '';
        dataTransaksi.forEach(trx => {
            const isMasuk = trx.tipe === 'masuk';
            const trxItem = document.createElement('div');
            trxItem.className = `transaksi-item ${isMasuk ? 'masuk' : 'keluar'}`;
            trxItem.innerHTML = `
                <div class="transaksi-info">
                    <h4>${trx.namaBarang}</h4>
                    <p>${trx.tanggal}</p>
                </div>
                <div class="transaksi-jumlah ${isMasuk ? 'masuk' : 'keluar'}">
                    ${isMasuk ? '+' : '-'}${trx.jumlah}
                </div>`;
            transaksiListContainer.appendChild(trxItem);
        });
    };

    const renderLaporan = () => {
        chartContainer.innerHTML = '';
        // Ambil 5 barang dengan stok terbanyak untuk ditampilkan di grafik
        const sortedData = [...dataBarang].sort((a, b) => b.kuantitas - a.kuantitas).slice(0, 5);
        const maxQuantity = sortedData.length > 0 ? sortedData[0].kuantitas : 100;

        sortedData.forEach(item => {
            const barPercentage = (item.kuantitas / maxQuantity) * 100;
            const chartBar = document.createElement('div');
            chartBar.className = 'chart-bar';
            chartBar.innerHTML = `
                <div class="bar-label" title="${item.nama}">${item.nama}</div>
                <div class="bar-itself" style="width: ${barPercentage}%;">
                    ${item.kuantitas}
                </div>`;
            chartContainer.appendChild(chartBar);
        });
    };

    // --- FUNGSI MODAL ---
    const bukaModal = () => modal.classList.remove('hidden');
    const tutupModal = () => modal.classList.add('hidden');

    // --- EVENT LISTENERS ---
    navLinks.forEach(link => {
        link.addEventListener('click', (e) => { e.preventDefault(); tampilkanHalaman(link.dataset.page); });
    });
    btnTambahBarang.addEventListener('click', bukaModal);
    btnTutupModal.addEventListener('click', tutupModal);
    modal.addEventListener('click', (e) => { if (e.target === modal) tutupModal(); });
    formTambahBarang.addEventListener('submit', (e) => {
        e.preventDefault();
        // Logika tambah barang...
        console.log("Form submitted!");
        tutupModal();
    });
    // Mencegah form pengaturan me-reload halaman
    document.querySelector('.settings-form').addEventListener('submit', (e) => {
        e.preventDefault();
        alert("Pengaturan disimpan! (prototipe)");
    });

    // --- INISIALISASI ---
    tampilkanHalaman('dashboard');
    renderListBarang();
    renderListTransaksi();
    renderLaporan();
});
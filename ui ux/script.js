/* FILE: script.js */

document.addEventListener('DOMContentLoaded', function() {

    // --- DATA DUMMY & STATE APLIKASI ---
    let dataKategori = [
        { id: 'CAT001', nama: 'Elektronik' },
        { id: 'CAT002', nama: 'Dapur' },
        { id: 'CAT003', nama: 'Alat Tulis' },
        { id: 'CAT004', nama: 'Pakaian' }
    ];

    let dataBarang = [
        { id: 'BRG001', kode: 'BRG001', nama: 'Buku Tulis', kuantitas: 85, unit: 'Pcs', harga: 5000, min_qty: 20, kategori_id: 'CAT003', gambar: '' },
        { id: 'BRG002', kode: 'BRG002', nama: 'Pensil 2B', kuantitas: 10, unit: 'Pcs', harga: 2000, min_qty: 15, kategori_id: 'CAT003', gambar: '' },
        { id: 'BRG003', kode: 'BRG003', nama: 'Kertas A4', kuantitas: 5, unit: 'Rim', harga: 50000, min_qty: 10, kategori_id: 'CAT003', gambar: '' },
        { id: 'BRG004', kode: 'BRG004', nama: 'Spidol', kuantitas: 30, unit: 'Box', harga: 80000, min_qty: 5, kategori_id: 'CAT003', gambar: '' },
        { id: 'BRG005', kode: 'BRG005', nama: 'Setrika', kuantitas: 15, unit: 'Unit', harga: 150000, min_qty: 10, kategori_id: 'CAT001', gambar: '' },
        { id: 'BRG006', kode: 'BRG006', nama: 'Panci', kuantitas: 8, unit: 'Pcs', harga: 75000, min_qty: 10, kategori_id: 'CAT002', gambar: '' }
    ];

    let dataTransaksi = [
        { id: 'TRX001', tipe: 'masuk', barang_id: 'BRG001', jumlah: 50, tanggal: '2023-10-27', catatan: 'Pembelian dari Supplier A' },
        { id: 'TRX002', tipe: 'keluar', barang_id: 'BRG002', jumlah: 20, tanggal: '2023-10-27', catatan: 'Penjualan ke Pelanggan B' },
        { id: 'TRX003', tipe: 'keluar', barang_id: 'BRG001', jumlah: 15, tanggal: '2023-10-26', catatan: 'Penjualan ke Pelanggan C' },
        { id: 'TRX004', tipe: 'masuk', barang_id: 'BRG003', jumlah: 5, tanggal: '2023-10-25', catatan: 'Pembelian dari Supplier B' },
    ];

    let dataActivityLog = [
        { id: 'ACT001', timestamp: '2023-10-27 14:21', description: 'Menambahkan 50 stok untuk Buku Tulis', item_id: 'BRG001', activity_type: 'ADD_STOCK' },
        { id: 'ACT002', timestamp: '2023-10-27 14:22', description: 'Mengurangi 20 stok untuk Pensil 2B', item_id: 'BRG002', activity_type: 'REMOVE_STOCK' },
        { id: 'ACT003', timestamp: '2023-10-26 10:00', description: 'Menambahkan barang baru: Setrika', item_id: 'BRG005', activity_type: 'ADD_ITEM' }
    ];

    let isPremium = false; // State untuk fitur premium

    // --- PEMILIHAN ELEMEN DOM ---
    const navLinks = document.querySelectorAll('.sidebar-nav .nav-link'); // Updated selector for sidebar nav
    const pages = document.querySelectorAll('.page-content');

    // Sidebar elements
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('overlay');
    const btnOpenSidebar = document.getElementById('btn-open-sidebar');
    const btnCloseSidebar = document.getElementById('btn-close-sidebar');
    const hamburgerIcons = document.querySelectorAll('.hamburger-icon'); // All hamburger icons

    // Dashboard
    const totalBarangElement = document.getElementById('total-barang');
    const stokAkanHabisElement = document.getElementById('stok-akan-habis');
    const transaksiHariIniElement = document.getElementById('transaksi-hari-ini');
    const notifikasiPentingElement = document.getElementById('notifikasi-penting');
    const transaksiTerbaruList = document.getElementById('transaksi-terbaru-list');

    // Barang
    const barangListContainer = document.getElementById('barang-list-container');
    const btnTambahBarang = document.getElementById('btn-tambah-barang');

    // Kategori
    const kategoriListContainer = document.getElementById('kategori-list-container');
    const btnTambahKategori = document.getElementById('btn-tambah-kategori');

    // Transaksi
    const transaksiListContainer = document.getElementById('transaksi-list-container');

    // Riwayat Aktivitas
    const activityLogListContainer = document.getElementById('activity-log-list-container');

    // Laporan
    const chartContainer = document.getElementById('chart-container');
    const btnEksporData = document.getElementById('btn-ekspor-data');
    const inputImporData = document.getElementById('input-impor-data');
    const btnImporData = document.getElementById('btn-impor-data');

    // Pengaturan
    const settingsForm = document.querySelector('.settings-form');
    const notifStokToggle = document.getElementById('notif-stok');
    const premiumStatusElement = document.getElementById('premium-status');
    const btnUpgradePremium = document.getElementById('btn-upgrade-premium');
    const btnBackupCloud = document.getElementById('btn-backup-cloud');
    const btnRestoreCloud = document.getElementById('btn-restore-cloud');

    // Modal Barang
    const modalBarang = document.getElementById('modal-barang');
    const modalBarangTitle = document.getElementById('modal-barang-title');
    const btnTutupModalBarang = document.getElementById('btn-tutup-modal-barang');
    const formBarang = document.getElementById('form-barang');
    const barangIdInput = document.getElementById('barang-id');
    const barangKodeInput = document.getElementById('barang-kode');
    const barangNamaInput = document.getElementById('barang-nama');
    const barangKuantitasInput = document.getElementById('barang-kuantitas');
    const barangUnitInput = document.getElementById('barang-unit');
    const barangHargaInput = document.getElementById('barang-harga');
    const barangMinQtyInput = document.getElementById('barang-min-qty');
    const barangKategoriSelect = document.getElementById('barang-kategori');
    const barangGambarInput = document.getElementById('barang-gambar');

    // Modal Kategori
    const modalKategori = document.getElementById('modal-kategori');
    const modalKategoriTitle = document.getElementById('modal-kategori-title');
    const btnTutupModalKategori = document.getElementById('btn-tutup-modal-kategori');
    const formKategori = document.getElementById('form-kategori');
    const kategoriIdInput = document.getElementById('kategori-id');
    const kategoriNamaInput = document.getElementById('kategori-nama');

    // --- HELPER FUNCTIONS ---
    function generateUniqueId(prefix) {
        return prefix + Date.now().toString(36) + Math.random().toString(36).substr(2, 5);
    }

    function getKategoriNama(id) {
        const kategori = dataKategori.find(cat => cat.id === id);
        return kategori ? kategori.nama : 'Tidak Berkategori';
    }

    function recordActivity(description, itemId = null, type = 'OTHER') {
        const now = new Date();
        const timestamp = `${now.getFullYear()}-${(now.getMonth() + 1).toString().padStart(2, '0')}-${now.getDate().toString().padStart(2, '0')} ${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
        dataActivityLog.unshift({ // Add to the beginning
            id: generateUniqueId('ACT'),
            timestamp: timestamp,
            description: description,
            item_id: itemId,
            activity_type: type
        });
        renderActivityLog();
    }

    function updatePremiumUI() {
        if (isPremium) {
            premiumStatusElement.textContent = 'Status: Premium (Bebas Iklan & Cloud Backup)';
            btnUpgradePremium.classList.add('hidden');
            btnBackupCloud.classList.remove('hidden');
            btnRestoreCloud.classList.remove('hidden');
            // Simulasi menghilangkan iklan
            console.log('Iklan dihilangkan!');
        } else {
            premiumStatusElement.textContent = 'Status: Gratis (dengan iklan)';
            btnUpgradePremium.classList.remove('hidden');
            btnBackupCloud.classList.add('hidden');
            btnRestoreCloud.classList.add('hidden');
            console.log('Iklan ditampilkan!');
        }
    }

    // --- SIDEBAR FUNCTIONS ---
    function openSidebar() {
        sidebar.classList.add('open');
        overlay.classList.remove('hidden');
    }

    function closeSidebar() {
        sidebar.classList.remove('open');
        overlay.classList.add('hidden');
    }

    // --- FUNGSI-FUNGSI RENDER ---
    const tampilkanHalaman = (pageId) => {
        pages.forEach(page => page.classList.add('hidden'));
        document.getElementById(pageId)?.classList.remove('hidden');

        // Update active nav link in sidebar
        navLinks.forEach(link => link.classList.remove('active'));
        document.querySelector(`.sidebar-nav .nav-link[data-page='${pageId}']`)?.classList.add('active');

        window.scrollTo(0, 0);
        closeSidebar(); // Close sidebar after navigation

        // Render spesifik untuk halaman yang ditampilkan
        if (pageId === 'dashboard') renderDashboard();
        if (pageId === 'barang') renderListBarang();
        if (pageId === 'kategori') renderListKategori();
        if (pageId === 'transaksi') renderListTransaksi();
        if (pageId === 'riwayat-aktivitas') renderActivityLog();
        if (pageId === 'laporan') renderLaporan();
    };

    const renderDashboard = () => {
        const totalJenisBarang = dataBarang.length;
        const stokAkanHabis = dataBarang.filter(item => item.kuantitas <= item.min_qty).length;
        const today = new Date().toISOString().slice(0, 10);
        const transaksiHariIni = dataTransaksi.filter(trx => trx.tanggal === today).length;

        totalBarangElement.textContent = totalJenisBarang;
        stokAkanHabisElement.textContent = stokAkanHabis;
        transaksiHariIniElement.textContent = transaksiHariIni;

        // Notifikasi Stok Rendah
        const lowStockItems = dataBarang.filter(item => item.kuantitas <= item.min_qty);
        if (lowStockItems.length > 0) {
            notifikasiPentingElement.innerHTML = `
                <p><strong>${lowStockItems.length}</strong> barang memiliki stok rendah:</p>
                <ul>
                    ${lowStockItems.map(item => `<li>${item.nama} (${item.kuantitas} ${item.unit})</li>`).join('')}
                </ul>
            `;
            notifikasiPentingElement.classList.remove('placeholder-box');
        } else {
            notifikasiPentingElement.innerHTML = '<p>Tidak ada notifikasi stok rendah.</p>';
            notifikasiPentingElement.classList.add('placeholder-box');
        }

        // Transaksi Terbaru (ambil 3-5 transaksi terakhir)
        transaksiTerbaruList.innerHTML = '';
        const latestTransactions = dataTransaksi.slice(0, 5);
        if (latestTransactions.length > 0) {
            latestTransactions.forEach(trx => {
                const item = dataBarang.find(b => b.id === trx.barang_id);
                const isMasuk = trx.tipe === 'masuk';
                const trxItem = document.createElement('div');
                trxItem.className = `transaksi-item ${isMasuk ? 'masuk' : 'keluar'}`;
                trxItem.innerHTML = `
                    <div class="transaksi-info">
                        <h4>${item ? item.nama : 'Barang Tidak Ditemukan'}</h4>
                        <p>${trx.tanggal} - ${trx.catatan}</p>
                    </div>
                    <div class="transaksi-jumlah ${isMasuk ? 'masuk' : 'keluar'}">
                        ${isMasuk ? '+' : '-'}${trx.jumlah}
                    </div>`;
                transaksiTerbaruList.appendChild(trxItem);
            });
            transaksiTerbaruList.classList.remove('placeholder-box');
        } else {
            transaksiTerbaruList.innerHTML = '<p>Belum ada transaksi terbaru.</p>';
            transaksiTerbaruList.classList.add('placeholder-box');
        }
    };

    const renderListBarang = () => {
        barangListContainer.innerHTML = '';
        if (dataBarang.length === 0) {
            barangListContainer.innerHTML = '<p class="placeholder-box">Belum ada barang. Tambahkan barang baru!</p>';
            return;
        }
        dataBarang.forEach(item => {
            const kategoriNama = getKategoriNama(item.kategori_id);
            const itemCard = document.createElement('div');
            itemCard.className = `barang-item ${item.kuantitas <= item.min_qty ? 'low-stock' : ''}`;
            itemCard.innerHTML = `
                <div class="item-header">
                    <h3>${item.nama}</h3>
                    <span class="kode-barang">${item.kode}</span>
                </div>
                <div class="item-details">
                    <div>Stok: <span>${item.kuantitas} ${item.unit}</span></div>
                    <div>Min. Stok: <span>${item.min_qty} ${item.unit}</span></div>
                    <div>Harga: <span>Rp ${item.harga}</span></div>
                    <div>Kategori: <span>${kategoriNama}</span></div>
                </div>
                <div class="item-actions">
                    <button data-id="${item.id}" class="edit-barang-btn">Edit</button>
                    <button data-id="${item.id}" class="hapus-barang-btn">Hapus</button>
                </div>`;
            barangListContainer.appendChild(itemCard);
        });
        totalBarangElement.textContent = dataBarang.length;

        // Add event listeners for edit/delete buttons
        document.querySelectorAll('.edit-barang-btn').forEach(button => {
            button.addEventListener('click', (e) => bukaModalBarang(e.target.dataset.id));
        });
        document.querySelectorAll('.hapus-barang-btn').forEach(button => {
            button.addEventListener('click', (e) => hapusBarang(e.target.dataset.id));
        });
    };

    const renderListKategori = () => {
        kategoriListContainer.innerHTML = '';
        if (dataKategori.length === 0) {
            kategoriListContainer.innerHTML = '<p class="placeholder-box">Belum ada kategori. Tambahkan kategori baru!</p>';
            return;
        }
        dataKategori.forEach(kategori => {
            const kategoriItem = document.createElement('div');
            kategoriItem.className = 'kategori-item';
            kategoriItem.innerHTML = `
                <span>${kategori.nama}</span>
                <div class="item-actions">
                    <button data-id="${kategori.id}" class="edit-kategori-btn">Edit</button>
                    <button data-id="${kategori.id}" class="hapus-kategori-btn">Hapus</button>
                </div>`;
            kategoriListContainer.appendChild(kategoriItem);
        });

        // Add event listeners for edit/delete buttons
        document.querySelectorAll('.edit-kategori-btn').forEach(button => {
            button.addEventListener('click', (e) => bukaModalKategori(e.target.dataset.id));
        });
        document.querySelectorAll('.hapus-kategori-btn').forEach(button => {
            button.addEventListener('click', (e) => hapusKategori(e.target.dataset.id));
        });
    };

    const renderListTransaksi = () => {
        transaksiListContainer.innerHTML = '';
        if (dataTransaksi.length === 0) {
            transaksiListContainer.innerHTML = '<p class="placeholder-box">Belum ada transaksi.</p>';
            return;
        }
        dataTransaksi.forEach(trx => {
            const item = dataBarang.find(b => b.id === trx.barang_id);
            const isMasuk = trx.tipe === 'masuk';
            const trxItem = document.createElement('div');
            trxItem.className = `transaksi-item ${isMasuk ? 'masuk' : 'keluar'}`;
            trxItem.innerHTML = `
                <div class="transaksi-info">
                    <h4>${item ? item.nama : 'Barang Tidak Ditemukan'}</h4>
                    <p>${trx.tanggal} - ${trx.catatan}</p>
                </div>
                <div class="transaksi-jumlah ${isMasuk ? 'masuk' : 'keluar'}">
                    ${isMasuk ? '+' : '-'}${trx.jumlah}
                </div>`;
            transaksiListContainer.appendChild(trxItem);
        });
    };

    const renderActivityLog = () => {
        activityLogListContainer.innerHTML = '';
        if (dataActivityLog.length === 0) {
            activityLogListContainer.innerHTML = '<p class="placeholder-box">Belum ada riwayat aktivitas.</p>';
            return;
        }
        dataActivityLog.forEach(log => {
            const logItem = document.createElement('div');
            logItem.className = 'activity-log-item';
            logItem.innerHTML = `
                <span class="timestamp">${log.timestamp}</span>
                <p>${log.description}</p>
            `;
            activityLogListContainer.appendChild(logItem);
        });
    };

    const renderLaporan = () => {
        chartContainer.innerHTML = '';
        if (dataBarang.length === 0) {
            chartContainer.innerHTML = '<p class="placeholder-box">Tidak ada data barang untuk grafik.</p>';
            return;
        }

        // Agregasi stok per kategori
        const stokPerKategori = {};
        dataBarang.forEach(item => {
            const kategoriNama = getKategoriNama(item.kategori_id);
            if (!stokPerKategori[kategoriNama]) {
                stokPerKategori[kategoriNama] = 0;
            }
            stokPerKategori[kategoriNama] += item.kuantitas;
        });

        const sortedKategoriStok = Object.entries(stokPerKategori).sort(([, qtyA], [, qtyB]) => qtyB - qtyA);
        const maxQuantity = sortedKategoriStok.length > 0 ? sortedKategoriStok[0][1] : 100;

        if (sortedKategoriStok.length === 0) {
            chartContainer.innerHTML = '<p class="placeholder-box">Tidak ada data kategori dengan stok.</p>';
            return;
        }

        sortedKategoriStok.forEach(([kategoriNama, kuantitas]) => {
            const barPercentage = (kuantitas / maxQuantity) * 100;
            const chartBar = document.createElement('div');
            chartBar.className = 'chart-bar';
            chartBar.innerHTML = `
                <div class="bar-label" title="${kategoriNama}">${kategoriNama}</div>
                <div class="bar-itself" style="width: ${barPercentage}%;">
                    ${kuantitas}
                </div>`;
            chartContainer.appendChild(chartBar);
        });
    };

    // --- FUNGSI MODAL BARANG ---
    const bukaModalBarang = (barangId = null) => {
        modalBarang.classList.remove('hidden');
        formBarang.reset();
        barangIdInput.value = '';
        modalBarangTitle.textContent = 'Tambah Barang Baru';

        // Populate kategori select
        barangKategoriSelect.innerHTML = dataKategori.map(cat => `<option value="${cat.id}">${cat.nama}</option>`).join('');
        if (dataKategori.length === 0) {
            barangKategoriSelect.innerHTML = '<option value="">Buat Kategori Dulu</option>';
            barangKategoriSelect.disabled = true;
        } else {
            barangKategoriSelect.disabled = false;
        }

        if (barangId) {
            const item = dataBarang.find(b => b.id === barangId);
            if (item) {
                modalBarangTitle.textContent = 'Edit Barang';
                barangIdInput.value = item.id;
                barangKodeInput.value = item.kode;
                barangNamaInput.value = item.nama;
                barangKuantitasInput.value = item.kuantitas;
                barangUnitInput.value = item.unit;
                barangHargaInput.value = item.harga;
                barangMinQtyInput.value = item.min_qty;
                barangKategoriSelect.value = item.kategori_id;
                barangGambarInput.value = item.gambar;
            }
        }
    };

    const tutupModalBarang = () => modalBarang.classList.add('hidden');

    // --- FUNGSI MODAL KATEGORI ---
    const bukaModalKategori = (kategoriId = null) => {
        modalKategori.classList.remove('hidden');
        formKategori.reset();
        kategoriIdInput.value = '';
        modalKategoriTitle.textContent = 'Tambah Kategori Baru';

        if (kategoriId) {
            const kategori = dataKategori.find(cat => cat.id === kategoriId);
            if (kategori) {
                modalKategoriTitle.textContent = 'Edit Kategori';
                kategoriIdInput.value = kategori.id;
                kategoriNamaInput.value = kategori.nama;
            }
        }
    };

    const tutupModalKategori = () => modalKategori.classList.add('hidden');

    // --- CRUD BARANG ---
    const simpanBarang = (e) => {
        e.preventDefault();
        const id = barangIdInput.value;
        const kode = barangKodeInput.value;
        const nama = barangNamaInput.value;
        const kuantitas = parseInt(barangKuantitasInput.value);
        const unit = barangUnitInput.value;
        const harga = parseFloat(barangHargaInput.value);
        const min_qty = parseInt(barangMinQtyInput.value);
        const kategori_id = barangKategoriSelect.value;
        const gambar = barangGambarInput.value;

        if (id) {
            // Edit Barang
            const index = dataBarang.findIndex(item => item.id === id);
            if (index !== -1) {
                const oldKuantitas = dataBarang[index].kuantitas;
                dataBarang[index] = { id, kode, nama, kuantitas, unit, harga, min_qty, kategori_id, gambar };
                recordActivity(`Mengedit barang: ${nama}. Kuantitas berubah dari ${oldKuantitas} menjadi ${kuantitas}.`, id, 'EDIT_ITEM');
            }
        } else {
            // Tambah Barang
            const newId = generateUniqueId('BRG');
            dataBarang.push({ id: newId, kode, nama, kuantitas, unit, harga, min_qty, kategori_id, gambar });
            recordActivity(`Menambahkan barang baru: ${nama} dengan kuantitas ${kuantitas}.`, newId, 'ADD_ITEM');
        }
        tutupModalBarang();
        tampilkanHalaman('barang');
    };

    const hapusBarang = (id) => {
        if (confirm('Apakah Anda yakin ingin menghapus barang ini?')) {
            const item = dataBarang.find(b => b.id === id);
            dataBarang = dataBarang.filter(item => item.id !== id);
            recordActivity(`Menghapus barang: ${item.nama}.`, id, 'DELETE_ITEM');
            tampilkanHalaman('barang');
        }
    };

    // --- CRUD KATEGORI ---
    const simpanKategori = (e) => {
        e.preventDefault();
        const id = kategoriIdInput.value;
        const nama = kategoriNamaInput.value;

        if (id) {
            // Edit Kategori
            const index = dataKategori.findIndex(cat => cat.id === id);
            if (index !== -1) {
                dataKategori[index] = { id, nama };
                recordActivity(`Mengedit kategori: ${nama}.`, null, 'EDIT_CATEGORY');
            }
        } else {
            // Tambah Kategori
            const newId = generateUniqueId('CAT');
            dataKategori.push({ id: newId, nama });
            recordActivity(`Menambahkan kategori baru: ${nama}.`, null, 'ADD_CATEGORY');
        }
        tutupModalKategori();
        tampilkanHalaman('kategori');
    };

    const hapusKategori = (id) => {
        if (confirm('Apakah Anda yakin ingin menghapus kategori ini? Barang yang terkait akan menjadi tidak berkategori.')) {
            const kategori = dataKategori.find(cat => cat.id === id);
            dataKategori = dataKategori.filter(cat => cat.id !== id);
            // Update barang yang terkait agar tidak berkategori
            dataBarang.forEach(item => {
                if (item.kategori_id === id) {
                    item.kategori_id = ''; // Set to empty or a default 'Uncategorized' category
                }
            });
            recordActivity(`Menghapus kategori: ${kategori.nama}.`, null, 'DELETE_CATEGORY');
            tampilkanHalaman('kategori');
        }
    };

    // --- EKSPOR/IMPOR DATA ---
    const eksporData = () => {
        const headerBarang = ['id', 'kode', 'nama', 'kuantitas', 'unit', 'harga', 'min_qty', 'kategori_id', 'gambar'];
        const headerKategori = ['id', 'nama'];
        const headerTransaksi = ['id', 'tipe', 'barang_id', 'jumlah', 'tanggal', 'catatan'];
        const headerActivity = ['id', 'timestamp', 'description', 'item_id', 'activity_type'];

        let csvContent = 'Data Barang\n' + headerBarang.join(',') + '\n'
            + dataBarang.map(row => headerBarang.map(fieldName => JSON.stringify(row[fieldName])).join(',')).join('\n');
        csvContent += '\n\nData Kategori\n' + headerKategori.join(',') + '\n'
            + dataKategori.map(row => headerKategori.map(fieldName => JSON.stringify(row[fieldName])).join(',')).join('\n');
        csvContent += '\n\nData Transaksi\n' + headerTransaksi.join(',') + '\n'
            + dataTransaksi.map(row => headerTransaksi.map(fieldName => JSON.stringify(row[fieldName])).join(',')).join('\n');
        csvContent += '\n\nData Aktivitas\n' + headerActivity.join(',') + '\n'
            + dataActivityLog.map(row => headerActivity.map(fieldName => JSON.stringify(row[fieldName])).join(',')).join('\n');

        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.setAttribute('download', 'inventarisku_data.csv');
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        alert('Data berhasil diekspor ke inventarisku_data.csv');
        recordActivity('Mengekspor semua data ke CSV.', null, 'EXPORT_DATA');
    };

    const imporData = (e) => {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function(event) {
            const csvString = event.target.result;
            // Simulasi parsing CSV. Dalam aplikasi nyata, ini akan lebih kompleks.
            alert('Simulasi impor data dari CSV. Data akan diproses di sini.');
            console.log('CSV Content:', csvString);
            recordActivity('Mencoba mengimpor data dari CSV.', null, 'IMPORT_DATA');
            // Di sini Anda akan memparsing csvString dan memperbarui dataBarang, dataKategori, dll.
            // Untuk prototipe, kita hanya mensimulasikan prosesnya.
        };
        reader.readAsText(file);
    };

    // --- FITUR PREMIUM ---
    const togglePremiumStatus = () => {
        isPremium = !isPremium;
        updatePremiumUI();
        alert(isPremium ? 'Anda sekarang Premium!' : 'Anda kembali ke status Gratis.');
        recordActivity(isPremium ? 'Mengaktifkan status Premium.' : 'Menonaktifkan status Premium.', null, 'TOGGLE_PREMIUM');
    };

    const simulasiBackupCloud = () => {
        if (!isPremium) {
            alert('Fitur ini hanya tersedia untuk pengguna Premium.');
            return;
        }
        alert('Simulasi: Data Anda sedang di-backup ke Firebase Storage...');
        console.log('Data to backup:', { dataBarang, dataKategori, dataTransaksi, dataActivityLog });
        recordActivity('Melakukan backup data ke Cloud.', null, 'CLOUD_BACKUP');
    };

    const simulasiRestoreCloud = () => {
        if (!isPremium) {
            alert('Fitur ini hanya tersedia untuk pengguna Premium.');
            return;
        }
        if (confirm('Simulasi: Apakah Anda yakin ingin memulihkan data dari Cloud? Data lokal saat ini akan ditimpa.')) {
            alert('Simulasi: Data Anda sedang dipulihkan dari Firebase Storage...');
            // Di sini Anda akan memuat data dari 'cloud' dan menimpa data lokal
            // Untuk prototipe, kita hanya mensimulasikan prosesnya.
            console.log('Simulasi restore: Data dari cloud akan dimuat.');
            recordActivity('Memulihkan data dari Cloud.', null, 'CLOUD_RESTORE');
            tampilkanHalaman('dashboard'); // Refresh UI setelah restore
        }
    };

    // --- EVENT LISTENERS ---
    // Sidebar Toggles
    hamburgerIcons.forEach(icon => icon.addEventListener('click', openSidebar));
    btnCloseSidebar.addEventListener('click', closeSidebar);
    overlay.addEventListener('click', closeSidebar);

    // Navigasi Sidebar
    navLinks.forEach(link => {
        link.addEventListener('click', (e) => { e.preventDefault(); tampilkanHalaman(link.dataset.page); });
    });

    // Barang
    btnTambahBarang.addEventListener('click', () => bukaModalBarang());
    btnTutupModalBarang.addEventListener('click', tutupModalBarang);
    modalBarang.addEventListener('click', (e) => { if (e.target === modalBarang) tutupModalBarang(); });
    formBarang.addEventListener('submit', simpanBarang);

    // Kategori
    btnTambahKategori.addEventListener('click', () => bukaModalKategori());
    btnTutupModalKategori.addEventListener('click', tutupModalKategori);
    modalKategori.addEventListener('click', (e) => { if (e.target === modalKategori) tutupModalKategori(); });
    formKategori.addEventListener('submit', simpanKategori);

    // Laporan (Ekspor/Impor)
    btnEksporData.addEventListener('click', eksporData);
    btnImporData.addEventListener('click', () => inputImporData.click()); // Trigger file input
    inputImporData.addEventListener('change', imporData);

    // Pengaturan (Premium)
    btnUpgradePremium.addEventListener('click', togglePremiumStatus);
    btnBackupCloud.addEventListener('click', simulasiBackupCloud);
    btnRestoreCloud.addEventListener('click', simulasiRestoreCloud);

    // Mencegah form pengaturan me-reload halaman
    settingsForm.addEventListener('submit', (e) => {
        e.preventDefault();
        alert("Pengaturan disimpan! (prototipe)");
        recordActivity('Menyimpan pengaturan aplikasi.', null, 'SAVE_SETTINGS');
    });

    // --- INISIALISASI ---
    tampilkanHalaman('dashboard');
    updatePremiumUI();
});
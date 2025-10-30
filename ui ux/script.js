/* FILE: script.js */

document.addEventListener('DOMContentLoaded', function() {
    console.log("Script v2.2 (Email/Password Auth, Enhanced Data & Reports) started.");

    // --- STATE APLIKASI ---
    let isLoggedIn = false;
    let isPremium = false;
    let currentUser = { email: '' }; // Dummy user

    // --- DATA DUMMY (akan diambil dari Appwrite) ---
    let dataKategori = [
        { id: 'CAT001', nama: 'Elektronik' },
        { id: 'CAT002', nama: 'Dapur' },
        { id: 'CAT003', nama: 'Alat Tulis' },
        { id: 'CAT004', nama: 'Pakaian' },
        { id: 'CAT005', nama: 'Makanan & Minuman' }
    ];

    let dataBarang = [
        { id: 'BRG001', kode: 'BRG001', nama: 'Buku Tulis A5', kuantitas: 85, unit: 'Pcs', buy_price: 3000, sell_price: 5000, min_qty: 20, kategori_id: 'CAT003', gambar: '' },
        { id: 'BRG002', kode: 'BRG002', nama: 'Pensil 2B Faber', kuantitas: 10, unit: 'Pcs', buy_price: 1500, sell_price: 2500, min_qty: 15, kategori_id: 'CAT003', gambar: '' },
        { id: 'BRG003', kode: 'BRG003', nama: 'Kertas HVS A4', kuantitas: 5, unit: 'Rim', buy_price: 45000, sell_price: 55000, min_qty: 10, kategori_id: 'CAT003', gambar: '' },
        { id: 'BRG004', kode: 'BRG004', nama: 'Spidol Whiteboard', kuantitas: 30, unit: 'Box', buy_price: 70000, sell_price: 90000, min_qty: 5, kategori_id: 'CAT003', gambar: '' },
        { id: 'BRG005', kode: 'BRG005', nama: 'Setrika Philips', kuantitas: 15, unit: 'Unit', buy_price: 120000, sell_price: 180000, min_qty: 10, kategori_id: 'CAT001', gambar: '' },
        { id: 'BRG006', kode: 'BRG006', nama: 'Panci Anti Lengket', kuantitas: 8, unit: 'Pcs', buy_price: 60000, sell_price: 85000, min_qty: 10, kategori_id: 'CAT002', gambar: '' },
        { id: 'BRG007', kode: 'BRG007', nama: 'Kemeja Pria L', kuantitas: 25, unit: 'Pcs', buy_price: 80000, sell_price: 120000, min_qty: 10, kategori_id: 'CAT004', gambar: '' },
        { id: 'BRG008', kode: 'BRG008', nama: 'Teh Celup Kotak', kuantitas: 50, unit: 'Box', buy_price: 10000, sell_price: 15000, min_qty: 25, kategori_id: 'CAT005', gambar: '' },
        { id: 'BRG009', kode: 'BRG009', nama: 'Kopi Instan Sachet', kuantitas: 5, unit: 'Pack', buy_price: 20000, sell_price: 28000, min_qty: 10, kategori_id: 'CAT005', gambar: '' }, // Low stock
        { id: 'BRG010', kode: 'BRG010', nama: 'Mouse Wireless', kuantitas: 12, unit: 'Unit', buy_price: 50000, sell_price: 75000, min_qty: 5, kategori_id: 'CAT001', gambar: '' } // Low stock
    ];

    let dataTransaksi = [
        { id: 'TRX001', tipe: 'masuk', barang_id: 'BRG001', jumlah: 50, tanggal: '2023-10-27', catatan: 'Pembelian dari Supplier A', image_path: '' },
        { id: 'TRX002', tipe: 'keluar', barang_id: 'BRG002', jumlah: 20, tanggal: '2023-10-27', catatan: 'Penjualan ke Pelanggan B', image_path: '' },
        { id: 'TRX003', tipe: 'keluar', barang_id: 'BRG001', jumlah: 15, tanggal: '2023-10-26', catatan: 'Penjualan ke Pelanggan C', image_path: '' },
        { id: 'TRX004', tipe: 'masuk', barang_id: 'BRG003', jumlah: 5, tanggal: '2023-10-25', catatan: 'Pembelian dari Supplier B', image_path: '' },
        { id: 'TRX005', tipe: 'keluar', barang_id: 'BRG005', jumlah: 3, tanggal: '2023-10-24', catatan: 'Penjualan ke Toko Elektronik', image_path: '' },
        { id: 'TRX006', tipe: 'masuk', barang_id: 'BRG006', jumlah: 10, tanggal: '2023-10-23', catatan: 'Restock Panci', image_path: '' },
        { id: 'TRX007', tipe: 'keluar', barang_id: 'BRG007', jumlah: 10, tanggal: '2023-10-22', catatan: 'Penjualan Grosir', image_path: '' },
        { id: 'TRX008', tipe: 'keluar', barang_id: 'BRG008', jumlah: 20, tanggal: '2023-10-21', catatan: 'Penjualan Eceran', image_path: '' },
        { id: 'TRX009', tipe: 'keluar', barang_id: 'BRG009', jumlah: 2, tanggal: '2023-10-20', catatan: 'Penjualan Kopi', image_path: '' },
        { id: 'TRX010', tipe: 'masuk', barang_id: 'BRG010', jumlah: 10, tanggal: '2023-10-19', catatan: 'Pembelian Mouse', image_path: '' },
        { id: 'TRX011', tipe: 'keluar', barang_id: 'BRG001', jumlah: 5, tanggal: '2023-10-18', catatan: 'Penjualan ke Pelanggan D', image_path: '' },
        { id: 'TRX012', tipe: 'keluar', barang_id: 'BRG002', jumlah: 5, tanggal: '2023-10-17', catatan: 'Penjualan ke Pelanggan E', image_path: '' },
        { id: 'TRX013', tipe: 'keluar', barang_id: 'BRG003', jumlah: 1, tanggal: '2023-10-16', catatan: 'Penjualan Kertas', image_path: '' },
        { id: 'TRX014', tipe: 'keluar', barang_id: 'BRG004', jumlah: 2, tanggal: '2023-10-15', catatan: 'Penjualan Spidol', image_path: '' },
        { id: 'TRX015', tipe: 'keluar', barang_id: 'BRG005', jumlah: 1, tanggal: '2023-10-14', catatan: 'Penjualan Setrika', image_path: '' },
    ];

    let dataActivityLog = [
        { id: 'ACT001', timestamp: '2023-10-27 14:21', description: 'Menambahkan 50 stok untuk Buku Tulis A5', item_id: 'BRG001', activity_type: 'ADD_STOCK' },
        { id: 'ACT002', timestamp: '2023-10-27 14:22', description: 'Mengurangi 20 stok untuk Pensil 2B Faber', item_id: 'BRG002', activity_type: 'REMOVE_STOCK' },
        { id: 'ACT003', timestamp: '2023-10-26 10:00', description: 'Menambahkan barang baru: Setrika Philips', item_id: 'BRG005', activity_type: 'ADD_ITEM' },
        { id: 'ACT004', timestamp: '2023-10-25 11:30', description: 'Mengedit barang: Kertas HVS A4 (harga jual)', item_id: 'BRG003', activity_type: 'EDIT_ITEM' },
        { id: 'ACT005', timestamp: '2023-10-24 09:00', description: 'Menambahkan kategori baru: Makanan & Minuman', item_id: null, activity_type: 'ADD_CATEGORY' },
        { id: 'ACT006', timestamp: '2023-10-23 16:45', description: 'Mengurangi 10 stok untuk Kemeja Pria L', item_id: 'BRG007', activity_type: 'REMOVE_STOCK' },
    ];

    // --- PEMILIHAN ELEMEN DOM ---
    const authPage = document.getElementById('auth-page');
    const appContainer = document.getElementById('app-container');
    const authEmailInput = document.getElementById('auth-email');
    const authPasswordInput = document.getElementById('auth-password');
    const btnLogin = document.getElementById('btn-login');
    const btnRegister = document.getElementById('btn-register');
    const btnLogout = document.getElementById('btn-logout');
    const userEmailElement = document.getElementById('user-email');
    const hamburgerIcons = document.querySelectorAll('.hamburger-icon');
    const navLinks = document.querySelectorAll('.sidebar-nav .nav-link');
    const pages = document.querySelectorAll('.page-content');
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('overlay');
    const btnCloseSidebar = document.getElementById('btn-close-sidebar');
    const premiumStatusElement = document.getElementById('premium-status');
    const btnUpgradePremium = document.getElementById('btn-upgrade-premium');

    // Dashboard elements
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
    const totalNilaiStokElement = document.getElementById('total-nilai-stok');
    const totalNilaiPenjualanElement = document.getElementById('total-nilai-penjualan');
    const totalKeuntunganKotorElement = document.getElementById('total-keuntungan-kotor');
    const barangTerlarisList = document.getElementById('barang-terlaris-list');
    const kategoriStokTerbanyakElement = document.getElementById('kategori-stok-terbanyak');

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
    const barangHargaBeliInput = document.getElementById('barang-harga-beli'); // New
    const barangHargaJualInput = document.getElementById('barang-harga-jual'); // New
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

    // Modal Transaksi
    const modalTransaksi = document.getElementById('modal-transaksi');
    const modalTransaksiTitle = document.getElementById('modal-transaksi-title');
    const btnTutupModalTransaksi = document.getElementById('btn-tutup-modal-transaksi');
    const formTransaksi = document.getElementById('form-transaksi');
    const transaksiIdInput = document.getElementById('transaksi-id');
    const transaksiTipeSelect = document.getElementById('transaksi-tipe');
    const transaksiBarangSelect = document.getElementById('transaksi-barang');
    const transaksiJumlahInput = document.getElementById('transaksi-jumlah');
    const transaksiTanggalInput = document.getElementById('transaksi-tanggal');
    const transaksiCatatanInput = document.getElementById('transaksi-catatan');
    const transaksiBuktiPembayaranInput = document.getElementById('transaksi-bukti-pembayaran');

    // --- HELPER FUNCTIONS ---
    function generateUniqueId(prefix) {
        return prefix + Date.now().toString(36) + Math.random().toString(36).substr(2, 5);
    }

    function getKategoriNama(id) {
        const kategori = dataKategori.find(cat => cat.id === id);
        return kategori ? kategori.nama : 'Tidak Berkategori';
    }

    function getBarangById(id) {
        return dataBarang.find(item => item.id === id);
    }

    function getBarangNama(id) {
        const barang = getBarangById(id);
        return barang ? barang.nama : 'Barang Tidak Ditemukan';
    }

    function formatCurrency(amount) {
        return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(amount);
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

    // --- FUNGSI-FUNGSI UTAMA ---
    function checkAuthStatus() {
        if (isLoggedIn) {
            authPage.classList.add('hidden');
            appContainer.classList.remove('hidden');
            userEmailElement.textContent = currentUser.email;
            tampilkanHalaman('dashboard');
            updatePremiumUI();
        } else {
            authPage.classList.remove('hidden');
            appContainer.classList.add('hidden');
            authEmailInput.value = '';
            authPasswordInput.value = '';
        }
    }

    async function handleLogin() {
        const email = authEmailInput.value;
        const password = authPasswordInput.value;
        if (!email || !password) {
            alert('Email dan password harus diisi.');
            return;
        }
        console.log(`Simulating Login for ${email}...`);
        // Simulasi Appwrite login
        // Di sini akan ada panggilan ke Appwrite SDK: account.createEmailSession(email, password)
        // Jika berhasil:
        isLoggedIn = true;
        currentUser.email = email;
        alert('Login berhasil!');
        checkAuthStatus();
    }

    async function handleRegister() {
        const email = authEmailInput.value;
        const password = authPasswordInput.value;
        if (!email || !password) {
            alert('Email dan password harus diisi.');
            return;
        }
        if (password.length < 8) {
            alert('Password minimal 8 karakter.');
            return;
        }
        console.log(`Simulating Registration for ${email}...`);
        // Simulasi Appwrite registrasi
        // Di sini akan ada panggilan ke Appwrite SDK: account.create(userId: 'unique()', email: email, password: password)
        // Jika berhasil:
        alert('Registrasi berhasil! Silakan login.');
    }

    function handleLogout() {
        if (confirm('Apakah Anda yakin ingin logout?')) {
            console.log("Logging out...");
            // Simulasi Appwrite logout
            // Di sini akan ada panggilan ke Appwrite SDK: account.deleteSession(sessionId: 'current')
            isLoggedIn = false;
            currentUser.email = '';
            alert('Logout berhasil.');
            checkAuthStatus();
        }
    }

    const tampilkanHalaman = (pageId) => {
        pages.forEach(page => page.classList.add('hidden'));
        document.getElementById(pageId)?.classList.remove('hidden');
        navLinks.forEach(link => link.classList.remove('active'));
        document.querySelector(`.sidebar-nav .nav-link[data-page='${pageId}']`)?.classList.add('active');
        window.scrollTo(0, 0);
        closeSidebar();
        
        // Render spesifik untuk halaman yang ditampilkan
        if (pageId === 'dashboard') renderDashboard();
        if (pageId === 'barang') renderListBarang();
        if (pageId === 'kategori') renderListKategori();
        if (pageId === 'transaksi') renderListTransaksi();
        if (pageId === 'riwayat-aktivitas') renderActivityLog();
        if (pageId === 'laporan') renderLaporan();
    };

    function openSidebar() {
        sidebar.classList.add('open');
        overlay.classList.remove('hidden');
    }

    function closeSidebar() {
        sidebar.classList.remove('open');
        overlay.classList.add('hidden');
    }

    function updatePremiumUI() {
        if (isLoggedIn) { // Only show premium status if logged in
            if (isPremium) {
                premiumStatusElement.textContent = 'Status: Premium (Bebas Iklan)';
                btnUpgradePremium.textContent = 'Anda Sudah Premium';
                btnUpgradePremium.disabled = true;
                console.log('Iklan disembunyikan!');
            } else {
                premiumStatusElement.textContent = 'Status: Gratis (dengan iklan)';
                btnUpgradePremium.textContent = 'Upgrade ke Premium (Bebas Iklan)';
                btnUpgradePremium.disabled = false;
                console.log('Iklan ditampilkan!');
            }
        } else {
            premiumStatusElement.textContent = 'Login untuk melihat status premium.';
            btnUpgradePremium.textContent = 'Login untuk Upgrade';
            btnUpgradePremium.disabled = true;
        }
    }

    function togglePremiumStatus() {
        if (!isLoggedIn) {
            alert('Anda harus login untuk mengelola status premium.');
            return;
        }
        isPremium = !isPremium;
        alert(isPremium ? 'Anda sekarang Premium!' : 'Anda kembali ke status Gratis.');
        updatePremiumUI();
    }

    // --- FUNGSI-FUNGSI RENDER ---
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
                const item = getBarangById(trx.barang_id);
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
                    <div>Harga Jual: <span>${formatCurrency(item.sell_price)}</span></div>
                    <div>Kategori: <span>${kategoriNama}</span></div>
                </div>
                <div class="item-actions">
                    <button data-id="${item.id}" class="edit-barang-btn">Edit</button>
                    <button data-id="${item.id}" class="hapus-barang-btn">Hapus</button>
                </div>`;
            barangListContainer.appendChild(itemCard);
        });

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
            const item = getBarangById(trx.barang_id);
            const isMasuk = trx.tipe === 'masuk';
            const trxItem = document.createElement('div');
            trxItem.className = `transaksi-item ${isMasuk ? 'masuk' : 'keluar'}`;
            trxItem.innerHTML = `
                <div class="transaksi-info">
                    <h4>${item ? item.nama : 'Barang Tidak Ditemukan'}</h4>
                    <p>${trx.tanggal} - ${trx.catatan}</p>
                    ${trx.image_path ? `<img src="${trx.image_path}" alt="Bukti Pembayaran" style="max-width: 100px; max-height: 100px; margin-top: 5px;">` : ''}
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

    // --- FUNGSI LAPORAN & STATISTIK ---
    const calculateTotalStockValue = () => {
        let totalValue = 0;
        dataBarang.forEach(item => {
            totalValue += item.kuantitas * item.buy_price;
        });
        return totalValue;
    };

    const calculateTotalSalesValue = () => {
        let totalSales = 0;
        dataTransaksi.filter(trx => trx.tipe === 'keluar').forEach(trx => {
            const item = getBarangById(trx.barang_id);
            if (item) {
                totalSales += trx.jumlah * item.sell_price;
            }
        });
        return totalSales;
    };

    const calculateTotalGrossProfit = () => {
        let totalProfit = 0;
        dataTransaksi.filter(trx => trx.tipe === 'keluar').forEach(trx => {
            const item = getBarangById(trx.barang_id);
            if (item) {
                totalProfit += trx.jumlah * (item.sell_price - item.buy_price);
            }
        });
        return totalProfit;
    };

    const getTopSellingItems = (limit = 3) => {
        const salesMap = {};
        dataTransaksi.filter(trx => trx.tipe === 'keluar').forEach(trx => {
            if (salesMap[trx.barang_id]) {
                salesMap[trx.barang_id] += trx.jumlah;
            } else {
                salesMap[trx.barang_id] = trx.jumlah;
            }
        });

        const sortedSales = Object.entries(salesMap).sort(([, qtyA], [, qtyB]) => qtyB - qtyA);
        return sortedSales.slice(0, limit).map(([itemId, qty]) => {
            const item = getBarangById(itemId);
            return { item: item ? item.nama : 'Tidak Dikenal', quantity: qty };
        });
    };

    const getCategoryWithMostStock = () => {
        const categoryStockMap = {};
        dataBarang.forEach(item => {
            if (categoryStockMap[item.kategori_id]) {
                categoryStockMap[item.kategori_id] += item.kuantitas;
            } else {
                categoryStockMap[item.kategori_id] = item.kuantitas;
            }
        });

        let topCategory = null;
        let maxStock = 0;
        for (const catId in categoryStockMap) {
            if (categoryStockMap[catId] > maxStock) {
                maxStock = categoryStockMap[catId];
                topCategory = catId;
            }
        }
        return topCategory ? { name: getKategoriNama(topCategory), quantity: maxStock } : null;
    };

    const renderLaporan = () => {
        chartContainer.innerHTML = '';
        if (dataBarang.length === 0) {
            chartContainer.innerHTML = '<p class="placeholder-box">Tidak ada data barang untuk grafik.</p>';
            return;
        }

        // Agregasi stok per kategori untuk grafik
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
            const barPercentage = (kuantitas / maxStock) * 100; // maxStock from chart context
            const chartBar = document.createElement('div');
            chartBar.className = 'chart-bar';
            chartBar.innerHTML = `
                <div class="bar-label" title="${kategoriNama}">${kategoriNama}</div>
                <div class="bar-itself" style="width: ${barPercentage}%;">
                    ${kuantitas}
                </div>`;
            chartContainer.appendChild(chartBar);
        });

        // Render Statistik Baru
        totalNilaiStokElement.textContent = formatCurrency(calculateTotalStockValue());
        totalNilaiPenjualanElement.textContent = formatCurrency(calculateTotalSalesValue());
        totalKeuntunganKotorElement.textContent = formatCurrency(calculateTotalGrossProfit());

        const topSelling = getTopSellingItems();
        barangTerlarisList.innerHTML = '';
        if (topSelling.length > 0) {
            topSelling.forEach(item => {
                const li = document.createElement('li');
                li.textContent = `${item.item}: ${item.quantity} unit`;
                barangTerlarisList.appendChild(li);
            });
        } else {
            barangTerlarisList.innerHTML = '<li>Tidak ada data penjualan.</li>';
        }

        const topCategory = getCategoryWithMostStock();
        kategoriStokTerbanyakElement.textContent = topCategory ? `${topCategory.name} (${topCategory.quantity} unit)` : 'Tidak ada data.';
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
            const item = getBarangById(barangId);
            if (item) {
                modalBarangTitle.textContent = 'Edit Barang';
                barangIdInput.value = item.id;
                barangKodeInput.value = item.kode;
                barangNamaInput.value = item.nama;
                barangKuantitasInput.value = item.kuantitas;
                barangUnitInput.value = item.unit;
                barangHargaBeliInput.value = item.buy_price; // New
                barangHargaJualInput.value = item.sell_price; // New
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

    // --- FUNGSI MODAL TRANSAKSI ---
    const bukaModalTransaksi = (transaksiId = null) => {
        modalTransaksi.classList.remove('hidden');
        formTransaksi.reset();
        transaksiIdInput.value = '';
        modalTransaksiTitle.textContent = 'Tambah Transaksi Baru';

        // Populate barang select
        transaksiBarangSelect.innerHTML = dataBarang.map(item => `<option value="${item.id}">${item.nama}</option>`).join('');
        if (dataBarang.length === 0) {
            transaksiBarangSelect.innerHTML = '<option value="">Tambahkan Barang Dulu</option>';
            transaksiBarangSelect.disabled = true;
        } else {
            transaksiBarangSelect.disabled = false;
        }

        // Set default date to today
        transaksiTanggalInput.value = new Date().toISOString().slice(0, 10);

        if (transaksiId) {
            // Edit Transaksi (not fully implemented in prototype, just for structure)
            const trx = dataTransaksi.find(t => t.id === transaksiId);
            if (trx) {
                modalTransaksiTitle.textContent = 'Edit Transaksi';
                transaksiIdInput.value = trx.id;
                transaksiTipeSelect.value = trx.tipe;
                transaksiBarangSelect.value = trx.barang_id;
                transaksiJumlahInput.value = trx.jumlah;
                transaksiTanggalInput.value = trx.tanggal;
                transaksiCatatanInput.value = trx.catatan;
                transaksiBuktiPembayaranInput.value = trx.image_path;
            }
        }
    };

    const tutupModalTransaksi = () => modalTransaksi.classList.add('hidden');

    // --- CRUD BARANG ---
    const simpanBarang = (e) => {
        e.preventDefault();
        const id = barangIdInput.value;
        const kode = barangKodeInput.value;
        const nama = barangNamaInput.value;
        const kuantitas = parseInt(barangKuantitasInput.value);
        const unit = barangUnitInput.value;
        const buy_price = parseFloat(barangHargaBeliInput.value);
        const sell_price = parseFloat(barangHargaJualInput.value);
        const min_qty = parseInt(barangMinQtyInput.value);
        const kategori_id = barangKategoriSelect.value;
        const gambar = barangGambarInput.value;

        if (id) {
            // Edit Barang
            const index = dataBarang.findIndex(item => item.id === id);
            if (index !== -1) {
                const oldKuantitas = dataBarang[index].kuantitas;
                dataBarang[index] = { id, kode, nama, kuantitas, unit, buy_price, sell_price, min_qty, kategori_id, gambar };
                recordActivity(`Mengedit barang: ${nama}. Kuantitas berubah dari ${oldKuantitas} menjadi ${kuantitas}.`, id, 'EDIT_ITEM');
            }
        } else {
            // Tambah Barang
            const newId = generateUniqueId('BRG');
            dataBarang.push({ id: newId, kode, nama, kuantitas, unit, buy_price, sell_price, min_qty, kategori_id, gambar });
            recordActivity(`Menambahkan barang baru: ${nama} dengan kuantitas ${kuantitas}.`, newId, 'ADD_ITEM');
        }
        tutupModalBarang();
        tampilkanHalaman('barang');
    };

    const hapusBarang = (id) => {
        if (confirm('Apakah Anda yakin ingin menghapus barang ini?')) {
            const item = getBarangById(id);
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

    // --- CRUD TRANSAKSI ---
    const simpanTransaksi = (e) => {
        e.preventDefault();
        const id = transaksiIdInput.value;
        const tipe = transaksiTipeSelect.value;
        const barang_id = transaksiBarangSelect.value;
        const jumlah = parseInt(transaksiJumlahInput.value);
        const tanggal = transaksiTanggalInput.value;
        const catatan = transaksiCatatanInput.value;
        const image_path = transaksiBuktiPembayaranInput.value;

        if (!barang_id) {
            alert('Pilih barang untuk transaksi.');
            return;
        }

        const itemIndex = dataBarang.findIndex(item => item.id === barang_id);
        if (itemIndex === -1) {
            alert('Barang tidak ditemukan.');
            return;
        }

        let activityDesc = '';
        if (tipe === 'masuk') {
            dataBarang[itemIndex].kuantitas += jumlah;
            activityDesc = `Menambahkan ${jumlah} stok untuk ${getBarangNama(barang_id)} melalui transaksi masuk.`;
        } else if (tipe === 'keluar') {
            if (dataBarang[itemIndex].kuantitas < jumlah) {
                alert('Stok tidak mencukupi untuk transaksi keluar ini.');
                return;
            }
            dataBarang[itemIndex].kuantitas -= jumlah;
            activityDesc = `Mengurangi ${jumlah} stok untuk ${getBarangNama(barang_id)} melalui transaksi keluar.`;
        }

        if (id) {
            // Edit Transaksi (prototype only, actual logic more complex)
            const index = dataTransaksi.findIndex(trx => trx.id === id);
            if (index !== -1) {
                dataTransaksi[index] = { id, tipe, barang_id, jumlah, tanggal, catatan, image_path };
                recordActivity(`Mengedit transaksi untuk ${getBarangNama(barang_id)}.`, barang_id, 'EDIT_TRANSACTION');
            }
        } else {
            // Tambah Transaksi
            const newId = generateUniqueId('TRX');
            dataTransaksi.unshift({ id: newId, tipe, barang_id, jumlah, tanggal, catatan, image_path }); // Add to beginning
            recordActivity(activityDesc, barang_id, 'ADD_TRANSACTION');
        }

        tutupModalTransaksi();
        tampilkanHalaman('transaksi');
    };

    // --- EKSPOR DATA ---
    const eksporData = () => {
        const headerBarang = ['id', 'kode', 'nama', 'kuantitas', 'unit', 'buy_price', 'sell_price', 'min_qty', 'kategori_id', 'gambar'];
        const headerKategori = ['id', 'nama'];
        const headerTransaksi = ['id', 'tipe', 'barang_id', 'jumlah', 'tanggal', 'catatan', 'image_path'];
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

    // --- EVENT LISTENERS ---
    btnLogin.addEventListener('click', handleLogin);
    btnRegister.addEventListener('click', handleRegister);
    btnLogout.addEventListener('click', handleLogout);
    btnUpgradePremium.addEventListener('click', togglePremiumStatus);

    hamburgerIcons.forEach(icon => {
        icon.addEventListener('click', openSidebar);
    });

    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            tampilkanHalaman(link.dataset.page);
        });
    });

    btnCloseSidebar.addEventListener('click', closeSidebar);
    overlay.addEventListener('click', closeSidebar);

    // Add a button to open transaction modal in the Transaksi page header
    const transaksiPageHeader = document.querySelector('#transaksi .page-header');
    const btnTambahTransaksi = document.createElement('button');
    btnTambahTransaksi.id = 'btn-tambah-transaksi';
    btnTambahTransaksi.className = 'action-button';
    btnTambahTransaksi.textContent = 'Tambah';
    transaksiPageHeader.appendChild(btnTambahTransaksi);
    btnTambahTransaksi.addEventListener('click', () => bukaModalTransaksi());

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

    // Transaksi
    btnTutupModalTransaksi.addEventListener('click', tutupModalTransaksi);
    modalTransaksi.addEventListener('click', (e) => { if (e.target === modalTransaksi) tutupModalTransaksi(); });
    formTransaksi.addEventListener('submit', simpanTransaksi);

    // Laporan (Ekspor)
    btnEksporData.addEventListener('click', eksporData);

    // --- INISIALISASI ---
    checkAuthStatus(); // Cek status login saat halaman dimuat
});

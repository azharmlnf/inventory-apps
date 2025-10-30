/* FILE: script.js */

document.addEventListener('DOMContentLoaded', function() {
    console.log("Script v2.0 (Online) started.");

    // --- STATE APLIKASI ---
    let isLoggedIn = false;
    let isPremium = false;
    let currentUser = { email: 'user@example.com' }; // Dummy user

    // --- DATA DUMMY (akan diambil dari Appwrite) ---
    let dataKategori = [{ id: 'CAT001', nama: 'Elektronik' }];
    let dataBarang = [{ id: 'BRG001', kode: 'BRG001', nama: 'Buku Tulis', kuantitas: 85, unit: 'Pcs', harga: 5000, min_qty: 20, kategori_id: 'CAT001' }];
    let dataTransaksi = [{ id: 'TRX001', tipe: 'masuk', barang_id: 'BRG001', jumlah: 50, tanggal: '2023-10-27', catatan: 'Pembelian' }];
    let dataActivityLog = [{ id: 'ACT001', timestamp: '2023-10-27 14:21', description: 'Menambahkan 50 stok untuk Buku Tulis' }];

    // --- PEMILIHAN ELEMEN DOM ---
    const loginPage = document.getElementById('login-page');
    const appContainer = document.getElementById('app-container');
    const btnLoginGoogle = document.getElementById('btn-login-google');
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

    // --- FUNGSI UTAMA (Login, Navigasi, dll) ---
    function checkAuthStatus() {
        if (isLoggedIn) {
            loginPage.classList.add('hidden');
            appContainer.classList.remove('hidden');
            userEmailElement.textContent = currentUser.email;
            tampilkanHalaman('dashboard');
            updatePremiumUI();
        } else {
            loginPage.classList.remove('hidden');
            appContainer.classList.add('hidden');
        }
    }

    function handleLogin() {
        console.log("Simulating Google Login...");
        isLoggedIn = true;
        currentUser.email = 'pengguna.baru@google.com';
        alert('Login berhasil!');
        checkAuthStatus();
    }

    function handleLogout() {
        if (confirm('Apakah Anda yakin ingin logout?')) {
            console.log("Logging out...");
            isLoggedIn = false;
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
        // Fungsi render spesifik bisa dipanggil di sini jika perlu refresh data
        if (pageId === 'dashboard') renderDashboard();
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
    }

    function togglePremiumStatus() {
        isPremium = !isPremium;
        alert(isPremium ? 'Anda sekarang Premium!' : 'Anda kembali ke status Gratis.');
        updatePremiumUI();
    }

    // --- RENDER FUNCTIONS (Contoh untuk Dashboard) ---
    const renderDashboard = () => {
        // Logika untuk mengambil data dari Appwrite dan merender dashboard
        console.log("Rendering dashboard with online data...");
        document.getElementById('total-barang').textContent = dataBarang.length;
        const stokAkanHabis = dataBarang.filter(item => item.kuantitas <= item.min_qty).length;
        document.getElementById('stok-akan-habis').textContent = stokAkanHabis;
        document.getElementById('transaksi-hari-ini').textContent = dataTransaksi.length;
    };

    // --- EVENT LISTENERS ---
    btnLoginGoogle.addEventListener('click', handleLogin);
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

    // Placeholder untuk tombol tambah di halaman lain
    document.getElementById('btn-tambah-barang')?.addEventListener('click', () => alert('Buka modal tambah barang (online)'));
    document.getElementById('btn-tambah-kategori')?.addEventListener('click', () => alert('Buka modal tambah kategori (online)'));
    document.getElementById('btn-ekspor-data')?.addEventListener('click', () => alert('Ekspor data dari Appwrite ke CSV'));

    // --- INISIALISASI ---
    checkAuthStatus(); // Cek status login saat halaman dimuat
});
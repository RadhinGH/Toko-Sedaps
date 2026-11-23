# CHANGELOG — Sedapss Cloth Web

Dokumen ini merangkum semua perubahan dari prototype awal hingga versi terbaru.

- **Original (v1)** — `rev_gatau yang keberapa.html` (1.473 baris)
- **v2** — `Sedapss-Web-Improved.zip` (2.107 baris) — bug fixes & fondasi
- **v3** — `Sedapss-Web-v3.zip` (3.570 baris + manifest.json + sw.js) — major upgrade
- **v3.0.3** — patch: 2 bug fix + 2 fitur Kelola Produk
- **v3.0.4** — patch: 2 bug fix + 3 perbaikan UX/aset (27-10-2026)

---

## [v3.0.4] — Patch (27-10-2026)

### Bug diperbaiki
1. **[FIX] Rasio foto di panel detail produk** — foto baju tampil "aneh" karena `object-cover` + `h-full` dalam container tinggi tetap MEMOTONG (crop) foto potrait. Diganti `object-contain` + `h-auto` + `max-h-[420px]`: foto kini tampil **utuh tanpa distorsi** (letterbox di atas latar abu-abu). Terverifikasi visual: baju tampil utuh, rasio normal.
2. **[FIX] Margin PDF terpotong (laporan + invoice)** — node export lama selebar 794px dipaksa masuk area konten A4 selebar 190mm (≈718px) sehingga skala tidak 1:1 + sensitif zoom browser → margin tampak tidak sesuai & konten terpotong. Perbaikan: node export selebar **tepat 718px** (skala 1:1 dengan 190mm), `windowWidth: 718` (kebal zoom), dan pagebreak `['css','legacy']` (tabel panjang mengalir ke halaman berikutnya, tidak terpotong). Bukti matematis dari PDF asli: gambar terpasang **tepat 190.0mm** di posisi x=**10.0mm** (margin kiri presisi), MediaBox tepat A4 210×297mm. Uji stres 49 order → 2 halaman penuh tanpa konten hilang; verifikasi visual VLM: tidak ada yang terpotong, margin seimbang, semua tabel lengkap. Invoice ikut difix (190mm presisi, 1 halaman).

### Perbaikan UX
3. **[FIX] Wishlist dipisah per akun** — dulu wishlist global (satu untuk semua): admin & akun baru melihat isi wishlist yang sama dengan akun customer. Kini tersimpan per username (`wishlists: { username: [id] }`): akun baru & admin mulai dari wishlist kosong; wishlist lama otomatis menjadi milik akun demo `siti`; menghapus produk membersihkannya dari wishlist semua akun; belum login → diminta login dulu.
4. **[FIX] Tombol "Simpan Stok" eksplisit** — ubah angka stok di Kelola Produk tidak lagi langsung tersimpan diam-diam. Perubahan menandai kartu: tombol **Simpan Stok** menyala oranye + label "belum disimpan" + tombol **Batal** + pratinjau total oranye. Stok baru benar-benar tersimpan saat tombol ditekan (dengan toast konfirmasi "X menjadi Y pcs").
5. **[FIX] Nama file foto profesional** — semua 30+ file `WhatsApp Image 2026-09-21 at ...` di-rename sesuai produk (mis. `floral-blue-cardigan.jpeg`, `twin-rose-cardigan.jpeg`; video hero jadi `hero-sedapss-video.mp4`). Data user lama tetap jalan via peta rename otomatis (`IMG_RENAME_MAP`) yang diterapkan saat load (produk + galeri + cart). 8 file tak terpakai (0 referensi, 1 di antaranya duplikat persis) dihapus dari paket. Cache SW dinaikkan ke `v3-0-4`.

### Validasi v3.0.4 (browser otomatis, semua PASS)
1. Fresh seed: 25/25 foto termuat dengan nama baru; poster & video hero OK ✓
2. Modal detail: `object-fit: contain` aktif, foto utuh & rasio normal (verifikasi VLM) ✓
3. Wishlist: siti 4 item (seed miliknya) / akun baru 0 / admin 0 terpisah / toggle akun baru tidak menyentuh milik siti ✓
4. Simpan Stok: ubah input TIDAK auto-save; tombol oranye + Batal muncul; Batal memulihkan nilai; Simpan menyimpan + badge kembali normal ✓
5. Migrasi DB lama: nama file WhatsApp → nama baru (produk, galeri, cart); wishlist global lama → milik siti ✓
6. PDF stres 49 order: 2 halaman terisi penuh, gambar tepat 190mm di x=10mm, MediaBox A4 presisi ✓ + render visual: margin aman ≥10mm semua sisi, tidak blank ✓
7. Invoice PDF: 190mm presisi, 1 halaman, tidak blank ✓
8. Print (tombol Cetak): 1 halaman, teks asli (bukan gambar) ✓

---

## [v3.0.3] — Patch (27-10-2026)

### Bug diperbaiki
1. **[FIX] Export PDF blank** — tombol "Unduh PDF" pada laporan menghasilkan PDF kosong. Akar masalah: `#print-area` bergaya `position:fixed; left:-10000px`; clone yang dibuat html2pdf tetap terkena CSS itu sehingga ter-render DI LUAR area capture (canvas kosong → PDF 3 KB tanpa konten). Solusi: export sekarang memakai **node detached** (`buildExportNodeForPDF`) yang tidak pernah menempel di DOM sehingga bebas dari CSS offscreen. Hasil uji: PDF 314 KB, 1 halaman, konten penuh. Fix yang sama diterapkan ke **invoice PDF** (146 KB, tidak blank).
2. **[FIX] Cetak 8 halaman (1 isi + 7 kosong)** — CSS print lama memakai `visibility:hidden` yang hanya menyembunyikan tapi **tetap memakan ruang layout**, sehingga seluruh aplikasi (header, hero, grid produk, footer) ikut terpaginasi jadi 7 halaman kosong. Solusi: `body > *:not(#print-area) { display:none }` — hanya area laporan yang tercetak. Hasil uji print-to-PDF: tepat 1 halaman.
3. **[FIX] Pesanan bocor antar akun** — "Pesanan Saya" dulu menampilkan semua order tanpa username (order demo/walk-in) ke SEMUA akun, termasuk akun baru. Solusi: filter ketat per akun (`o.username === currentUser.username`). Akun baru = bersih ("Belum ada pesanan aktif"). Order demo milik Siti dipetakan ke akun demo `siti`; order walk-in lain hanya muncul di sisi admin/laporan. Normalisasi otomatis juga diterapkan saat load DB lama.

### Fitur baru
4. **[FITUR] Urutkan produk di Kelola Produk** — dropdown sort: stok paling tipis (kritis dulu) / stok paling tebal / harga termahal / termurah / paling laris / nama A-Z / Z-A, plus checkbox **"Hanya stok kritis (< 5)"** dan label jumlah produk tampil (mis. "2 dari 25 produk ditampilkan"). Kartu dengan stok kritis diberi border oranye + badge **KRITIS**.
5. **[FITUR] Peringatan stok menipis interaktif** — di ringkasan dashboard, tiap peringatan kini memakai **foto produk** (+ overlay "HABIS" untuk stok 0) dan **bisa diklik**: otomatis membuka tab Kelola Produk, mengurutkan stok dari yang paling tipis, lalu **menyorot kartu produknya** (highlight oranye + auto-scroll).

### Validasi v3.0.3 (8 skenario, semua PASS via browser otomatis)
1. Akun baru `budites` → 0 pesanan, modal tampil "Belum ada pesanan aktif" ✓
2. Login `siti` → hanya 3 pesanan miliknya, semua `username:'siti'` ✓
3. Low stock: kartu peringatan tampil dengan foto termuat + overlay HABIS ✓
4. Klik kartu peringatan → tab Kelola Produk terbuka, sort otomatis stock-asc, kartu tersorot ✓
5. Semua mode sort + filter kritis + label jumlah ✓
6. Export PDF baru: 314 KB / 1 JPEG / 1 halaman vs cara lama 3 KB / 0 JPEG (blank) — fix terbukti ✓
7. Print-to-PDF: 1 halaman (sebelumnya 8) ✓
8. Invoice PDF: 146 KB tidak blank ✓ + normalisasi DB v3.0.2 lama setelah reload ✓

---

## [v3] — Major Upgrade (27-10-2026)

> Eksekusi 15 improvement hasil audit (QRIS / #3 di-skip sesuai permintaan — masih prototype).

### Auth & Keamanan
- **[v3-1] Auth nyata**: register multi-user + login + logout. Password disimpan sebagai **hash** (SHA-256 saat dijalankan via server, fallback hash lokal saat file://), bukan plain-text lagi.
- **[v3-2] Anti-XSS**: seluruh input user (nama produk, deskripsi, ulasan, alamat, nama akun, dll) di-escape sebelum dirender via `escapeHtml()` — sudah dites dengan payload XSS saat register, tidak tereksekusi.

### Kelola Produk (Admin)
- **[v3-4] CRUD lengkap**: tambah, **edit** (ubah nama/harga/HPP/kategori/deskripsi/ganti foto), dan **hapus** produk — sebelumnya hanya bisa tambah + update stok.
- **[v3-5] Varian ukuran**: S/M/L (Women) dan M/L/XL (Men) dengan **stok terpisah per ukuran**. Wajib pilih ukuran saat checkout. Cart & order tersimpan per kombinasi (produk, ukuran).

### Alur Pembayaran & Order
- **[v3-6] Upload bukti bayar** (opsional, maks 2MB, tersimpan base64) + tab **Verifikasi Pembayaran** untuk admin: setujui / tolak + zoom bukti. Stok otomatis dikembalikan saat order ditolak.
- **[v3-9] Ongkir dinamis**: 54 kota (3 zona) × 3 kurir × berat paket per produk (kg dibulatkan ke atas) — tidak flat per kurir lagi. Contoh hasil test: Medan Rp46.000 vs Karawang Rp18.000 untuk paket 1,2 kg.
- **Order flow baru**: `Menunggu Verifikasi` → `Diproses` → `Dalam Pengiriman` → `Tiba di Tujuan` (atau `Dibatalkan`). Stok dipotong (reserved) saat order dibuat.
- **[v3-8] Invoice customer**: tombol unduh PDF / cetak dari halaman "Pesanan Saya".

### Laporan
- **[v3-10] Laporan laba lebih detail**: top 5 produk terlaris, omzet per kategori (Women vs Men), **perbandingan delta % vs periode sebelumnya**, biaya operasional bulanan (sewa/gaji/listrik/lain), laba bersih setelah operasional. Export PDF & Cetak tetap tersedia.

### Pengalaman Customer
- **[v3-7] Wishlist**: simpan produk favorit (ikon hati) + modal daftar wishlist.
- **[v3-11] Mobile UX**: bottom navigation bar 5 item (ala Shopee/Tokopedia).
- **[v3-12] Galeri multi-foto** produk (isikan beberapa nama file dipisah koma saat tambah/edit produk).
- **[v3-13] Produk terkait** di halaman detail produk.
- **[v3-14] Customer service**: tombol WhatsApp mengambang.
- **[v3-16] Analitik internal**: hitungan view per produk + conversion rate (terjual/views) di dashboard admin.

### Platform
- **[v3-15] PWA**: `manifest.json` + `sw.js` (network-first untuk HTML, cache-first untuk gambar, cache busting v3-0-2). Bisa di-install seperti aplikasi & dibuka offline — butuh dijalankan via server lokal (`python -m http.server 8080`).
- **Migrasi data otomatis** dari `sedapss_db_v2` ke `sedapss_db_v3`.

### Bug ditemukan & diperbaiki selama development v3
1. Quote hilang di `deltaLabel` (laporan perbandingan periode).
2. `refreshSizeCheckboxes` tidak dipanggil saat init.
3. `seedDemoOrders` crash saat katalog v2 custom (produk demo sudah diedit/dihapus).
4. Bukti bayar tidak tersimpan bila upload dilakukan setelah halaman payment terbuka.
5. Service worker cache-first menahan update HTML (diperbaiki jadi network-first).

### Validasi v3
- 15+ skenario test otomatis via agent-browser PASS, zero console error: login, register (+XSS payload), multi-item checkout 3 produk beda ukuran, ongkir 2 kota, upload bukti, approve & reject (stok balik), CRUD produk, laporan bulanan (12 order, delta %, chart), invoice & report generator, persistence reload, migrasi v2, fresh seed.

---

## [v2] — Bug Fixes & Fondasi (Sedapss-Web-Improved.zip)

### Bug fatal diperbaiki
1. **`showToast()` dipanggil 20x tapi tidak pernah didefinisikan** → ReferenceError yang merusak semua flow (login prompt, add-to-cart, konfirmasi bayar). Ditambahkan implementasi toast lengkap + container.
2. **`renderCartItems()` menghancurkan elemen `#empty-cart-msg` saat render** → transaksi kedua `openCart()` TypeError → cart macet total. *Inilah bug "tidak bisa checkout" yang dilaporkan.*
3. **Tanpa persistensi localStorage** → semua data hilang saat refresh.
4. **Order tanpa timestamp** → tidak bisa dibuat laporan per periode.
5. **Laba dihitung 35% dari omzet (termasuk ongkir)** → tidak akurat.

### Fitur baru v2
- Tab Admin **"Laporan Laba"**: mode Harian/Bulanan, 8 kartu metrik (omzet, HPP, laba bersih, ongkir, kas masuk, jumlah transaksi, item terjual, rata-rata laba), grafik batang laba per hari, tabel transaksi.
- **Export PDF asli** via html2pdf.js (A4, margin rapi, kolom tanda tangan) + tombol Cetak (window.print dengan `@page A4`).
- **Sistem HPP per produk** (25 produk + form tambah katalog + preview laba/pcs).
- **Persistensi localStorage penuh** (produk, stok, order, cart, sesi login).
- Seed 12 transaksi demo tersebar 42 hari + tombol reset data transaksi.
- Ringkasan pesanan di checkout (subtotal + ongkir + total).
- Re-validasi stok saat bayar, guard double-click bayar, tombol logout, search mobile, ESC close modal, badge NEW.
- Validasi: 18 smoke test points PASS, zero console error.

---

## [v1] — Original (baseline)

Prototype awal `rev_gatau yang keberapa.html`. Sumber asli tidak diubah, disimpan di folder `upload/`.

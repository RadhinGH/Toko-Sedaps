# SEDAPSS CLOTH — Web Toko v4 (Database Online)

Toko online pakaian rajut "Sedapss Cloth": satu halaman web (`index.html`) dengan data tersimpan di
**Supabase** (database, login, penyimpanan foto). Pesanan dari HP pembeli langsung masuk ke panel admin
di perangkat mana pun.

> Panduan setup lengkap langkah demi langkah: **[SETUP-SUPABASE.md](SETUP-SUPABASE.md)**

---

## Isi Folder

| File / folder | Fungsi |
|---|---|
| `index.html` | Seluruh tampilan & logika web (katalog, keranjang, checkout, akun, panel admin) |
| `config.js` | URL & publishable key Supabase |
| `manifest.json`, `sw.js` | PWA (bisa di-install seperti aplikasi) |
| `media/` | Foto produk awal (`*.jpeg`), video & poster hero (`hero-sedapss-video.mp4`, `hero-sedapss-poster.jpeg`), logo (`logo.jpeg`), QRIS (`qris-sedapss.png`, `qris-sedapss-poster.jpg`) |
| `supabase/01-schema.sql` | Tabel, aturan akses (RLS), fungsi pesanan, storage bukti bayar |
| `supabase/02-seed-products.sql` | 25 produk awal + harga modal |
| `supabase/03-make-admin.sql` | Menjadikan sebuah akun sebagai admin |
| `supabase/04-product-images.sql` | Storage untuk upload foto produk dari panel admin |
| `supabase/05-profile-fields.sql` | Kolom HP / alamat / kota di profil + fungsi ubah profil |
| `supabase/06-auto-cancel-orders.sql` | Batal otomatis pesanan tanpa bukti bayar (> 24 jam) + jadwal pg_cron |
| `supabase/07-couriers-pickup.sql` | Pilihan pengiriman: JNE, GoSend (khusus Karawang), Ambil di Tempat |
| `supabase/08-demo-data.sql` | *(opsional)* Pesanan contoh 60 hari (`#DEMO-…`) untuk mencoba laporan & panel admin |
| `supabase/09-hapus-demo-data.sql` | Menghapus semua pesanan demo — jalankan sebelum toko dibuka |
| `media/qris-sedapss.png` | Kode QR QRIS toko (NMID ID1026508551904) yang tampil di halaman pembayaran |
| `media/qris-sedapss-poster.jpg` | Poster QRIS lengkap (untuk dicetak), tidak dipakai di web |
| `index-v3-localstorage-backup.html` | Cadangan versi lama (data di browser), tidak dipakai lagi |

## Setup Singkat

1. Di Supabase **SQL Editor**, jalankan berurutan: `01` → `02` → `04` → `05` → `06` → `07`.
2. Isi `config.js` dengan **Project URL** dan **Publishable key** (Project Settings → API).
   Jangan pernah isi dengan `service_role` / secret key.
3. Jalankan web:
   ```
   python -m http.server 8080
   ```
   lalu buka `http://localhost:8080` (atau double-click `index.html` untuk uji cepat).
4. Daftar akun pemilik toko di web, lalu jalankan `03-make-admin.sql` dengan username akun itu.
5. Di Supabase **Authentication → URL Configuration**, isi **Site URL** dengan alamat web kamu, dan
   tambahkan alamat yang sama (plus `http://localhost:8080/**` untuk uji lokal) di **Redirect URLs**
   agar link **Lupa password** kembali ke web ini.

## Fitur

### Pembeli
- Katalog dengan filter kategori (Women / Men), tipe, pencarian, dan urutan harga / nama / terlaris.
- Detail produk: galeri multi-foto, zoom, pilih ukuran, ulasan pembeli, produk terkait.
- Daftar & login dengan **email + password** (Supabase Auth).
- **Lupa password**: link reset dikirim ke email, lalu pembeli membuat password baru langsung di web.
- **Profil Saya**: lihat & ubah username, nama, nomor HP, kota, alamat. Data ini mengisi otomatis form checkout.
- Wishlist per akun, keranjang (tersimpan di perangkat).
- Checkout: ongkir dihitung dari kota (3 zona), berat paket, dan pilihan pengiriman:
  **JNE Express** (semua kota), **GoSend Instant** (hanya muncul untuk tujuan Karawang), dan
  **Ambil di Tempat** (gratis ongkir, alamat opsional). Alamat toko untuk pengambilan bisa diisi di
  konstanta `STORE_PICKUP_ADDRESS` di `index.html`.
- Bayar dengan **QRIS asli toko** (bisa diperbesar & disimpan ke galeri), nominal diisi manual sesuai total tagihan.
- Upload bukti bayar (otomatis dikompres), lacak status pesanan, konfirmasi barang diterima, beri ulasan.
- Unduh / cetak invoice PDF.
- Bottom navigation di HP, tombol WhatsApp CS, tombol **Esc** menutup jendela pop-up.

### Admin
- Login lewat form **Masuk Akun** yang sama; akun admin otomatis membuka panel admin.
- Ringkasan: omzet, laba, jumlah transaksi, produk terlaris, produk paling dilihat, stok menipis.
- Verifikasi pembayaran: lihat bukti transfer, **Setujui** atau **Tolak** (stok dikembalikan otomatis).
- Proses kirim pesanan.
- Tambah / edit / hapus produk dengan **upload foto langsung** (bisa banyak foto, pilih foto utama).
  Foto yang dibuang saat edit, atau milik produk yang dihapus, ikut terhapus dari Storage.
- Kelola stok per ukuran (tombol **Simpan Stok**).
- Laporan laba harian / bulanan: kartu **laba bersih** + margin, bar **"ke mana omzet pergi"**
  (laba bersih / modal / biaya operasional), **grafik tren omzet & laba kotor per hari**
  (bisa di-hover, ada tabelnya), top produk, porsi kategori, perbandingan periode, unduh PDF / cetak
  (grafik ikut masuk ke PDF).

## Alur Pesanan

Untuk **Ambil di Tempat**, status di database sama, hanya labelnya berbeda:
"Dalam Pengiriman" tampil sebagai **Siap Diambil**, "Tiba di Tujuan" sebagai **Sudah Diambil**.

```
Menunggu Verifikasi → Diproses → Dalam Pengiriman → Tiba di Tujuan
        └──────────→ Dibatalkan (admin menolak, atau tanpa bukti bayar > 24 jam; stok dikembalikan)
```

- Stok dipotong saat pesanan dibuat; dikembalikan ke **ukuran yang sama** jika ditolak / batal otomatis.
- Batal otomatis dicek tiap 15 menit oleh `pg_cron` (lihat `06-auto-cancel-orders.sql`). Pesanan yang
  sudah ada bukti bayarnya **tidak** dibatalkan otomatis — tetap menunggu keputusan admin.
- Angka **terjual** baru bertambah saat admin **menyetujui** pembayaran.

## Keamanan

- Harga, ongkir, dan stok **dihitung ulang di server** (`place_order`) — tidak bisa diubah dari browser.
- Stok dipotong secara atomik: dua pembeli tidak bisa membeli stok terakhir yang sama.
- Harga modal (HPP) dan laba hanya bisa dibaca admin.
- Role admin hanya bisa diberikan lewat SQL Editor; pelanggan hanya bisa mengubah profilnya sendiri.
- Bukti bayar disimpan di storage **privat** (hanya pemilik pesanan & admin, link sementara 1 jam).
- Semua teks dari pengguna di-escape sebelum ditampilkan (anti-XSS).

## Hosting

Web ini statis, jadi bisa di-upload ke hosting statis gratis (Cloudflare Pages, GitHub Pages, Netlify, Vercel).
Supabase sendiri **tidak** bisa dipakai untuk hosting halaman web.

Yang di-upload: `index.html`, `config.js`, `manifest.json`, `sw.js`, dan folder `media/` (logo, `qris-sedapss.png`, video, dan foto produk).
Tidak perlu di-upload: folder `supabase/`, `.claude/`, file backup, dan file `.md`.

## Catatan & Batasan

- QRIS yang dipakai adalah **QRIS statis**: pembeli mengetik nominal sendiri, dan pembayaran tetap
  dicek manual oleh admin lewat bukti bayar + mutasi rekening. Konfirmasi otomatis butuh payment
  gateway (Midtrans, Xendit, dll.) dan belum dipasang.
- Pembeli belum bisa menambahkan bukti bayar **setelah** pesanan dibuat; jika lupa upload, pesanan
  batal otomatis setelah 24 jam (atau hubungi CS via WhatsApp).
- Nomor WhatsApp CS ada di konstanta `WA_NUMBER` di `index.html`.
- Email reset password memakai pengirim bawaan Supabase (dibatasi beberapa email per jam). Untuk toko
  ramai, pasang SMTP sendiri di Supabase → Authentication → Emails → SMTP Settings.

## Riwayat Versi

- **v4.6** — Header kaca transparan di atas hero (berubah putih solid setelah digulir).
- **v4.5** — Warna grafik ikut tercetak, laporan PDF/cetak didesain ulang (sorotan, bar omzet,
  grafik batang ganda), hero memenuhi layar awal, animasi tombol "Belanja Sekarang", efek riak di
  semua tombol, kartu katalog muncul bertahap, perbaikan PDF tergeser.
- **v4.4** — Laporan laba didesain ulang + grafik tren & pembagian omzet (juga di PDF).
- **v4.3** — Ambil di Tempat (gratis ongkir), GoSend khusus Karawang, SiCepat dihapus
  (`07-couriers-pickup.sql`).
- **v4.2** — Perbaikan ikon (CDN Lucide lama 404), kartu produk lebih bersih (harga di bawah nama,
  stok hanya "Sisa N" saat menipis), hero baru + tombol Belanja Sekarang, filter tipe berupa chip,
  bahasa Indonesia seragam, aksen hitam di sisi pembeli, header HP lebih ringkas.
- **v4.1** — QRIS asli toko, lupa password, foto produk terhapus dari Storage saat dibuang/dihapus,
  batal otomatis pesanan tanpa bukti bayar (`06-auto-cancel-orders.sql`).

- **v4** — Pindah ke Supabase (database, login, storage), upload foto produk, Profil Saya,
  harga & stok dikunci di server, hapus akun demo dan link "Masuk Panel Admin".
- **v3.0.5** — Kompres bukti bayar, peringatan penyimpanan penuh, lazy-load gambar,
  tombol Esc, label aksesibilitas, perbaikan typo hero.
- **v3.0.4 dan sebelumnya** — Lihat `CHANGELOG.md` (versi dengan data di localStorage browser).

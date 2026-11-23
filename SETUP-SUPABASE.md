# Setup Database Supabase — Sedapss v4

Mulai v4, semua data toko (produk, akun, pesanan, wishlist, ulasan, bukti bayar) disimpan di **Supabase**,
bukan lagi di localStorage browser. Pesanan dari HP pembeli langsung masuk ke panel admin di perangkat mana pun.
Yang masih disimpan di browser hanya **isi keranjang** (per perangkat).

## 1. Jalankan SQL (sekali saja)
Buka proyek Supabase kamu → **SQL Editor** → **New query**. Tempel isi file, klik **Run**, berurutan:

1. `supabase/01-schema.sql` — tabel, aturan akses (RLS), fungsi transaksi, storage bukti bayar.
2. `supabase/02-seed-products.sql` — 25 produk awal + HPP.

Kalau muncul pesan *"destructive operation"*, itu karena ada `drop policy if exists` / `drop trigger if exists`. Aman, lanjutkan.

## 2. Isi `config.js`
Supabase Dashboard → **Project Settings → API** (atau tombol **Connect**):

```js
window.SEDAPSS_CONFIG = {
    SUPABASE_URL: 'https://xxxxxxxx.supabase.co',     // Project URL
    SUPABASE_KEY: 'sb_publishable_xxxxxxxxxxxx'        // Publishable key / anon key
};
```

⚠️ **Jangan** pernah isi dengan `service_role` / secret key.

## 3. Pengaturan Auth
**Authentication → Sign In / Providers → Email**:
- **Confirm email** menyala (default): pembeli harus klik link di email sebelum bisa login.
  Untuk uji coba cepat boleh dimatikan dulu, nyalakan lagi sebelum toko dibuka.
- **Authentication → URL Configuration → Site URL**: isi alamat web kamu
  (misalnya `http://localhost:8080` saat uji coba, atau domain asli saat online),
  supaya link konfirmasi email mengarah ke web yang benar.

## 4. Buat akun admin
1. Jalankan web (lihat langkah 5), klik **Masuk / Daftar → Daftar Sekarang**, buat akun untuk pemilik toko.
2. Buka `supabase/03-make-admin.sql`, ganti `username_kamu` dengan username tadi, jalankan di SQL Editor.
3. Keluar, lalu login lagi lewat **Masuk / Daftar** biasa dengan email & password akun itu — panel admin terbuka otomatis.
4. Jalankan juga `supabase/04-product-images.sql` agar admin bisa upload foto produk.

## 5. Menjalankan web
Web harus dibuka lewat server (bukan double-click file), contoh:

```
python -m http.server 8080
```

lalu buka `http://localhost:8080`. Untuk online, upload semua file ke hosting statis
(Netlify, Vercel, GitHub Pages, Cloudflare Pages) — tidak perlu server sendiri.

## Apa yang dijaga oleh database
- **Harga & ongkir dihitung ulang di server** (`place_order`) — pembeli tidak bisa mengubah harga dari browser.
- **Stok dipotong secara atomik** — dua pembeli tidak bisa membeli stok terakhir yang sama.
- **HPP / laba hanya bisa dibaca admin** (`product_costs`, `order_finance`).
- **Role admin tidak bisa diambil sendiri** — hanya bisa diset lewat SQL Editor.
- **Bukti bayar di bucket privat** — hanya pemilik pesanan & admin yang bisa melihat (link sementara 1 jam).
- Angka **terjual** baru bertambah saat admin **menyetujui** pembayaran, bukan saat pesanan dibuat.
- Pesanan ditolak → stok dikembalikan ke **ukuran yang sama**.

## Yang belum
- Pesanan "Menunggu Verifikasi" belum otomatis batal kalau admin tidak memproses (stok tetap tertahan).
- Foto produk masih file lokal di folder web (isi nama file saat tambah produk), belum upload ke Storage.
- QRIS masih gambar contoh; belum terhubung payment gateway.
- Cadangan versi lama (localStorage): `index-v3-localstorage-backup.html`.

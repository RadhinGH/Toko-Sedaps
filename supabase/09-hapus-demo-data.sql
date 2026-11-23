-- =====================================================================
--  SEDAPSS CLOTH — HAPUS SEMUA DATA DEMO
--  Menghapus hanya pesanan yang nomornya diawali #DEMO- (dibuat oleh 08-demo-data.sql).
--  Pesanan asli, produk, stok, akun, dan ulasan TIDAK tersentuh.
--  Jalankan sebelum toko dibuka untuk umum.
-- =====================================================================

-- Data keuangan (order_finance) ikut terhapus otomatis (ON DELETE CASCADE)
delete from public.orders where id like '#DEMO-%';

-- Cek: harus 0
select count(*) as sisa_pesanan_demo from public.orders where id like '#DEMO-%';

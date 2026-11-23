-- =====================================================================
--  SEDAPSS CLOTH — Batal otomatis pesanan yang tidak dibayar
--  Jalankan sekali di SQL Editor, setelah 01-schema.sql.
--
--  Aturan:
--    Pesanan "Menunggu Verifikasi" TANPA bukti bayar yang berumur lebih dari
--    24 jam -> otomatis "Dibatalkan" dan stok dikembalikan ke ukuran yang sama
--    (sama persis seperti admin menekan "Tolak").
--
--  Pesanan yang SUDAH ada bukti bayarnya TIDAK dibatalkan otomatis, karena
--  pembeli sudah transfer — admin tetap harus memeriksa & menyetujui/menolaknya.
--
--  Mengganti batas waktu: ubah '24 hours' di bagian JADWAL paling bawah,
--  lalu jalankan ulang file ini.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Fungsi pembatal (hanya bisa dijalankan oleh database / jadwal cron)
-- ---------------------------------------------------------------------
create or replace function public.expire_unpaid_orders(p_older_than interval default interval '24 hours')
returns integer
language plpgsql security definer set search_path = ''
as $$
declare
  v_order public.orders%rowtype;
  v_it    jsonb;
  v_prod  public.products%rowtype;
  v_size  text;
  v_qty   integer;
  v_count integer := 0;
begin
  for v_order in
    select * from public.orders
    where status = 'Menunggu Verifikasi'
      and payment_proof is null
      and created_at < now() - p_older_than
    order by created_at
    for update skip locked              -- jangan bentrok dengan admin yang sedang memproses
  loop
    for v_it in select value from jsonb_array_elements(v_order.items) loop
      v_qty  := (v_it->>'quantity')::integer;
      v_size := nullif(v_it->>'size', '');
      select * into v_prod from public.products where id = (v_it->>'id')::bigint for update;
      if not found then continue; end if;  -- produk sudah dihapus admin
      if v_prod.sizes is not null and v_size is not null and v_prod.sizes ? v_size then
        update public.products
          set sizes = jsonb_set(sizes, array[v_size], to_jsonb((sizes->>v_size)::integer + v_qty))
          where id = v_prod.id;
      elsif v_prod.sizes is null then
        update public.products set stock = stock + v_qty where id = v_prod.id;
      end if;
    end loop;
    update public.orders set status = 'Dibatalkan' where id = v_order.id;
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;

-- Tidak boleh dipanggil dari web (anon / pelanggan / admin) — hanya jadwal cron.
revoke execute on function public.expire_unpaid_orders(interval) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. JADWAL: cek setiap 15 menit (pakai ekstensi pg_cron bawaan Supabase)
--    Jika baris "create extension" error, aktifkan dulu lewat
--    Dashboard > Database > Extensions > cari "pg_cron" > Enable, lalu Run lagi.
-- ---------------------------------------------------------------------
create extension if not exists pg_cron with schema pg_catalog;

select cron.schedule(
  'sedapss-expire-unpaid-orders',       -- nama job (dijalankan ulang = jadwal diperbarui, tidak dobel)
  '*/15 * * * *',
  $$ select public.expire_unpaid_orders(interval '24 hours'); $$
);

-- ---------------------------------------------------------------------
-- Cek / kelola (opsional, jalankan terpisah):
--   select * from cron.job;                                          -- daftar jadwal
--   select * from cron.job_run_details order by start_time desc limit 10;  -- riwayat jalan
--   select public.expire_unpaid_orders();                            -- jalankan manual sekarang
--   select cron.unschedule('sedapss-expire-unpaid-orders');          -- matikan batal otomatis
-- ---------------------------------------------------------------------

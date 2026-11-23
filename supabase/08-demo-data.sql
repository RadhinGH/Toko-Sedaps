-- =====================================================================
--  SEDAPSS CLOTH — DATA DEMO (pesanan contoh untuk mencoba laporan & panel admin)
--  Jalankan di Supabase > SQL Editor > New query > Run.
--  Butuh: 01-schema.sql dan 02-seed-products.sql sudah dijalankan.
--
--  Yang dibuat:
--    - Pesanan contoh selama 60 hari terakhir (0-4 pesanan per hari, 1-3 produk per pesanan)
--    - Nomor pesanan diawali  #DEMO-  dan nama pembeli diawali  [DEMO]
--    - Harga & HPP diambil dari produk asli di database, jadi laporan laba realistis
--
--  AMAN untuk data asli:
--    - Stok produk, angka "terjual", rating, dan ulasan TIDAK diubah sama sekali
--    - Tidak ada pesanan demo berstatus "Menunggu Verifikasi", supaya tidak ikut
--      diproses batal-otomatis / tombol Tolak (yang akan MENAMBAH stok asli)
--    - Pesanan demo tidak terhubung ke akun pembeli mana pun (hanya terlihat di panel admin)
--
--  Menjalankan ulang file ini = data demo lama dihapus lalu dibuat ulang (tidak dobel).
--  Menghapus semua data demo: jalankan 09-hapus-demo-data.sql
--
--  Ubah jumlah hari di baris  v_days  di bawah jika ingin rentang lain.
-- =====================================================================

-- Bersihkan data demo sebelumnya (order_finance ikut terhapus otomatis / ON DELETE CASCADE)
delete from public.orders where id like '#DEMO-%';

do $$
declare
  v_days     constant integer := 60;     -- rentang hari ke belakang
  v_day      date;
  v_orders   integer;
  v_lines    integer;
  v_seq      integer := 0;
  v_prod     record;
  v_size     text;
  v_qty      integer;
  v_items    jsonb;
  v_costs    jsonb;
  v_summary  text[];
  v_subtotal integer;
  v_hpp      integer;
  v_weight   integer;
  v_city     text;
  v_courier  text;
  v_ship     integer;
  v_status   text;
  v_age      integer;
  v_id       text;
  v_name     text;
  v_today    constant date := (now() at time zone 'Asia/Jakarta')::date;   -- tanggal hari ini versi WIB
  cities     constant text[] := array['Karawang','Karawang','Karawang','Bekasi','Cikarang','Jakarta Timur','Depok','Bandung','Semarang','Surabaya','Medan','Makassar'];
  names      constant text[] := array['Dewi Lestari','Rizky Pratama','Siti Nurhaliza','Andi Saputra','Putri Ayu','Bima Aditya','Nadia Rahma','Fajar Nugroho','Intan Permata','Yoga Prasetyo','Maya Sari','Rendi Kurniawan','Ayu Wulandari','Dimas Ramadhan','Laras Kinanti'];
begin
  if not exists (select 1 from public.products) then
    raise exception 'Tabel produk masih kosong. Jalankan 02-seed-products.sql dulu.';
  end if;

  perform setseed(0.2026);   -- hasil acak yang sama setiap kali dijalankan

  for v_day in select generate_series(v_today - (v_days - 1), v_today, interval '1 day')::date loop
    -- akhir pekan sedikit lebih ramai
    v_orders := floor(random() * (case when extract(isodow from v_day) >= 6 then 6 else 4 end))::integer;

    for i in 1..v_orders loop
      v_seq      := v_seq + 1;
      v_id       := '#DEMO-' || lpad(v_seq::text, 4, '0');
      v_items    := '[]'::jsonb;
      v_costs    := '[]'::jsonb;
      v_summary  := '{}';
      v_subtotal := 0; v_hpp := 0; v_weight := 0;
      v_lines    := 1 + floor(random() * 3)::integer;   -- 1-3 produk

      for j in 1..v_lines loop
        select p.id, p.name, p.price, p.weight, p.sizes, coalesce(pc.cost, 0) as cost
          into v_prod
          from public.products p
          left join public.product_costs pc on pc.product_id = p.id
          order by random() limit 1;

        v_size := null;
        if v_prod.sizes is not null then
          select k into v_size from jsonb_object_keys(v_prod.sizes) k order by random() limit 1;
        end if;
        v_qty := case when random() < 0.8 then 1 else 2 end;

        v_items    := v_items || jsonb_build_object('id', v_prod.id, 'name', v_prod.name, 'price', v_prod.price, 'size', v_size, 'quantity', v_qty);
        v_costs    := v_costs || jsonb_build_object('id', v_prod.id, 'size', v_size, 'cost', v_prod.cost);
        v_summary  := v_summary || (v_prod.name || coalesce(' uk.' || v_size, '') || ' (x' || v_qty || ')');
        v_subtotal := v_subtotal + v_prod.price * v_qty;
        v_hpp      := v_hpp + v_prod.cost * v_qty;
        v_weight   := v_weight + v_prod.weight * v_qty;
      end loop;

      v_city := cities[1 + floor(random() * array_length(cities, 1))::integer];
      if v_city = 'Karawang' then
        v_courier := (array['JNE Express','GoSend Instant','Ambil di Tempat'])[1 + floor(random() * 3)::integer];
      else
        v_courier := 'JNE Express';
      end if;
      v_ship := case when v_courier = 'Ambil di Tempat' then 0 else public.calc_shipping(v_city, v_courier, v_weight) end;

      -- status mengikuti umur pesanan (tanpa "Menunggu Verifikasi", lihat catatan di atas)
      v_age := v_today - v_day;
      v_status := case
        when random() < 0.07 then 'Dibatalkan'
        when v_age <= 1 then 'Diproses'
        when v_age <= 4 then (array['Diproses','Dalam Pengiriman'])[1 + floor(random() * 2)::integer]
        else 'Tiba di Tujuan'
      end;

      v_name := names[1 + floor(random() * array_length(names, 1))::integer];

      insert into public.orders (id, user_id, customer, phone, address, city, courier, items, items_summary,
                                 subtotal, shipping_fee, weight, total, payment_proof, status, is_reviewed, created_at)
      values (v_id, null, '[DEMO] ' || v_name,
              '08' || lpad((floor(random() * 1e10))::bigint::text, 10, '0'),
              case when v_courier = 'Ambil di Tempat' then 'Ambil di tempat (tanpa pengiriman)' else 'Jl. Contoh Demo No. ' || (1 + floor(random() * 99))::integer end,
              v_city, v_courier, v_items, array_to_string(v_summary, ', '),
              v_subtotal, v_ship, v_weight, v_subtotal + v_ship, null, v_status, false,
              -- jam 08:00-21:00 WIB, tidak pernah lewat dari "sekarang"
              least(now(), (v_day + time '08:00' + (random() * interval '13 hours')) at time zone 'Asia/Jakarta'));

      insert into public.order_finance (order_id, hpp, profit, item_costs)
      values (v_id, v_hpp, v_subtotal - v_hpp, v_costs);
    end loop;
  end loop;

  raise notice 'Selesai: % pesanan demo dibuat.', v_seq;
end;
$$;

-- Ringkasan hasil (muncul di panel Results)
select count(*)                                         as jumlah_pesanan_demo,
       count(*) filter (where status <> 'Dibatalkan')  as tidak_batal,
       sum(subtotal) filter (where status <> 'Dibatalkan') as omzet_demo,
       min(created_at at time zone 'Asia/Jakarta')::date as dari,
       max(created_at at time zone 'Asia/Jakarta')::date as sampai
from public.orders
where id like '#DEMO-%';

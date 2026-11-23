-- =====================================================================
--  SEDAPSS CLOTH — Pilihan pengiriman baru
--  Jalankan sekali di SQL Editor, setelah 01-schema.sql.
--
--    - JNE Express     : semua kota (tarif per zona, sama seperti sebelumnya)
--    - GoSend Instant  : HANYA tujuan Karawang (Rp 25.000 + Rp 9.000 / kg berikutnya)
--    - Ambil di Tempat : semua kota, ongkir Rp 0
--    - SiCepat Reguler : DIHAPUS (pesanan lama yang memakai SiCepat tetap tersimpan apa adanya)
--
--  Harus sama dengan COURIERS di index.html.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Ongkir
-- ---------------------------------------------------------------------
create or replace function public.calc_shipping(p_city text, p_courier text, p_weight integer)
returns integer
language plpgsql immutable set search_path = ''
as $$
declare
  zones constant jsonb := '{
    "Karawang":1,"Cikarang":1,"Jakarta Barat":1,"Jakarta Pusat":1,"Jakarta Selatan":1,"Jakarta Timur":1,"Jakarta Utara":1,
    "Bekasi":1,"Depok":1,"Tangerang":1,"Tangerang Selatan":1,"Bogor":1,
    "Bandung":2,"Cirebon":2,"Sukabumi":2,"Semarang":2,"Yogyakarta":2,"Solo (Surakarta)":2,"Magelang":2,
    "Surabaya":2,"Malang":2,"Serang":2,"Cilegon":2,"Purwokerto":2,"Tegal":2,
    "Lampung":3,"Bengkulu":3,"Palembang":3,"Jambi":3,"Pangkal Pinang":3,
    "Medan":3,"Padang":3,"Pekanbaru":3,"Batam":3,"Banda Aceh":3,
    "Denpasar":3,"Mataram":3,"Kupang":3,
    "Makassar":3,"Manado":3,"Palu":3,"Kendari":3,"Gorontalo":3,
    "Balikpapan":3,"Banjarmasin":3,"Samarinda":3,"Tarakan":3,
    "Pontianak":3,"Banjarbaru":3,"Palangkaraya":3,
    "Jayapura":3,"Ambon":3,"Sorong":3,"Ternate":3
  }';
  couriers constant jsonb := '{
    "JNE Express":     {"base":[12000,18000,30000],"perKg":[6000,9000,16000]},
    "GoSend Instant":  {"base":[25000,25000,25000],"perKg":[9000,9000,9000]},
    "Ambil di Tempat": {"base":[0,0,0],"perKg":[0,0,0]}
  }';
  z  integer;
  c  jsonb;
  kg integer;
begin
  z  := coalesce((zones->>p_city)::integer, 2);
  c  := coalesce(couriers->p_courier, couriers->'JNE Express');
  kg := greatest(1, ceil(coalesce(p_weight, 0) / 1000.0)::integer);
  return (c->'base'->>(z - 1))::integer + (c->'perKg'->>(z - 1))::integer * (kg - 1);
end;
$$;

-- ---------------------------------------------------------------------
-- 2. Buat pesanan (sama dengan versi 01, hanya bagian validasi kurir yang berubah)
-- ---------------------------------------------------------------------
create or replace function public.place_order(
  p_items    jsonb,
  p_customer text,
  p_phone    text,
  p_address  text,
  p_city     text,
  p_courier  text,
  p_proof    text default null
)
returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_uid      uuid := auth.uid();
  v_item     jsonb;
  v_prod     public.products%rowtype;
  v_cost     integer;
  v_qty      integer;
  v_size     text;
  v_avail    integer;
  v_lines    jsonb := '[]'::jsonb;
  v_costs    jsonb := '[]'::jsonb;
  v_summary  text[] := '{}';
  v_subtotal integer := 0;
  v_hpp      integer := 0;
  v_weight   integer := 0;
  v_ship     integer;
  v_order    public.orders%rowtype;
begin
  if v_uid is null then raise exception 'Silakan login terlebih dahulu.'; end if;
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'Keranjang kosong.';
  end if;
  if jsonb_array_length(p_items) > 50 then raise exception 'Terlalu banyak item dalam satu pesanan.'; end if;
  if coalesce(trim(p_customer), '') = '' or coalesce(trim(p_address), '') = '' or coalesce(trim(p_city), '') = '' then
    raise exception 'Lengkapi data penerima & alamat.';
  end if;
  if regexp_replace(coalesce(p_phone, ''), '[[:space:]-]', '', 'g') !~ '^0[0-9]{8,13}$' then
    raise exception 'Format nomor HP tidak valid.';
  end if;
  if p_courier not in ('JNE Express', 'GoSend Instant', 'Ambil di Tempat') then
    raise exception 'Pilihan pengiriman tidak valid.';
  end if;
  if p_courier = 'GoSend Instant' and trim(p_city) <> 'Karawang' then
    raise exception 'GoSend Instant hanya tersedia untuk tujuan Karawang.';
  end if;
  if p_proof is not null and p_proof not like (v_uid::text || '/%') then
    raise exception 'File bukti bayar tidak valid.';
  end if;

  for v_item in select value from jsonb_array_elements(p_items) loop
    v_qty  := (v_item->>'qty')::integer;
    v_size := nullif(v_item->>'size', '');
    if v_qty is null or v_qty < 1 or v_qty > 99 then raise exception 'Jumlah barang tidak valid.'; end if;

    select * into v_prod from public.products where id = (v_item->>'id')::bigint for update;
    if not found then raise exception 'Ada produk di keranjang yang sudah tidak tersedia.'; end if;

    if v_prod.sizes is not null then
      if v_size is null or not (v_prod.sizes ? v_size) then
        raise exception 'Pilih ukuran untuk %.', v_prod.name;
      end if;
      v_avail := (v_prod.sizes->>v_size)::integer;
      if v_avail < v_qty then
        raise exception 'Stok % ukuran % tidak cukup (sisa %).', v_prod.name, v_size, v_avail;
      end if;
      update public.products
        set sizes = jsonb_set(sizes, array[v_size], to_jsonb(v_avail - v_qty))
        where id = v_prod.id;
    else
      v_size := null;
      if v_prod.stock < v_qty then
        raise exception 'Stok % tidak cukup (sisa %).', v_prod.name, v_prod.stock;
      end if;
      update public.products set stock = stock - v_qty where id = v_prod.id;
    end if;

    v_cost := coalesce((select pc.cost from public.product_costs pc where pc.product_id = v_prod.id), 0);

    v_lines    := v_lines || jsonb_build_object('id', v_prod.id, 'name', v_prod.name, 'price', v_prod.price, 'size', v_size, 'quantity', v_qty);
    v_costs    := v_costs || jsonb_build_object('id', v_prod.id, 'size', v_size, 'cost', v_cost);
    v_summary  := v_summary || (v_prod.name || coalesce(' uk.' || v_size, '') || ' (x' || v_qty || ')');
    v_subtotal := v_subtotal + v_prod.price * v_qty;
    v_hpp      := v_hpp + v_cost * v_qty;
    v_weight   := v_weight + v_prod.weight * v_qty;
  end loop;

  v_ship := public.calc_shipping(p_city, p_courier, v_weight);

  insert into public.orders (user_id, customer, phone, address, city, courier, items, items_summary,
                             subtotal, shipping_fee, weight, total, payment_proof)
  values (v_uid, left(trim(p_customer), 80), left(trim(p_phone), 20), left(trim(p_address), 500), left(trim(p_city), 60),
          p_courier, v_lines, array_to_string(v_summary, ', '),
          v_subtotal, v_ship, v_weight, v_subtotal + v_ship, p_proof)
  returning * into v_order;

  insert into public.order_finance (order_id, hpp, profit, item_costs)
  values (v_order.id, v_hpp, v_subtotal - v_hpp, v_costs);

  return to_jsonb(v_order);
end;
$$;

-- Hak akses tetap sama seperti 01-schema.sql
revoke execute on function public.calc_shipping(text, text, integer) from public;
grant  execute on function public.calc_shipping(text, text, integer) to anon, authenticated;
revoke execute on function public.place_order(jsonb, text, text, text, text, text, text) from public, anon;
grant  execute on function public.place_order(jsonb, text, text, text, text, text, text) to authenticated;

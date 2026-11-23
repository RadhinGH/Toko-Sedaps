-- =====================================================================
--  SEDAPSS CLOTH — Profil pelanggan: nomor HP, alamat, kota + ubah profil
--  Jalankan sekali di SQL Editor, setelah 01-schema.sql.
-- =====================================================================

alter table public.profiles add column if not exists phone   text;
alter table public.profiles add column if not exists address text;
alter table public.profiles add column if not exists city    text;

-- Ubah profil sendiri. Lewat fungsi (bukan UPDATE langsung) supaya kolom
-- "role" tidak pernah bisa diubah oleh pelanggan.
create or replace function public.update_my_profile(
  p_username text,
  p_name     text,
  p_phone    text,
  p_address  text,
  p_city     text
)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_uid      uuid := auth.uid();
  v_username text := lower(trim(coalesce(p_username, '')));
  v_phone    text := nullif(regexp_replace(coalesce(p_phone, ''), '[[:space:]-]', '', 'g'), '');
begin
  if v_uid is null then raise exception 'Silakan login terlebih dahulu.'; end if;
  if v_username !~ '^[a-z0-9_.]{3,20}$' then
    raise exception 'Username 3-20 karakter (huruf kecil/angka/_/.).';
  end if;
  if char_length(trim(coalesce(p_name, ''))) < 3 then raise exception 'Nama minimal 3 karakter.'; end if;
  if v_phone is not null and v_phone !~ '^0[0-9]{8,13}$' then
    raise exception 'Format nomor HP tidak valid (contoh: 081234567890).';
  end if;
  if exists (select 1 from public.profiles where username = v_username and id <> v_uid) then
    raise exception 'Username sudah dipakai, pilih yang lain.';
  end if;

  update public.profiles
     set username = v_username,
         name     = left(trim(p_name), 80),
         phone    = v_phone,
         address  = nullif(left(trim(coalesce(p_address, '')), 500), ''),
         city     = nullif(left(trim(coalesce(p_city, '')), 60), '')
   where id = v_uid;
end;
$$;

revoke execute on function public.update_my_profile(text, text, text, text, text) from public, anon;
grant  execute on function public.update_my_profile(text, text, text, text, text) to authenticated;

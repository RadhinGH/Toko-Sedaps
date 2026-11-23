-- =====================================================================
--  SEDAPSS CLOTH — Jadikan sebuah akun sebagai ADMIN
--  1. Daftar akun biasa dulu lewat web (tombol "Daftar Sekarang").
--  2. Ganti 'username_kamu' di bawah dengan username akun tersebut, lalu Run.
-- =====================================================================

update public.profiles
set role = 'admin'
where username = 'username_kamu';

-- Cek hasilnya:
select username, name, role from public.profiles order by created_at;

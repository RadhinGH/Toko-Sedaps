-- =====================================================================
--  SEDAPSS CLOTH — Isi katalog awal (25 produk)
--  Jalankan SETELAH 01-schema.sql. Aman dijalankan ulang (produk yang sudah ada dilewati).
--  Catatan: angka terjual / dilihat / rating dimulai dari 0 (data asli toko, bukan angka demo).
-- =====================================================================

insert into public.products (id, category, name, type, material, description, price, sizes, weight, images, is_new) values
 (1,  'women', 'Floral Blue Cardigan',        'Cardigan', 'Rajut Premium (Tebal & Halus)', 'Cardigan biru dengan motif bunga daisy yang cantik.',             110000, '{"S":5,"M":5,"L":5}', 320, '{media/floral-blue-cardigan.jpeg}', true),
 (2,  'women', 'Triangle Knit Polo',          'Polo',     'Rajut Cotton Blend',            'Sweater berkerah polo dengan motif segitiga minimalis.',          115000, '{"S":4,"M":4,"L":4}', 360, '{media/triangle-knit-polo.jpeg}', false),
 (3,  'women', 'Minimalist Flower Cardie',    'Cardigan', 'Rajut Akrilik Lembut',          'Cardigan coklat elegan dengan aksen satu bunga.',                 95000,  '{"S":7,"M":7,"L":6}', 400, '{media/minimalist-flower-cardie.jpeg}', false),
 (4,  'women', 'Ribbon Red Sweater',          'Sweater',  'Rajut Premium Hangat',          'Sweater merah merona dengan grafis pita krem.',                   105000, '{"S":3,"M":3,"L":2}', 440, '{media/ribbon-red-sweater.jpeg}', true),
 (5,  'women', 'Twin Rose Cardigan',          'Cardigan', 'Rajut Premium Blend',           'Cardigan kancing depan warna merah tua motif mawar.',             120000, '{"S":4,"M":3,"L":3}', 280, '{media/twin-rose-cardigan.jpeg}', true),
 (6,  'women', 'Abstract Line Art Sweater',   'Sweater',  'Rajut Tebal',                   'Sweater dengan desain line art abstrak.',                         99000,  '{"S":5,"M":5,"L":4}', 320, '{media/abstract-line-art-sweater.jpeg}', false),
 (7,  'women', 'Party Vibe Cardigan',         'Cardigan', 'Rajut Katun',                   'Cardigan coklat bertema musik dan pesta.',                        100000, '{"S":6,"M":6,"L":6}', 360, '{media/party-vibe-cardigan.jpeg}', false),
 (8,  'women', 'Typography Graphic Sweater',  'Sweater',  'Rajut Premium',                 'Sweater penuh statement tipografi streetwear.',                   110000, '{"S":3,"M":3,"L":3}', 400, '{media/typography-graphic-sweater.jpeg}', true),
 (9,  'women', 'Striped Polo Cardigan',       'Cardigan', 'Rajut Halus Ringan',            'Cardigan motif garis horizontal coklat putih.',                   95000,  '{"S":9,"M":8,"L":8}', 440, '{media/striped-polo-cardigan.jpeg}', true),
 (10, 'women', 'Blue Daisy Cardigan (Var)',   'Cardigan', 'Rajut Premium',                 'Varian lain cardigan biru motif daisy.',                          110000, '{"S":4,"M":3,"L":3}', 280, '{media/blue-daisy-cardigan-varian.jpeg}', false),
 (11, 'women', 'Rose Garden Maroon Knit',     'Sweater',  'Rajut Wool Halus',              'Koleksi sweater rajut merah maron bertema taman mawar.',          115000, '{"S":4,"M":4,"L":4}', 320, '{media/rose-garden-maroon-knit.jpeg}', false),
 (12, 'women', 'Choco Daisy Sweet Knit',      'Cardigan', 'Akrilik Ringan',                'Cardigan coklat hangat dengan bordir bunga lembut.',              98000,  '{"S":5,"M":5,"L":5}', 360, '{media/choco-daisy-sweet-knit.jpeg}', false),
 (13, 'women', 'Urban Chic Red Ribbon',       'Sweater',  'Cotton Knit',                   'Edisi spesial sweater pita merah bernuansa chic.',                112000, '{"S":3,"M":3,"L":2}', 400, '{media/ribbon-red-sweater.jpeg}', true),
 (14, 'men',   'Black Half-Zip Sweater',      'Zipper',   'Premium Knit Blend',            'Sweater hitam elegan dengan kerah half-zip.',                     115000, '{"M":4,"L":4,"XL":3}', 440, '{media/black-half-zip-sweater.jpeg}', true),
 (15, 'men',   'OUIOUI Emerald Hoodie',       'Hoodie',   'Heavy Cotton Knit',             'Hoodie hijau botol pekat dengan bordir ouioui.',                  120000, '{"M":3,"L":2,"XL":2}', 280, '{media/ouioui-emerald-hoodie.jpeg}', true),
 (16, 'men',   'New York 67 Crewneck',        'Sweater',  'Soft Knit Cotton',              'Crewneck warna krem tipografi NEW YORK 67.',                      105000, '{"M":6,"L":5,"XL":5}', 320, '{media/new-york-67-crewneck.jpeg}', false),
 (17, 'men',   'Abstract Face Knit Sweater',  'Sweater',  'Jacquard Knit',                 'Sweater hitam putih dengan motif rajut jacquard wajah abstrak.',  118000, '{"M":4,"L":3,"XL":3}', 360, '{media/abstract-face-knit-sweater.jpeg}', true),
 (18, 'men',   'Print Your Life Sweater',     'Sweater',  'Medium Weight Knit',            'Sweater rajut dengan motif teks besar PRINT YOUR LIFE.',          110000, '{"M":5,"L":4,"XL":4}', 400, '{media/print-your-life-sweater.jpeg}', false),
 (19, 'men',   'Track Line Zipper Jacket',    'Zipper',   'Sporty Knit Blend',             'Jaket rajut hitam dengan resleting penuh dan garis putih.',       120000, '{"M":3,"L":3,"XL":3}', 440, '{media/track-line-zipper-jacket.jpeg}', false),
 (20, 'men',   'Monochrome Print Back Knit',  'Sweater',  'Cotton Jacquard',               'Sweater rajut hitam motif artistik monokrom.',                    116000, '{"M":3,"L":3,"XL":2}', 280, '{media/monochrome-print-back-knit.jpeg}', true),
 (21, 'men',   'Dark Streetwear Crewneck',    'Sweater',  'Heavy Wool Blend',              'Crewneck streetwear edisi terbatas dengan grafis kontras.',       112000, '{"M":5,"L":5,"XL":4}', 320, '{media/dark-streetwear-crewneck.jpeg}', false),
 (22, 'men',   'Urban Half-Zip Classic',      'Zipper',   'Ribbed Knit',                   'Varian half-zip eksklusif untuk gaya harian urban.',              119000, '{"M":2,"L":2,"XL":2}', 360, '{media/black-half-zip-sweater.jpeg}', true),
 (23, 'men',   'Forest Green OUIOUI',         'Hoodie',   'Thick Knit Fleece',             'Hoodie hijau hutan anti angin dan bertekstur lembut.',            120000, '{"M":4,"L":3,"XL":3}', 400, '{media/forest-green-ouioui.jpeg}', false),
 (24, 'men',   'NYC 67 Heritage Knit',        'Sweater',  'Cotton Blend',                  'Edisi heritage gaya collegiate New York.',                        108000, '{"M":5,"L":5,"XL":5}', 440, '{media/new-york-67-crewneck.jpeg}', false),
 (25, 'men',   'Sport Track Knit Jacket',     'Zipper',   'Sport Knit',                    'Jaket track rajut sporty performa tinggi.',                       120000, '{"M":4,"L":4,"XL":3}', 280, '{media/track-line-zipper-jacket.jpeg}', true)
on conflict (id) do nothing;

-- Harga modal (HPP) — hanya bisa dilihat admin
insert into public.product_costs (product_id, cost) values
 (1, 60000), (2, 63000), (3, 52000), (4, 58000), (5, 65000), (6, 54000), (7, 55000), (8, 60000), (9, 52000),
 (10, 60000), (11, 63000), (12, 53000), (13, 61000), (14, 63000), (15, 66000), (16, 58000), (17, 64000),
 (18, 60000), (19, 66000), (20, 63000), (21, 61000), (22, 65000), (23, 66000), (24, 59000), (25, 66000)
on conflict (product_id) do nothing;

-- Lanjutkan nomor ID otomatis setelah ID 25
select setval(pg_get_serial_sequence('public.products', 'id'), (select max(id) from public.products));

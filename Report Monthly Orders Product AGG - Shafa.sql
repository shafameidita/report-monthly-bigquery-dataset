Report Monthly Orders Product AGG
Shafa Salzabila Meidita

-- Check Necessary Data
SELECT 
    * 
FROM 
    `bigquery-public-data.thelook_ecommerce.order_items` 
LIMIT 
    100;

SELECT 
    * 
FROM 
    `bigquery-public-data.thelook_ecommerce.products` 
LIMIT 
    100;

SELECT 
    * 
FROM 
    `bigquery-public-data.thelook_ecommerce.users` 
LIMIT 
    100;

Penjelasan:
Select * : Select all data 
from  bigquery-public-data.thelook_ecommerce : akses data dari dataset thelook_ecommerce (bagian dari bigquery-public-data)
bigquery-public-data.thelook_ecommerce apabila ditambahkan (.order_items, .products, atau .users) maka menanndakan tabel mana yang mau diakses (teble order_items, products, atau users)

-- Check the timestamp 
SELECT 
  *
FROM 
  `bigquery-public-data.thelook_ecommerce.orders` 
order by 
  created_at desc
LIMIT 100;

Penjelasan: 
pada tahap ini, saya mau memastikan data order terbaru yang bisa diakses, dan didapatkan bahwa data ini masih terus update per hari ini (11-08-2024), maka untuk membuat temporary tabel penjualan produk saya akan memakai data pada bulan sebelumnya yaitu Juli 2024

-- Temporary table for all products in July 2024 (Do in Bigquery)
SELECT 
  o.order_id, 
  o.user_id,
  CONCAT(u.first_name, ' ', u.last_name) AS user_name,  
  u.email as user_email, 
  o.product_id,
  p.category, 
  p.name as product_name,
  p.brand, 
  o.status, 
  o.created_at, 
  o.sale_price
FROM 
  `bigquery-public-data.thelook_ecommerce.order_items` o
JOIN 
  `bigquery-public-data.thelook_ecommerce.products` p
ON 
  o.product_id = p.id
JOIN 
  `bigquery-public-data.thelook_ecommerce.users` u 
ON 
  o.user_id = u.id
  
WHERE 
  status like 'Complete'
  AND o.created_at BETWEEN '2024-07-01' AND '2024-07-31';

Penjelasan : 
1. Pada tahap ini saya membuat temporary tabel untuk penjualan seluruh produk yang berstatus Complete di bulan Juli 2024 
2. Namun karena data yang dipakai yaitu data publik di bigquery, saya tidak bisa membuat tabel baru pada dataset ini sehingga saya hanya melakukan Join pada beberapa tabel untuk mendapatkan data yang sekiranya dibutuhkan untuk mengetahui produk dengan penjualan terbesar pada bulan Juli 2024 
3. Tabel yang saya gunakan dalam analisis ini yaitu tabel order_items, products, dan users. 
4. saya melakukan join pada tabel products dan tabel users ke tabel order_items 
(From `bigquery-public-data.thelook_ecommerce.order_items` o : saya mengambil data dari tabel order_items dataset tersebut (sudah dijelaskan sebelumnya) dan saya inisialkan sebagai 'o' untuk memudahkan dan mempersingkat query )
(JOIN 
  `bigquery-public-data.thelook_ecommerce.products` p = saya menggabungkan tabel products (diinisialkan dengan p) ke tabel orders (o)
ON 
  o.product_id = p.id) = pada kolom yang sesuai (memiliki nilai yang sama, sama-sama id produk), pada tabel o namanya product_id, dan pada tabel p namanya id

5. saya melakukan hal yang sama juga antara tabel users dan tabel order_items

6. WHERE : ini merupakan tahap filtering
7. status like 'Complete' : saya mau hanya menampilkan data dengan status Complete
8. AND o.created_at BETWEEN '2024-07-01' AND '2024-07-31'; : dan saya hanya mau menampilkan pada data bulan Juli 2024


-- See the Top 10 Products in July 2024 
SELECT 
  product_id, 
  category, 
  brand, 
  product_name, 
  SUM(sale_price) AS total_sales
FROM 
  (SELECT 
    o.order_id, 
    o.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,  
    u.email as user_email, 
    o.product_id,
    p.category, 
    p.name as product_name,
    p.brand, 
    o.status, 
    o.created_at, 
    o.sale_price
  FROM 
    `bigquery-public-data.thelook_ecommerce.order_items` o
  JOIN 
    `bigquery-public-data.thelook_ecommerce.products` p
  ON 
    o.product_id = p.id
  JOIN 
    `bigquery-public-data.thelook_ecommerce.users` u 
  ON 
    o.user_id = u.id
  
  WHERE 
    o.status LIKE 'Complete'
    AND o.created_at BETWEEN '2024-07-01' AND '2024-07-30') 

GROUP BY 
  product_id, 
  category, 
  brand, 
  product_name
ORDER BY 
  total_sales DESC

Limit 10;

Penjelasan: 
1. ini merupakan query untuk menampilkan 10 data penjualan tertinggi pada bulan Juli 2024 
2. SELECT 
  product_id, 
  category, 
  brand, 
  product_name, 
  SUM(sale_price) AS total_sales
  pada tahap ini saya memilih kolom-kolom tertentu dan relevan untuk ditampilkan pada tabel data penjualan yang fokus pada produk, yaitu kolom 
  (product_id, 
  category, 
  brand, 
  product_name, 
  SUM(sale_price) AS total_sales) pada kolom sale_price, saya jumlahkan dan saya beri nama kolom penjualannya dengan nama total_sales 
3. Pada step From, saya meng-copy query sebelumnya karena saya mau dapatkan dan akses data dari output query tabel sebelumnya 
4. GROUP BY 
  product_id, 
  category, 
  brand, 
  product_name
  pada tahap ini saya mengeolompokan tabel pada kolom-kolom tersebut, sebelum nantinya saya urutkan berdasarkan penjualan tertinggi 
5. ORDER BY 
  total_sales DESC
  pada tahap ini saya mengurutkan data berdasarkan penjualan tertinggi (total_sales), DESC artinya urutannya dari yang terbesar/tertinggi 
6. Limit 10 : pada tahap ini saya membatasi hanya 10 data untuk menampilkan top 10 produk dengan penjualan terbesar pada Bulan Juli 2024

Notes : 
1. Apabila ingin membuat temporary table, dapat dilakukan di local komputer anda dengan mendownload datasetnya terlebih dahulu 
2. temporary tabelnya dapat dinamakan report_monthly_orders_product_agg, sesuai dengan arahan atau instruksi soal 
3. Berikut Query yang bisa anda pakai apabila anda mengakses data di local 
4. Untuk penjelasan kurang lebih sama. Perbedaannya hanya pada proses pembuatan tabel, sehingga bisa langsung diakses di query selanjutnya tanpa copy query


-- State the dataset 
use thelook_ecommerce

-- Check Necessary Data
SELECT 
    * 
FROM 
    order_items
LIMIT 
    100;

SELECT 
    * 
FROM 
    products
LIMIT 
    100;

SELECT 
    * 
FROM 
    users
LIMIT 
    100;


-- Check the timestamp 
SELECT 
  *
FROM 
  orders
order by 
  created_at desc
LIMIT 100;


-- Temporary table for all products in July 2024 (Do in Local (ex: MySQL))

CREATE OR REPLACE TABLE report_monthly_orders_product_agg AS
SELECT 
  o.order_id, 
  o.user_id,
  CONCAT(u.first_name, ' ', u.last_name) AS user_name,  
  u.email as user_email, 
  o.product_id,
  p.category, 
  p.name as product_name,
  p.brand, 
  o.status, 
  o.created_at, 
  o.sale_price
FROM 
  order_items o
JOIN 
  products p
ON 
  o.product_id = p.id
JOIN 
  users u 
ON 
  o.user_id = u.id
  
WHERE 
  status like 'Complete'
  AND o.created_at BETWEEN '2024-07-01' AND '2024-07-31';


-- See the Top 10 Products in July 2024 
SELECT 
  product_id, 
  category, 
  brand, 
  product_name, 
  SUM(sale_price) AS total_sales
FROM 
  report_monthly_orders_product_agg

GROUP BY 
  product_id, 
  category, 
  brand, 
  product_name
ORDER BY 
  total_sales DESC

Limit 10;






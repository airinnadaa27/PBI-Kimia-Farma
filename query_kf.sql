CREATE OR REPLACE TABLE `kimia-farma-x-rakamin-458710.kimia_farma.tabel_analisa` AS
SELECT
  t.transaction_id,
  DATE(t.date) AS date,
  t.branch_id,
  kc.branch_name,
  kc.kota,
  kc.provinsi,

  -- Rata-rata rating per cabang
  AVG(t.rating) OVER (PARTITION BY t.branch_id) AS rating_cabang,

  t.customer_name,
  t.product_id,
  p.product_name,
  t.price AS actual_price,
  t.discount_percentage,

  -- Persentase Gross Laba
  CASE
    WHEN t.price <= 50000 THEN 0.10
    WHEN t.price <= 100000 THEN 0.15
    WHEN t.price <= 300000 THEN 0.20
    WHEN t.price <= 500000 THEN 0.25
    ELSE 0.30
  END AS persentase_gross_laba,

  -- Nett Sales
  t.price * (1 - t.discount_percentage) AS nett_sales,

  -- Nett Profit
  (t.price * (1 - t.discount_percentage)) *
  CASE
    WHEN t.price <= 50000 THEN 0.10
    WHEN t.price <= 100000 THEN 0.15
    WHEN t.price <= 300000 THEN 0.20
    WHEN t.price <= 500000 THEN 0.25
    ELSE 0.30
  END AS nett_profit,

  t.rating AS rating_transaksi

FROM
  `kimia-farma-x-rakamin-458710.kimia_farma.kf_final_transaction` t
LEFT JOIN
  `kimia-farma-x-rakamin-458710.kimia_farma.kf_kantor_cabang` kc ON t.branch_id = kc.branch_id
LEFT JOIN
  `kimia-farma-x-rakamin-458710.kimia_farma.kf_product` p ON t.product_id = p.product_id;

-- Tabel top 5 cabang rating tinggi tapi rating transaksi rendah
CREATE OR REPLACE TABLE `kimia-farma-x-rakamin-458710.kimia_farma.top_5_rating_cabang_bingung` AS
WITH cabang_rating_summary AS (
  SELECT
    branch_id,
    branch_name,
    kota,
    provinsi,
    AVG(rating_cabang) AS avg_rating_cabang,
    AVG(rating_transaksi) AS avg_rating_transaksi
  FROM
    `kimia-farma-x-rakamin-458710.kimia_farma.tabel_analisa`
  GROUP BY
    branch_id, branch_name, kota, provinsi
)

SELECT *
FROM cabang_rating_summary
ORDER BY avg_rating_cabang DESC, avg_rating_transaksi ASC
LIMIT 5;

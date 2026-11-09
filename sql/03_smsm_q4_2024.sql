-- ARSIP, JANGAN DIJALANKAN ULANG.
-- Koreksi SMSM Q4 2024: selling_expense 171.906 -> 71.906 juta.
-- Dugaan/inferensi: salah ketik satu digit; dasar pengecekan = jumlah FY2024 dibandingkan laporan.
-- SMSM 2025 belum dicek ke laporan.
-- CREATE TABLE dan UPDATE dikomentari; SELECT dibiarkan karena hanya membaca.

SELECT period_date,
       revenue / 1000000.0         AS rev_juta,
       gross_profit / 1000000.0    AS gp_juta,
       selling_expense / 1000000.0 AS sell_juta,
       ga_expense / 1000000.0      AS ga_juta
FROM fact_peer_benchmark
WHERE ticker = 'SMSM'
  AND period_date BETWEEN '2024-01-01' AND '2024-12-31'
ORDER BY period_date;

-- CREATE TABLE bak_fact_peer_benchmark_20261027 AS
-- SELECT * FROM fact_peer_benchmark;

SELECT (SELECT COUNT(*) FROM bak_fact_peer_benchmark_20261027) AS n_bak,
       (SELECT COUNT(*) FROM fact_peer_benchmark)              AS n_asli;

-- UPDATE fact_peer_benchmark
-- SET selling_expense = 71906000000
-- WHERE ticker = 'SMSM'
--   AND period_date = '2024-12-31'
--   AND selling_expense = 171906000000;

SELECT SUM(revenue)         / 1000000.0 AS rev_juta,
       SUM(gross_profit)    / 1000000.0 AS gp_juta,
       SUM(selling_expense) / 1000000.0 AS sell_juta,
       SUM(ga_expense)      / 1000000.0 AS ga_juta
FROM fact_peer_benchmark
WHERE ticker = 'SMSM'
  AND period_date BETWEEN '2024-01-01' AND '2024-12-31';
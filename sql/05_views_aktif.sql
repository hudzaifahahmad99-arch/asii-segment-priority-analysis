-- 13 view aktif Project 7 (definisi dari pg_get_viewdef, dirapikan menjadi CREATE OR REPLACE VIEW).
-- Urutan = urutan dependensi (view dasar lebih dulu). Dijalankan pada database yang tabel faktanya sudah terisi.
-- Perbedaan dari definisi di database sebelum perbaikan: v_segment_scorecard memakai round(r.opm_vol, 10)
-- agar Power Query tidak error pada angka dengan 40 desimal.
-- Tabel dasar: fact_segment_asii, fact_peer_benchmark, fact_auto_konsolidasi.

-- v_bench_ann_base
CREATE OR REPLACE VIEW v_bench_ann_base AS
CREATE OR REPLACE VIEW v_bench_ann_base AS
 SELECT 'AUTO'::character varying AS ticker,
    EXTRACT(year FROM fact_auto_konsolidasi.period_date)::integer AS tahun,
    fact_auto_konsolidasi.revenue,
    fact_auto_konsolidasi.gross_profit,
    fact_auto_konsolidasi.selling_expense,
    fact_auto_konsolidasi.ga_expense,
    fact_auto_konsolidasi.gross_profit - fact_auto_konsolidasi.selling_expense - fact_auto_konsolidasi.ga_expense AS operating_profit
   FROM fact_auto_konsolidasi
UNION ALL
 SELECT fact_peer_benchmark.ticker,
    EXTRACT(year FROM fact_peer_benchmark.period_date)::integer AS tahun,
    sum(fact_peer_benchmark.revenue) AS revenue,
    sum(fact_peer_benchmark.gross_profit) AS gross_profit,
    sum(fact_peer_benchmark.selling_expense) AS selling_expense,
    sum(fact_peer_benchmark.ga_expense) AS ga_expense,
    sum(fact_peer_benchmark.gross_profit - fact_peer_benchmark.selling_expense - fact_peer_benchmark.ga_expense) AS operating_profit
   FROM fact_peer_benchmark
  WHERE (fact_peer_benchmark.ticker::text = ANY (ARRAY['GJTL'::character varying, 'SMSM'::character varying]::text[])) AND fact_peer_benchmark.period_date >= '2024-01-01'::date
  GROUP BY fact_peer_benchmark.ticker, (EXTRACT(year FROM fact_peer_benchmark.period_date))
UNION ALL
 SELECT fact_segment_asii.ticker,
    EXTRACT(year FROM fact_segment_asii.period_date)::integer AS tahun,
    sum(fact_segment_asii.revenue) AS revenue,
    sum(fact_segment_asii.gross_profit) AS gross_profit,
    sum(fact_segment_asii.selling_expense) AS selling_expense,
    sum(fact_segment_asii.ga_expense) AS ga_expense,
    sum(fact_segment_asii.gross_profit - fact_segment_asii.selling_expense - fact_segment_asii.ga_expense) AS operating_profit
   FROM fact_segment_asii
  WHERE fact_segment_asii.segment::text = 'automotive'::text AND fact_segment_asii.period_date >= '2024-01-01'::date
  GROUP BY fact_segment_asii.ticker, (EXTRACT(year FROM fact_segment_asii.period_date));

-- v_bench_ann
CREATE OR REPLACE VIEW v_bench_ann AS
CREATE OR REPLACE VIEW v_bench_ann AS
 SELECT ticker,
    tahun,
    revenue,
    1.0 * gross_profit / NULLIF(revenue, 0::numeric) AS gross_margin,
    1.0 * operating_profit / NULLIF(revenue, 0::numeric) AS operating_margin
   FROM v_bench_ann_base;

-- v_bench_ann_gap
CREATE OR REPLACE VIEW v_bench_ann_gap AS
CREATE OR REPLACE VIEW v_bench_ann_gap AS
 WITH peer AS (
         SELECT v_bench_ann.tahun,
            percentile_cont(0.5::double precision) WITHIN GROUP (ORDER BY (v_bench_ann.gross_margin::double precision)) AS peer_gm,
            percentile_cont(0.5::double precision) WITHIN GROUP (ORDER BY (v_bench_ann.operating_margin::double precision)) AS peer_opm
           FROM v_bench_ann
          WHERE v_bench_ann.ticker::text = ANY (ARRAY['AUTO'::character varying, 'GJTL'::character varying, 'SMSM'::character varying]::text[])
          GROUP BY v_bench_ann.tahun
        ), asii AS (
         SELECT v_bench_ann.tahun,
            v_bench_ann.gross_margin,
            v_bench_ann.operating_margin
           FROM v_bench_ann
          WHERE v_bench_ann.ticker::text = 'ASII'::text
        )
 SELECT a.tahun,
    a.gross_margin,
    p.peer_gm,
    (a.gross_margin::double precision - p.peer_gm) * 100::double precision AS gm_gap_pp,
    a.operating_margin,
    p.peer_opm,
    (a.operating_margin::double precision - p.peer_opm) * 100::double precision AS opm_gap_pp
   FROM asii a
     JOIN peer p USING (tahun)
  ORDER BY a.tahun;

-- v_finding_peer_ann
CREATE OR REPLACE VIEW v_finding_peer_ann AS
CREATE OR REPLACE VIEW v_finding_peer_ann AS
 SELECT count(*) AS total_tahun,
    count(*) FILTER (WHERE gm_gap_pp > 0::double precision) AS tahun_gm_di_atas_peer,
    count(*) FILTER (WHERE opm_gap_pp > 0::double precision) AS tahun_opm_di_atas_peer,
    round(max(gm_gap_pp) FILTER (WHERE tahun = 2024)::numeric, 2) AS gm_gap_2024_pp,
    round(max(gm_gap_pp) FILTER (WHERE tahun = 2025)::numeric, 2) AS gm_gap_2025_pp,
    round(max(opm_gap_pp) FILTER (WHERE tahun = 2024)::numeric, 2) AS opm_gap_2024_pp,
    round(max(opm_gap_pp) FILTER (WHERE tahun = 2025)::numeric, 2) AS opm_gap_2025_pp
   FROM v_bench_ann_gap;

-- v_segment_annual
CREATE OR REPLACE VIEW v_segment_annual AS
CREATE OR REPLACE VIEW v_segment_annual AS
 SELECT segment,
    substr(period_date::text, 1, 4) AS tahun,
    sum(revenue) AS revenue,
    sum(gross_profit - selling_expense - ga_expense) AS operating_profit,
    sum(net_profit_raw) AS net_profit,
    sum(share_equity_results) AS share_equity,
    count(*) AS n_kuartal
   FROM fact_segment_asii
  GROUP BY segment, (substr(period_date::text, 1, 4));

-- v_segment_margin
CREATE OR REPLACE VIEW v_segment_margin AS
CREATE OR REPLACE VIEW v_segment_margin AS
 WITH base AS (
         SELECT fact_segment_asii.ticker,
            fact_segment_asii.segment,
            fact_segment_asii.period_date,
            fact_segment_asii.revenue,
            fact_segment_asii.gross_profit,
            fact_segment_asii.selling_expense,
            fact_segment_asii.ga_expense,
            fact_segment_asii.gross_profit - fact_segment_asii.selling_expense - fact_segment_asii.ga_expense AS operating_profit,
            fact_segment_asii.net_profit_raw,
            fact_segment_asii.share_equity_results
           FROM fact_segment_asii
        ), ratio AS (
         SELECT base.ticker,
            base.segment,
            base.period_date,
            base.revenue,
            base.operating_profit,
            1.0 * base.gross_profit / NULLIF(base.revenue, 0::numeric) AS gross_margin,
            1.0 * base.selling_expense / NULLIF(base.revenue, 0::numeric) AS selling_ratio,
            1.0 * base.ga_expense / NULLIF(base.revenue, 0::numeric) AS ga_ratio,
            1.0 * base.operating_profit / NULLIF(base.revenue, 0::numeric) AS operating_margin,
            1.0 * base.net_profit_raw / NULLIF(base.revenue, 0::numeric) AS net_margin,
            1.0 * base.share_equity_results / NULLIF(base.net_profit_raw, 0::numeric) AS equity_share_of_np
           FROM base
        )
 SELECT ticker,
    segment,
    period_date,
    revenue,
    operating_profit,
    gross_margin,
    selling_ratio,
    ga_ratio,
    operating_margin,
    net_margin,
    equity_share_of_np,
    operating_margin - lag(operating_margin, 4) OVER (PARTITION BY ticker, segment ORDER BY period_date) AS opm_yoy_pp,
    gross_margin - lag(gross_margin, 4) OVER (PARTITION BY ticker, segment ORDER BY period_date) AS gm_yoy_pp
   FROM ratio;

-- v_segment_rank
CREATE OR REPLACE VIEW v_segment_rank AS
CREATE OR REPLACE VIEW v_segment_rank AS
 WITH y AS (
         SELECT a.segment,
            1.0 * a.operating_profit / NULLIF(a.revenue, 0::numeric) AS opm_2025,
            1.0 * a.operating_profit / NULLIF(a.revenue, 0::numeric) - 1.0 * p.operating_profit / NULLIF(p.revenue, 0::numeric) AS opm_chg_pp,
                CASE
                    WHEN p.revenue > 0::numeric THEN 1.0 * (a.revenue - p.revenue) / p.revenue
                    ELSE NULL::numeric
                END AS rev_growth,
                CASE
                    WHEN p.operating_profit > 0::numeric THEN 1.0 * (a.operating_profit - p.operating_profit) / p.operating_profit
                    ELSE NULL::numeric
                END AS op_growth,
            1.0 * a.share_equity / NULLIF(a.net_profit, 0::numeric) AS equity_share_np
           FROM v_segment_annual a
             JOIN v_segment_annual p ON p.segment::text = a.segment::text AND p.tahun = '2024'::text
          WHERE a.tahun = '2025'::text AND a.segment::text <> 'financial_services'::text
        ), vol AS (
         SELECT v_segment_margin.segment,
            stddev_pop(v_segment_margin.operating_margin) AS opm_vol
           FROM v_segment_margin
          WHERE v_segment_margin.segment::text <> 'financial_services'::text AND v_segment_margin.period_date >= '2024-03-31'::date
          GROUP BY v_segment_margin.segment
        ), m AS (
         SELECT y.segment,
            y.opm_2025,
            y.opm_chg_pp,
            y.rev_growth,
            y.op_growth,
            y.equity_share_np,
            vol.opm_vol
           FROM y
             JOIN vol USING (segment)
        ), r AS (
         SELECT m.segment,
            m.opm_2025,
            m.opm_chg_pp,
            m.rev_growth,
            m.op_growth,
            m.equity_share_np,
            m.opm_vol,
            rank() OVER (ORDER BY m.opm_2025 DESC) AS r_opm,
            rank() OVER (ORDER BY (COALESCE(m.op_growth, '-999'::integer::numeric)) DESC) AS r_opg,
            rank() OVER (ORDER BY (COALESCE(m.rev_growth, '-999'::integer::numeric)) DESC) AS r_rvg,
            rank() OVER (ORDER BY m.opm_chg_pp DESC) AS r_trend,
            rank() OVER (ORDER BY m.opm_vol) AS r_stab
           FROM m
        )
 SELECT segment,
    opm_2025,
    opm_chg_pp,
    rev_growth,
    op_growth,
    equity_share_np,
    opm_vol,
    r_opm,
    r_opg,
    r_rvg,
    r_trend,
    r_stab,
    0.30 * r_opm::numeric + 0.25 * r_opg::numeric + 0.15 * r_rvg::numeric + 0.15 * r_trend::numeric + 0.15 * r_stab::numeric AS skor_berbobot,
    (r_opm + r_opg + r_rvg + r_trend + r_stab)::numeric / 5.0 AS skor_sama_rata,
    rank() OVER (ORDER BY (0.30 * r_opm::numeric + 0.25 * r_opg::numeric + 0.15 * r_rvg::numeric + 0.15 * r_trend::numeric + 0.15 * r_stab::numeric)) AS rank_berbobot,
    rank() OVER (ORDER BY ((r_opm + r_opg + r_rvg + r_trend + r_stab)::numeric / 5.0)) AS rank_sama_rata
   FROM r
  ORDER BY (rank() OVER (ORDER BY (0.30 * r_opm::numeric + 0.25 * r_opg::numeric + 0.15 * r_rvg::numeric + 0.15 * r_trend::numeric + 0.15 * r_stab::numeric)));

-- v_rank_sensitivity_tb
CREATE OR REPLACE VIEW v_rank_sensitivity_tb AS
CREATE OR REPLACE VIEW v_rank_sensitivity_tb AS
 WITH w(nama, w_opm, w_opg, w_rvg, w_trend, w_stab) AS (
         VALUES ('dasar'::text,0.30,0.25,0.15,0.15,0.15), ('sama_rata'::text,0.20,0.20,0.20,0.20,0.20), ('fokus_margin'::text,0.45,0.15,0.10,0.20,0.10), ('fokus_growth'::text,0.15,0.35,0.30,0.10,0.10)
        ), skor AS (
         SELECT w.nama,
            r.segment,
            r.r_opm,
            r.r_opg,
            w.w_opm * r.r_opm::numeric + w.w_opg * r.r_opg::numeric + w.w_rvg * r.r_rvg::numeric + w.w_trend * r.r_trend::numeric + w.w_stab * r.r_stab::numeric AS skor
           FROM v_segment_rank r
             CROSS JOIN w
        )
 SELECT nama,
    segment,
    skor,
    rank() OVER (PARTITION BY nama ORDER BY skor) AS rank_dengan_seri,
    row_number() OVER (PARTITION BY nama ORDER BY skor, r_opm, r_opg, segment) AS rank_tiebreak
   FROM skor;

-- v_finding_sensitivity
CREATE OR REPLACE VIEW v_finding_sensitivity AS
CREATE OR REPLACE VIEW v_finding_sensitivity AS
 SELECT segment,
    count(*) FILTER (WHERE rank_tiebreak = 1) AS kali_peringkat_1,
    count(*) FILTER (WHERE rank_tiebreak <= 2) AS kali_top2,
    min(rank_tiebreak) AS terbaik,
    max(rank_tiebreak) AS terburuk,
    count(*) FILTER (WHERE rank_dengan_seri = 1) AS kali_peringkat_1_dengan_seri,
    count(*) FILTER (WHERE (rank_dengan_seri <= 2) <> (rank_tiebreak <= 2)) AS skema_top2_terpengaruh_seri
   FROM v_rank_sensitivity_tb
  GROUP BY segment;

-- v_findings
CREATE OR REPLACE VIEW v_findings AS
CREATE OR REPLACE VIEW v_findings AS
 WITH s AS (
         SELECT v_finding_sensitivity.segment,
            v_finding_sensitivity.kali_peringkat_1,
            v_finding_sensitivity.kali_top2,
            v_finding_sensitivity.terbaik,
            v_finding_sensitivity.terburuk,
            v_finding_sensitivity.kali_peringkat_1_dengan_seri,
            v_finding_sensitivity.skema_top2_terpengaruh_seri,
            row_number() OVER (ORDER BY v_finding_sensitivity.kali_top2 DESC, v_finding_sensitivity.kali_peringkat_1 DESC, v_finding_sensitivity.terbaik, v_finding_sensitivity.segment) AS urut
           FROM v_finding_sensitivity
        ), t1 AS (
         SELECT s.segment,
            s.kali_peringkat_1,
            s.kali_top2,
            s.terbaik,
            s.terburuk,
            s.kali_peringkat_1_dengan_seri,
            s.skema_top2_terpengaruh_seri,
            s.urut
           FROM s
          WHERE s.urut = 1
        ), t2 AS (
         SELECT s.segment,
            s.kali_peringkat_1,
            s.kali_top2,
            s.terbaik,
            s.terburuk,
            s.kali_peringkat_1_dengan_seri,
            s.skema_top2_terpengaruh_seri,
            s.urut
           FROM s
          WHERE s.urut = 2
        ), oto AS (
         SELECT s.segment,
            s.kali_peringkat_1,
            s.kali_top2,
            s.terbaik,
            s.terburuk,
            s.kali_peringkat_1_dengan_seri,
            s.skema_top2_terpengaruh_seri,
            s.urut
           FROM s
          WHERE s.segment::text = 'automotive'::text
        ), p AS (
         SELECT v_finding_peer_ann.total_tahun,
            v_finding_peer_ann.tahun_gm_di_atas_peer,
            v_finding_peer_ann.tahun_opm_di_atas_peer,
            v_finding_peer_ann.gm_gap_2024_pp,
            v_finding_peer_ann.gm_gap_2025_pp,
            v_finding_peer_ann.opm_gap_2024_pp,
            v_finding_peer_ann.opm_gap_2025_pp
           FROM v_finding_peer_ann
        )
 SELECT t1.segment AS segmen_utama,
    t1.kali_peringkat_1 AS utama_kali_1,
    t1.kali_top2 AS utama_kali_top2,
    t2.segment AS segmen_kedua,
    t2.kali_top2 AS kedua_kali_top2,
        CASE
            WHEN t1.kali_peringkat_1 = 4 THEN 'PRIORITAS JELAS'::text
            WHEN t1.kali_top2 = 4 THEN 'KANDIDAT UTAMA, SENSITIF TERHADAP BOBOT'::text
            ELSE 'TIDAK ADA PEMENANG TUNGGAL'::text
        END AS ketegasan,
    oto.kali_top2 AS otomotif_kali_top2,
    p.total_tahun,
    p.tahun_opm_di_atas_peer,
    p.gm_gap_2024_pp,
    p.gm_gap_2025_pp,
    p.opm_gap_2024_pp,
    p.opm_gap_2025_pp,
        CASE
            WHEN oto.kali_top2 < 3 THEN 'TIDAK MENGUBAH KEPUTUSAN (OTOMOTIF BUKAN TOP 2 KONSISTEN)'::text
            WHEN p.tahun_opm_di_atas_peer = p.total_tahun THEN 'MENDUKUNG'::text
            ELSE 'MELEMAHKAN'::text
        END AS peran_benchmark
   FROM t1
     CROSS JOIN t2
     CROSS JOIN oto
     CROSS JOIN p;

-- v_rank_sensitivity
CREATE OR REPLACE VIEW v_rank_sensitivity AS
CREATE OR REPLACE VIEW v_rank_sensitivity AS
 WITH w(nama, w_opm, w_opg, w_rvg, w_trend, w_stab) AS (
         VALUES ('dasar'::text,0.30,0.25,0.15,0.15,0.15), ('sama_rata'::text,0.20,0.20,0.20,0.20,0.20), ('fokus_margin'::text,0.45,0.15,0.10,0.20,0.10), ('fokus_growth'::text,0.15,0.35,0.30,0.10,0.10)
        ), skor AS (
         SELECT w.nama,
            r.segment,
            w.w_opm * r.r_opm::numeric + w.w_opg * r.r_opg::numeric + w.w_rvg * r.r_rvg::numeric + w.w_trend * r.r_trend::numeric + w.w_stab * r.r_stab::numeric AS skor
           FROM v_segment_rank r
             CROSS JOIN w
        )
 SELECT nama,
    segment,
    skor,
    rank() OVER (PARTITION BY nama ORDER BY skor) AS rank_skema
   FROM skor;

-- v_segment_growth
CREATE OR REPLACE VIEW v_segment_growth AS
CREATE OR REPLACE VIEW v_segment_growth AS
 WITH base AS (
         SELECT fact_segment_asii.ticker,
            fact_segment_asii.segment,
            fact_segment_asii.period_date,
            fact_segment_asii.revenue,
            fact_segment_asii.gross_profit,
            fact_segment_asii.gross_profit - fact_segment_asii.selling_expense - fact_segment_asii.ga_expense AS operating_profit,
            fact_segment_asii.net_profit_raw,
            fact_segment_asii.share_equity_results
           FROM fact_segment_asii
        ), lagged AS (
         SELECT base.ticker,
            base.segment,
            base.period_date,
            base.revenue,
            base.gross_profit,
            base.operating_profit,
            base.net_profit_raw,
            base.share_equity_results,
            lag(base.revenue, 1) OVER w AS rev_q1,
            lag(base.revenue, 4) OVER w AS rev_y1,
            lag(base.operating_profit, 1) OVER w AS op_q1,
            lag(base.operating_profit, 4) OVER w AS op_y1
           FROM base
          WINDOW w AS (PARTITION BY base.ticker, base.segment ORDER BY base.period_date)
        )
 SELECT ticker,
    segment,
    period_date,
    revenue,
    operating_profit,
        CASE
            WHEN rev_q1 > 0::numeric THEN 1.0 * (revenue - rev_q1) / rev_q1
            ELSE NULL::numeric
        END AS rev_qoq,
        CASE
            WHEN rev_y1 > 0::numeric THEN 1.0 * (revenue - rev_y1) / rev_y1
            ELSE NULL::numeric
        END AS rev_yoy,
        CASE
            WHEN op_q1 > 0::numeric THEN 1.0 * (operating_profit - op_q1) / op_q1
            ELSE NULL::numeric
        END AS op_qoq,
        CASE
            WHEN op_y1 > 0::numeric THEN 1.0 * (operating_profit - op_y1) / op_y1
            ELSE NULL::numeric
        END AS op_yoy,
        CASE
            WHEN (segment::text = ANY (ARRAY['automotive'::character varying, 'infra_logistic'::character varying, 'financial_services'::character varying]::text[])) AND period_date >= '2024-03-31'::date AND period_date <= '2024-12-31'::date THEN 'LINTAS_BASIS_2023'::text
            WHEN segment::text = 'financial_services'::text AND period_date = '2025-03-31'::date THEN 'BASIS_CAMPURAN'::text
            ELSE NULL::text
        END AS data_flag
   FROM lagged;

-- v_segment_scorecard
CREATE OR REPLACE VIEW v_segment_scorecard AS
CREATE OR REPLACE VIEW v_segment_scorecard AS
 WITH g AS (
         SELECT v_segment_growth.segment,
            avg(v_segment_growth.rev_yoy) AS avg_rev_yoy,
            avg(v_segment_growth.op_yoy) AS avg_op_yoy,
            sum(
                CASE
                    WHEN v_segment_growth.op_yoy IS NULL AND v_segment_growth.period_date >= '2025-03-31'::date THEN 1
                    ELSE 0
                END) AS n_op_yoy_null
           FROM v_segment_growth
          WHERE v_segment_growth.period_date >= '2025-03-31'::date
          GROUP BY v_segment_growth.segment
        ), f AS (
         SELECT v_segment_growth.segment,
            count(*) FILTER (WHERE v_segment_growth.data_flag IS NOT NULL) AS n_flag
           FROM v_segment_growth
          GROUP BY v_segment_growth.segment
        )
 SELECT r.segment,
    r.opm_2025,
    r.opm_chg_pp,
    r.rev_growth,
    r.op_growth,
    round(r.opm_vol, 10) AS opm_vol,
    g.avg_rev_yoy,
    g.avg_op_yoy,
    g.n_op_yoy_null,
    r.rank_berbobot,
    r.rank_sama_rata,
    f.n_flag,
        CASE
            WHEN r.rank_berbobot <= 2 AND r.rank_sama_rata <= 2 THEN 'KUAT'::text
            WHEN r.rank_berbobot <= 3 OR r.rank_sama_rata <= 3 THEN 'SEDANG'::text
            ELSE 'LEMAH'::text
        END AS kategori_awal
   FROM v_segment_rank r
     JOIN g USING (segment)
     JOIN f USING (segment)
  ORDER BY r.rank_berbobot;

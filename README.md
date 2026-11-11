# asii-segment-priority-analysis

SQL & Power BI: prioritas segmen bisnis ASII (profitabilitas, sensitivitas bobot, benchmark peer Otomotif).

## Pertanyaan

Segmen ASII mana yang paling layak diprioritaskan untuk investasi tambahan?

Hasil analisis ini adalah **kandidat yang layak dianalisis lebih lanjut**, bukan saran investasi.

## Ringkasan temuan

- **Tidak ada pemenang tunggal.** Peringkat berubah menurut skema bobot.
- **TI** dan **agribisnis** masing-masing masuk 2 teratas pada 3 dari 4 skema bobot.
- **Otomotif** dan **HEMCE** berada di dua peringkat terbawah.
- **Infrastruktur & logistik vs properti** rapuh terhadap pilihan jendela waktu: urutannya bisa berbalik.
- **Otomotif ASII vs median peer** (AUTO, GJTL, SMSM):

| Metrik | Selisih vs median peer (pp) |
|---|---|
| Gross margin | -10,14 dan -8,11 |
| Operating margin | -10,48 dan -8,76 |

Sumber angka: `data/v_bench_ann_gap.csv` (dua baris, satu per periode tahunan).

## Metode

- Sumber: laporan keuangan segmen ASII (kuartalan) dan tiga emiten pembanding Otomotif (AUTO, GJTL, SMSM).
- Laba operasional = laba kotor - beban penjualan - beban umum & administrasi. Tidak termasuk `share_equity_results`.
- Peringkat atas **6 segmen non-keuangan** dengan 5 metrik, dan **4 skema bobot**: `dasar`, `sama_rata`, `fokus_margin`, `fokus_growth`.
- Tie-break: `r_opm`, lalu `r_opg`.
- Jendela stabilitas: 8 kuartal.
- Benchmark peer hanya untuk gross margin dan operating margin, memakai median AUTO/GJTL/SMSM. AUTO/GJTL/SMSM hanya dipakai sebagai pembanding Otomotif, bukan sebagai kandidat.

## Struktur repo

| Folder / file | Isi |
|---|---|
| `data/` | 7 CSV hasil ekspor: `fact_segment_asii` (84 baris), `fact_peer_benchmark` (48), `v_segment_scorecard` (6), `v_rank_sensitivity_tb` (24), `v_findings` (1), `v_bench_ann_gap` (2), `v_bench_ann` (8) |
| `sql/05_views_aktif.sql` | 13 view aktif, urut dependensi. Ini skrip utama |
| `sql/01`-`04` | Arsip koreksi data (AUTO, net profit kuartalan, SMSM Q4 2024, restatement 2024). **Jangan dijalankan ulang** |
| `sql/06_arsip_view_dihapus.sql` | Arsip parsial view yang dihapus. Jangan dibuat ulang |

File `sql/01`-`04` dan `06` berisi dokumentasi: perintah yang mengubah data sudah dikomentari.

## Cara melihat hasil

1. Lihat CSV di `data/`.
2. Untuk membaca logika, buka `sql/05_views_aktif.sql`.
3. Untuk mereproduksi di PostgreSQL: muat `fact_segment_asii` dan `fact_peer_benchmark` dari CSV, lalu jalankan `sql/05_views_aktif.sql`.

Dashboard Power BI (mode Import) mengimpor 5 view: `v_segment_scorecard`, `v_rank_sensitivity_tb`, `v_findings`, `v_bench_ann_gap`, `v_bench_ann`. Halaman 1 "Ringkasan" dan halaman 2 "Otomotif vs Peer".

## Keterbatasan

1. Tidak ada data modal atau aset per segmen. Peringkat mengukur profitabilitas, bukan return on capital, dan peringkat ordinal tidak mengukur ukuran segmen.
2. Peer (AUTO, GJTL, SMSM) tidak like-for-like dengan segmen Otomotif ASII. Perannya hanya konteks dan tidak mengubah peringkat internal.
3. Definisi laba ASII berbeda dari peer, sehingga benchmark hanya memakai gross margin dan operating margin.
4. Peringkat ordinal 6 segmen non-keuangan rapuh terhadap bobot dan jendela stabilitas. Infrastruktur & logistik vs properti berubah pada jendela 12 kuartal. Jasa keuangan tidak diranking di sini.
5. Operating profit = laba bruto - beban penjualan - beban G&A, tanpa `share_equity_results` (hasil bagian ekuitas JV dan asosiasi). Pernyataan "Otomotif tidak pernah top 2" hanya berlaku dengan definisi ini; bagian ekuitas FY2025 setara 74% dari laba segmen.
6. FY2024 disajikan kembali untuk 3 segmen (automotive, infra_logistic, jasa keuangan); data 2023 tidak disesuaikan dan tidak dipakai. Pembanding 2024 di laporan kuartal 2025 dan di laporan FY2025 adalah dua penyajian berbeda (contoh: total aset 31/12/2024 = 471.356 vs 471.449).
7. Staging awal yang kumulatif dikoreksi lewat skrip terdokumentasi (`sql/01` sampai `sql/04`). Skrip koreksi AUTO (`sql/01`) direkonstruksi, bukan file asli. Satu view warisan (`v_segment_quarterly`) ditemukan salah dan dihapus (`sql/06`, arsip parsial).
8. Benchmark hanya FY2024-FY2025. Data SMSM 2025 belum dicek ke laporan, koreksi SMSM Q4 2024 adalah inferensi (jumlah FY2024 cocok dengan laporan), dan `net_profit` GJTL tidak dipakai.
9. AUTO komponen Q2 2024 rugi operasional -80,725 miliar. Angka ini sah dan cocok dengan laporan.
10. `net_profit_raw` 2023 tidak valid dan tidak dipakai.
11. Jasa keuangan 2024: Q4 berbasis campuran (`BASIS_CAMPURAN`) dan Q1 berbeda dari pembanding.
12. Property 2025: jumlah beban penjualan 4 kuartal = 72 vs laporan 71 miliar. Diduga pembulatan; data tidak diubah.
13. Infra_logistic 2023 vs 2024 tidak sebanding (revenue 9.154 miliar menjadi 3.147 miliar).

Seluruh keluaran adalah kandidat yang layak dianalisis lebih lanjut, bukan rekomendasi investasi.

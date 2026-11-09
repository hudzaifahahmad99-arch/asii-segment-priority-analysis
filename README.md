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

| Tahun | Selisih gross margin (pp) | Selisih operating margin (pp) |
|---|---|---|
| 2024 | -10,14 | -10,48 |
| 2025 | -8,11 | -8,76 |

Sumber angka: `data/v_bench_ann_gap.csv`. Selisih = margin ASII dikurangi median margin AUTO, GJTL, dan SMSM.

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

1. `financial_services` tidak ditampilkan di dashboard. Segmen ini diranking terpisah berdasarkan net margin, sesuai desain.
2. Q4 2024 `financial_services` memakai basis campuran (FY dikurangi 9 bulan), ditandai `BASIS_CAMPURAN`.
3. Q1 2024 `financial_services` punya anomali.
4. Laba operasional tidak memasukkan `share_equity_results`.
5. Median peer hanya dari tiga emiten (AUTO, GJTL, SMSM) dan hanya untuk gross margin dan operating margin.
6. Hasil peringkat sensitif terhadap skema bobot dan jendela stabilitas (8 kuartal). Infrastruktur vs properti paling rentan.
7. Data SMSM 2025 belum dicek ulang ke laporan keuangan.
8. Koreksi SMSM Q4 2024 (beban penjualan 171.906 menjadi 71.906 juta) adalah dugaan/inferensi dari pola, lalu dikonfirmasi lewat jumlah FY2024.
9. `sql/01_koreksi_auto.sql` direkonstruksi dari selisih terhadap `bak_fact_peer_benchmark_20261021`; bukan file asli 21/10.
10. `sql/06_arsip_view_dihapus.sql` tidak lengkap; hanya satu definisi yang tersimpan.
11. Tie-out laba bersih kuartalan semula mengecualikan `infra_logistic` 2025; verifikasi akhir memuatnya (1.427 miliar).
12. Seluruh keluaran adalah dasar analisis lanjutan, bukan rekomendasi investasi.

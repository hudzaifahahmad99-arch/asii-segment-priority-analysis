# asii-segment-priority-analysis

SQL & Power BI: prioritas segmen bisnis ASII (profitabilitas, sensitivitas bobot, benchmark peer Otomotif).

## Keputusan yang dibantu

**Pemilik keputusan:** CEO dan Head of Finance grup otomotif.

**Pertanyaan:** segmen ASII mana yang paling layak diprioritaskan untuk investasi tambahan?

Hasil analisis ini adalah **kandidat yang layak dianalisis lebih lanjut**, bukan saran investasi.

## Temuan

**Satu kalimat:** TI dan agribisnis adalah kandidat yang paling layak dianalisis lebih lanjut (masing-masing top 2 pada 3 dari 4 skema bobot; FY2025: pertumbuhan revenue +6,29% dan +31,35%, operating margin 9,53% dan 8,44%), sedangkan Otomotif tidak pernah top 2, dengan operating margin 1,39% (tanpa bagian ekuitas), 8,76 pp di bawah median peer.

Enam segmen non-keuangan, FY2025 terhadap FY2024. Peringkat 1 = terbaik.

| Segmen | Revenue growth | Operating margin | Operating profit growth | Share revenue* | Share laba operasional* | Peringkat: dasar / sama rata / fokus margin / fokus growth |
|---|---|---|---|---|---|---|
| TI | +6,29% | 9,53% | +40,39% | 1,02% | 1,01% | 1 / 1 / 3 / 2 |
| Agribisnis | +31,35% | 8,44% | +45,75% | 9,78% | 8,57% | 2 / 2 / 4 / 1 |
| Infra & logistik | +0,57% | 47,05% | +2,13% | 1,08% | 5,28% | 3 / 3 / 1 / 3 |
| Properti | -17,49% | 18,02% | +14,61% | 0,39% | 0,72% | 4 / 4 / 2 / 4 |
| HEMCE | -2,33% | 16,81% | -18,82% | 44,83% | 78,21% | 5 / 5 / 5 / 5 |
| Otomotif | -8,19% | 1,39% | -21,37% | 42,90% | 6,21% | 6 / 6 / 6 / 6 |

\*Dari total 6 segmen non-keuangan FY2025. Median operating margin keenam segmen: 13,17%.

- **Tidak ada pemenang tunggal.** Peringkat berubah menurut skema bobot.
- **TI** peringkat 1 pada 2 skema dan top 2 pada 3 dari 4. **Agribisnis** peringkat 1 pada 1 skema dan top 2 pada 3 dari 4.
- **Skala sangat berbeda.** Agribisnis 9,78% dari revenue segmen non-keuangan FY2025, TI 1,02%. Peringkat ordinal tidak memperlihatkan itu.
- **Otomotif** dan **HEMCE** berada di dua peringkat terbawah pada keempat skema. HEMCE menyumbang 78,21% laba operasional segmen non-keuangan FY2025.
- **Infrastruktur & logistik vs properti** rapuh terhadap pilihan jendela waktu: urutannya bisa berbalik.
- **Otomotif ASII vs median peer** (AUTO, GJTL, SMSM):

| Metrik | Selisih vs median peer (pp) |
|---|---|
| Gross margin | -10,14 (2024) dan -8,11 (2025) |
| Operating margin | -10,48 (2024) dan -8,76 (2025) |

Operating margin Otomotif ASII 1,63% (2024) dan 1,39% (2025); median peer 12,11% dan 10,15%.

Sumber angka: `data/v_segment_scorecard.csv`, `data/v_rank_sensitivity_tb.csv`, `data/v_findings.csv`, `data/v_bench_ann_gap.csv`. Kolom share dan bagian ekuitas dihitung dari `data/fact_segment_asii.csv` dengan definisi laba operasional di bagian Metode.

## Rekomendasi

**Untuk CEO dan Head of Finance:** jadikan **agribisnis** dan **TI** dua kandidat untuk kajian lanjutan sebelum ada keputusan alokasi modal. Urutan kajian, bukan penetapan pemenang: mulai dari agribisnis, karena skalanya lebih material (9,78% revenue dan 8,57% laba operasional segmen non-keuangan FY2025, dibanding TI 1,02% dan 1,01%). Itu inferensi dari skala, bukan hasil uji.

Bahan tambahan yang perlu sebelum keputusan:

1. Modal atau aset per segmen, untuk menghitung return on capital (tidak ada di data ini).
2. Proyeksi FY2026 untuk agribisnis dan TI, untuk menguji apakah pertumbuhan FY2025 berulang.
3. Penilaian Otomotif dengan bagian ekuitas JV dan asosiasi: pada FY2025 bagian ekuitas Rp8,83 triliun dari laba segmen Rp11,90 triliun (74,2%). Dengan definisi laba operasional di sini, bagian itu tidak ikut dihitung.

## Empat Pertanyaan Konteks

**#1. Keputusan siapa yang dibantu?**
CEO dan Head of Finance grup otomotif yang memilih segmen ASII untuk investasi tambahan. Project ini hanya menjawab satu pertanyaan itu. Kualitas laba, arus kas, dan ruang utang berada di luar scope.

**#2. Apa yang tidak bisa dijawab data ini?**

- Return on capital dan besar investasi: tidak ada data modal atau aset per segmen. Peringkat ordinal tidak mengukur skala (TI 1,02% revenue, agribisnis 9,78%).
- Apakah pertumbuhan FY2025 berulang: growth berasal dari satu pasang tahun (FY2024 ke FY2025). Data 2023 tidak sebanding untuk automotive, infra_logistic, dan jasa keuangan (Keterbatasan 6 dan 13).
- Total kontribusi laba segmen yang berasal dari JV dan asosiasi: laba operasional tidak memuat bagian ekuitas. Pada FY2025 bagian ekuitas Otomotif Rp8,83 triliun dari laba segmen Rp11,90 triliun (74,2%), sehingga operating margin 1,39% tidak menggambarkan seluruh kontribusi laba Otomotif.
- Keberhasilan operasional ekspansi (permintaan pasar, eksekusi manajemen) dan tata kelola.
- Kapasitas pendanaan, utang, dan arus kas grup.

**#3. Apa yang bisa mengubah kesimpulan?**

- Definisi laba. Memasukkan bagian ekuitas mengubah posisi Otomotif (74,2% laba segmen FY2025) dan infra_logistic (45,1%). Pernyataan "Otomotif tidak pernah top 2" hanya berlaku dengan definisi di bagian Metode.
- Skema bobot dan jendela waktu. Pada skema `fokus_margin`, infra_logistic peringkat 1 dan agribisnis turun ke peringkat 4. Urutan infra_logistic vs properti berbalik pada jendela 12 kuartal.
- Basis kecil TI: laba operasional FY2025 Rp285 miliar, sehingga pertumbuhan +40,39% bisa berbalik oleh satu proyek atau satu kuartal.
- Pertumbuhan agribisnis +31,35% berasal dari satu tahun. Kalau FY2026 melambat, posisinya bergeser (dugaan sensitivitas, belum diuji).
- Penyajian ulang data. FY2024 disajikan kembali untuk 3 segmen, dan data SMSM 2025 belum dicek ke laporan (Keterbatasan 6 dan 8).
- Corporate action besar di grup atau di segmen yang belum tercatat di data.

**#4. Apa taruhannya kalau data ini salah?**

- Otomotif tersisih karena operating margin 1,39%, padahal 74,2% laba segmennya berasal dari bagian ekuitas. Segmen dengan laba segmen Rp11,90 triliun (kedua terbesar di antara 6 segmen non-keuangan, setelah HEMCE Rp15,21 triliun) bisa ikut terabaikan di pembahasan modal.
- Modal diarahkan ke segmen kecil karena peringkat ordinal. TI hanya 1,02% dari revenue segmen non-keuangan, sehingga tambahan modal bisa tidak material bagi grup.
- Pertumbuhan satu tahun diperlakukan sebagai tren, terutama agribisnis +31,35%.
- Selisih data kecil menggeser urutan yang rapuh: properti beban penjualan 72 vs 71 miliar di laporan (Keterbatasan 12), skrip koreksi AUTO direkonstruksi (Keterbatasan 7), dan urutan infra_logistic vs properti sensitif.
- Kredibilitas analisis. Hasil ini hanya kandidat untuk dianalisis lebih lanjut. Kalau dipakai sebagai saran investasi, keputusan nyata berdiri di atas data yang punya 13 keterbatasan di bawah.

## Dashboard Power BI

Mode Import. Model: `dim_segment`, `dim_period`, `fact_segment_asii`, `fact_peer_benchmark`, dan 5 view impor.

| Halaman | Menjawab |
|---|---|
| Kuadran | Pertumbuhan revenue FY2025 vs operating margin, ukuran gelembung = share revenue; garis di 0% dan di median margin 6 segmen |
| Tren Share | Share revenue dan share laba operasional per kuartal, 2023-Q1 sampai 2025-Q4 (penyebut 6 segmen non-keuangan) |
| Otomotif vs Peer | Operating margin ASII (segmen Otomotif) vs AUTO, GJTL, SMSM, dan gap terhadap median peer |

Jasa keuangan diranking terpisah (net margin) dan tidak ditampilkan di dashboard.

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

Dashboard Power BI (mode Import) mengimpor 5 view: `v_segment_scorecard`, `v_rank_sensitivity_tb`, `v_findings`, `v_bench_ann_gap`, `v_bench_ann`. Halaman: "Ringkasan", "Kuadran", "Tren Share", dan "Otomotif vs Peer".

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
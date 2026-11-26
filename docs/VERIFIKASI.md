# Verifikasi paket Langit

Pemeriksaan dilakukan saat penyusunan paket pada 26 November 2026 (waktu Indonesia barat).

| Pemeriksaan | Hasil |
| --- | --- |
| Flutter SDK | 3.50.1 stable |
| Dart SDK | 3.14.0 |
| flutter pub get | Berhasil; pubspec.lock disertakan |
| dart format lib test | Berhasil |
| flutter analyze | No issues found |
| flutter test | 9 tes otomatis lulus |
| flutter build web --no-pub --no-web-resources-cdn | Berhasil menghasilkan build/web |
| Request langsung Geocoding API | Berhasil, Jakarta dan koordinat ditemukan |
| Request langsung Forecast API | Berhasil, current dan 7 tanggal prakiraan tersedia |
| Render UI 430 × 932 | Berhasil, screenshot dokumentasi tersedia |
| Alur widget 360 × 800 | Pencarian, favorit dan pemilihan kota lulus tanpa exception layout |
| Build/install APK Android | Belum diuji: Android SDK/perangkat Android tidak tersedia di lingkungan penyusunan |
| Interaksi aplikasi melalui browser sebenarnya | Belum diverifikasi; build web berhasil, browser pengujian tidak dapat dijalankan di lingkungan ini |
| Persistensi plugin di HP/browser pengguna | Perlu diuji pengguna; tes otomatis ViewModel memakai penyimpanan uji di memori |

## Cakupan 9 tes otomatis

1. Parsing angka integer/double, nilai null dan serialisasi lokasi.
2. HTTP GET pencarian membawa nama kota yang benar; hasil kosong aman.
3. Request cuaca menggunakan koordinat, timezone, daily dan forecast_days yang benar.
4. HTTP error dan JSON rusak ditangani.
5. Favorit dapat dipulihkan oleh instance ViewModel baru dan kegagalan penyimpanan tidak memberi state sukses palsu.
6. Lokasi terakhir dipulihkan; kegagalan cuaca dapat dicoba kembali.
7. Respons pencarian lama tidak menimpa pencarian terbaru.
8. Respons cuaca lama tidak menimpa kota yang lebih baru dipilih.
9. Interaksi widget pencarian → favorit → pilih kota → cuaca pada layar sempit.

## Asal screenshot

Screenshot di docs/screenshots merupakan hasil render widget Flutter dalam harness pengujian, memakai respons Open-Meteo yang diambil melalui request langsung. Waktu current pada respons: 2026-11-26T00:15, zona Asia/Jakarta, suhu 26.1°C. Fixture screenshot tidak menjadi sumber data produksi. Kode aplikasi normal selalu memanggil API melalui WeatherService.

Data dari server dibulatkan untuk tampilan suhu. Contohnya suhu 26.1°C ditampilkan 26°C. Waktu tersebut adalah waktu data API, bukan klaim waktu perekaman di HP pengguna.

## Yang perlu dilakukan mahasiswa

- Jalankan aplikasi pada perangkat yang akan dipakai saat demo.
- Uji favorit setelah aplikasi benar-benar ditutup dan dibuka kembali, dan uji koneksi terputus.
- Rekam screenshot dan video sendiri, isi identitas serta link video pada README.
- Unggah source code ke GitHub dan kirim link sesuai form tugas.

Tidak ada klaim bahwa aplikasi telah diuji pada HP tertentu atau APK sudah dibuat. Folder build/cache tidak disertakan dalam ZIP; jalankan perintah build pada perangkat sendiri bila membutuhkan hasil build.

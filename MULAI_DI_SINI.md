# Langit — panduan dari ekstrak sampai pengumpulan

Paket ini adalah proyek Flutter lengkap untuk Responsi Flutter. Jangan menyalin seluruh kode ke main.dart; pertahankan struktur foldernya. Target yang disertakan: Android dan web (Chrome).

## 1. Ekstrak dan buka

1. Download ZIP dan klik kanan > Extract All / Ekstrak Semua.
2. Simpan di folder biasa, misalnya `D:\FlutterProjects\cuaca_app`. Hindari membuka file dari dalam ZIP.
3. Buka VS Code > File > Open Folder.
4. Pilih folder **cuaca_app yang berisi pubspec.yaml**, lib, android, web, dan test. Bila ada folder cuaca_app di dalam cuaca_app, pilih yang paling dalam dan memiliki pubspec.yaml.
5. Bila VS Code menanyakan kepercayaan terhadap folder proyek yang kamu unduh ini, pilih Yes, I trust the authors setelah memeriksa isinya.
6. Pastikan extension Flutter dan Dart tersedia di VS Code.

Tidak perlu menjalankan flutter create untuk paket lengkap ini. Tidak memerlukan Laragon, XAMPP, MySQL, Firebase, atau API key untuk penggunaan tugas nonkomersial ini.

## 2. Periksa Flutter

Pilih Terminal > New Terminal, lalu jalankan satu per satu:

```sh
flutter --version
flutter doctor
flutter devices
```

Proyek diverifikasi dengan Flutter 3.50.1 stable dan Dart 3.14.0. Jika SDK kamu lebih lama dan muncul pesan ketidakcocokan SDK/dependensi, jalankan `flutter upgrade` pada instalasi Flutter stable, kemudian buka ulang terminal. Jangan mengubah batas versi SDK secara sembarang.

Jika `flutter is not recognized`, periksa folder instalasi SDK Flutter milikmu, tambahkan folder `flutter\bin` ke Environment Variables > User variables > Path, lalu tutup dan buka kembali VS Code. Jangan memasukkan path contoh yang tidak ada di komputer.

## 3. Ambil dependensi dan cek kode

```sh
flutter pub get
flutter analyze
flutter test
```

Tunggu setiap perintah selesai sebelum menjalankan berikutnya. Unduhan pertama memerlukan internet. Jangan menutup terminal saat masih mengunduh.

## 4. Jalankan di Chrome dahulu

```sh
flutter run -d chrome --web-port=7357
```

Biarkan terminal tetap berjalan. Browser akan terbuka. Port tetap dipakai agar asal penyimpanan web tetap sama; jika port berganti, favorit di browser bisa terlihat kosong. Gunakan browser dan profil yang sama, bukan mode Incognito, ketika menguji penyimpanan favorit.

Jika Chrome belum terdeteksi:

```sh
flutter config --enable-web
flutter devices
```

Pastikan Chrome terpasang. Jika Edge tersedia pada daftar devices, kamu juga bisa menjalankan `flutter run -d edge --web-port=7357` (penyimpanan Edge terpisah dari Chrome).

## 5. Cara menggunakan aplikasi

1. Pada halaman awal tekan **Pilih kota**.
2. Ketik **Jakarta** atau **Purwokerto** pada Nama kota.
3. Tekan **Cari kota** atau Enter pada keyboard. Pencarian dijalankan saat tombol/Enter ditekan, bukan setiap ketikan.
4. Pilih hasil yang sesuai dengan wilayah/negaranya; nama kota dapat sama.
5. Ketuk **ikon bintang** untuk menyimpan favorit.
6. Ketuk **nama kota** untuk kembali ke halaman cuaca.
7. Lihat suhu, kondisi cuaca, suhu terasa, kelembapan, angin, peluang hujan hari ini, curah hujan, dan prakiraan 7 hari. Gulir ke bawah.
8. Tekan ikon refresh atau tarik ke bawah untuk mengambil data lagi.
9. Tekan ikon pencarian atau **Ganti kota / buka favorit** untuk berpindah kota.
10. Tutup dan buka aplikasi kembali. Kota terakhir dimuat otomatis dan favorit tetap ada. Data cuaca diambil ulang dari internet; tidak ada cache cuaca offline.

Curah hujan (mm) berbeda dari peluang hujan (%). Peluang hujan hari ini merupakan nilai maksimum harian dari API. Angka “—” berarti nilai API tidak tersedia, bukan nol.

## 6. Jalankan di HP Android

1. Pastikan Android Studio, Android SDK dan command-line tools sudah terpasang. Buka Android Studio > SDK Manager untuk memeriksa komponen yang diminta `flutter doctor`.
2. Jika diminta lisensi, jalankan `flutter doctor --android-licenses`, baca dan terima lisensi yang sesuai.
3. Di Samsung: Settings > About phone > Software information > ketuk Build number tujuh kali, lalu aktifkan Developer options > USB debugging.
4. Sambungkan HP memakai kabel USB data. Buka kunci HP dan izinkan dialog USB debugging. Jika hanya mengisi daya dan HP tidak terdeteksi, coba kabel data lain, port lain, dan mode File transfer.
5. Jalankan `flutter devices`.
6. Jalankan `flutter run -d ID_HP`, ganti ID_HP dengan ID perangkat yang benar. Alternatif: pilih HP di pojok kanan bawah VS Code lalu tekan F5.
7. Build pertama Android dapat lama karena mengunduh Gradle/SDK. Tunggu sampai selesai.

Izin INTERNET sudah tersedia di `android/app/src/main/AndroidManifest.xml`. Jangan menambahkan permission di dalam tag application.

Untuk APK pengujian lokal:

```sh
flutter build apk --release
```

Hasil: `build/app/outputs/flutter-apk/app-release.apk`. Signing bawaan template untuk pengujian lokal, belum dikonfigurasi sebagai signing publikasi Play Store. PDF meminta source code; APK bukan pengganti GitHub.

## 7. Setelah mengubah kode

- Simpan file: Ctrl+S.
- Di terminal flutter run: `r` untuk hot reload; `R` untuk hot restart; `q` untuk berhenti.
- Sesudah mengubah dependensi/plugin atau konfigurasi Android: hentikan run, jalankan flutter pub get, lalu run ulang.
- `flutter clean` tidak perlu dilakukan setiap saat. Gunakan jika masalah build cache tetap terjadi setelah membaca pesan error, lalu flutter pub get dan run ulang.

## 8. Uji mandiri sebelum mengumpulkan

| Skenario | Langkah | Hasil yang diharapkan |
| --- | --- | --- |
| Cari kota | Cari Jakarta dan tekan Cari kota | Daftar lokasi dari API muncul |
| Pilih kota | Ketuk nama hasil | Nama kota dan cuaca sesuai koordinat hasil |
| Ganti kota | Cari Bandung dan pilih | Cuaca baru diambil; data lama tidak tertinggal |
| Favorit | Tekan bintang | Lokasi masuk daftar favorit |
| Persistensi | Tutup/buka aplikasi dengan browser/port sama | Favorit dan lokasi terakhir dipulihkan |
| Hapus favorit | Ketuk bintang aktif lalu buka ulang | Favorit yang dihapus tidak muncul |
| Hasil kosong | Cari zzzzxxyyqq | Pesan kota tidak ditemukan |
| Input pendek | Cari satu huruf | Pesan minimal 2 karakter |
| Internet mati | Matikan internet lalu refresh/cari | Pesan error, bukan crash; coba lagi setelah tersambung |
| Prakiraan | Gulir halaman cuaca | Prakiraan hingga 7 hari; hujan dalam %, suhu maks/min |
| Responsif | Ubah lebar jendela / jalankan di HP | Konten dapat digulir dan tidak meluap |

Tes otomatis menggunakan data uji terpisah di folder test. Aplikasi normal tidak menggunakan fixture/hardcoded cuaca. Tetap lakukan uji API langsung di perangkatmu.

## 9. Screenshot dan README

Baca README.md untuk dokumentasi struktur, API, dan MVVM. Screenshot hasil render widget dengan respons API yang diambil saat penyusunan paket sudah disertakan. Sebelum mengumpulkan, ambil ulang screenshot aplikasi milikmu setelah berjalan:

1. Halaman cuaca (termasuk prakiraan; boleh dua gambar).
2. Halaman pencarian dengan hasil kota dan favorit.
3. Opsional: kondisi error dan hasil kosong.

Di Windows gunakan Win+Shift+S; di Android gunakan Power+Volume Down. Simpan PNG di `docs/screenshots/`. Sesuaikan tautan gambar pada README jika nama berubah. Isi identitas dan tautan video yang masih bertanda TODO.

## 10. Upload ke GitHub

1. Buka GitHub dan login.
2. Buat repository baru bernama `responsi-flutter-cuaca`. Pilih visibilitas sesuai aturan dosen; jika private, pastikan dosen mendapat akses.
3. Untuk mengikuti perintah berikut, buat repository kosong: jangan centang penambahan README/license/gitignore karena sudah ada lokal.
4. Pastikan Git terpasang (`git --version`). Pada terminal folder proyek:

```sh
git init
git add .
git commit -m "Implementasi aplikasi cuaca Flutter MVVM"
git branch -M main
git remote add origin https://github.com/USERNAME/responsi-flutter-cuaca.git
git push -u origin main
```

Ganti USERNAME dengan username GitHub kamu. Login melalui alur GitHub saat diminta; jangan menaruh token/password dalam kode. Jika `Author identity unknown`, atur nama/email Git yang kamu inginkan dengan `git config user.name "Nama Kamu"` dan `git config user.email "Email GitHub Kamu"`, lalu ulang commit. Jika origin sudah ada, cek `git remote -v` sebelum mengubahnya.

File build dan cache sudah diabaikan melalui .gitignore. Commit pubspec.lock, kode lib, folder platform, test, dokumentasi dan screenshot.

## 11. Video dan pengumpulan

Buka `SKRIP_VIDEO.md`. Itu panduan rekaman demo dan penjelasan kode sekitar 5–6 menit; PDF tidak menetapkan durasi tertentu. Pahami dan sesuaikan penjelasan, jangan mengaku melakukan tes yang belum dilakukan.

1. Rekam demo pencarian, pemilihan kota, favorit, dan prakiraan.
2. Jelaskan Model, View, ViewModel, HTTP GET, parsing JSON, state, local storage, serta loading/error.
3. Upload video ke lokasi yang dapat diakses dosen, lalu masukkan link pada README dan form sesuai kolom yang tersedia.
4. Periksa bahwa GitHub berisi source code dan screenshot benar-benar tampil di README.
5. Kumpulkan melalui https://forms.gle/vz5LUdPVZmJ2F5uKA.

PDF menyebut batas pengerjaan **26 November 2026 pukul 10 pagi** tanpa keterangan zona waktu. Pastikan mengikuti waktu yang ditentukan dosen.

## Masalah yang sering muncul

| Pesan/kondisi | Tindakan |
| --- | --- |
| No pubspec.yaml file found | Buka terminal di folder cuaca_app yang tepat |
| Target of URI doesn't exist | Jalankan flutter pub get; pastikan semua file lib ikut diekstrak |
| Version solving failed | Baca syarat SDK; upgrade Flutter stable bila versinya tidak cocok |
| No supported devices connected | Periksa flutter devices, Chrome atau USB debugging HP |
| Socket/HTTP error | Periksa internet, coba lagi; API mungkin sementara bermasalah |
| Favorit di Chrome hilang | Gunakan browser/profil/port 7357 yang sama; jangan Incognito atau hapus data situs |
| Port 7357 sedang digunakan | Hentikan run sebelumnya; jika mengganti port, penyimpanan web terpisah |
| Gradle build gagal | Jalankan flutter doctor -v, periksa Android SDK/JDK dan baca pesan pertama penyebab kegagalan |
| Aplikasi bawaan penghitung masih muncul | Pastikan folder proyek dan lib/main.dart yang dibuka berasal dari ZIP ini |

Jika menemui error, kirim teks error lengkap dan perintah yang dijalankan. Jangan hanya mengirim baris terakhir “build failed”.

# Panduan video demo dan penjelasan kode (sekitar 5–6 menit)

Isi nama dan NIM sendiri. Durasi ini saran, bukan ketentuan PDF. Rekam aplikasi yang benar-benar berjalan, lalu buka kode di VS Code. Gunakan bahasa sendiri setelah memahami alurnya.

## 00:00–01:15 — Demo

“Halo, saya [nama], NIM [NIM]. Pada responsi ini saya membuat Langit, aplikasi cuaca menggunakan Flutter dan Dart. Sumber data cuacanya adalah Open-Meteo.

Pada awal aplikasi, pengguna memilih kota. Saya membuka halaman pencarian, mengetik Jakarta, lalu menekan Cari kota. Daftar ini berasal dari Geocoding API, bukan daftar kota yang ditulis secara statis. Saya tekan bintang untuk menyimpan favorit, kemudian memilih nama kota.

Halaman cuaca menampilkan kota terpilih, suhu, kondisi cuaca, dan suhu yang dirasakan. Di bagian detail terdapat kelembapan, kecepatan angin, peluang hujan hari ini, dan curah hujan. Peluang hujan menggunakan persen, sedangkan curah hujan menggunakan milimeter. Di bawahnya ada prakiraan tujuh hari dengan suhu maksimum dan minimum.

Melalui pencarian saya dapat membuka favorit dan berpindah kota. Tombol refresh mengambil data terbaru. Lokasi favorit dan kota terakhir tersimpan secara lokal.”

[Tunjukkan pencarian, bintang, halaman cuaca, scroll prakiraan, dan favorit. Jika menjelaskan persistensi, demonstrasikan buka ulang aplikasi pada origin/browser sama.]

## 01:15–02:00 — Struktur dan main.dart

“Tugas ini menerapkan MVVM, yaitu Model, View, dan ViewModel. Folder models berisi bentuk data, views menampilkan antarmuka, sedangkan viewmodels mengelola state dan aksi pengguna. Folder services menangani komunikasi API dan penyimpanan.

Pada main.dart, WidgetsFlutterBinding.ensureInitialized menyiapkan binding Flutter. ChangeNotifierProvider membuat WeatherViewModel dan memanggil initialize untuk membaca data lokal. MaterialApp mengatur tema Material Design agar warna dan tipografi konsisten.”

[Buka main.dart dan struktur lib.]

## 02:00–02:45 — Model dan API

“LocationModel menyimpan ID lokasi, nama, wilayah, negara, lintang, dan bujur. fromJson mengubah JSON menjadi objek Dart, sedangkan toJson digunakan saat menyimpan lokasi.

WeatherModel memisahkan data current dan daily. DailyWeather mewakili satu hari prakiraan. Nilai yang tidak tersedia tetap null dan ditampilkan sebagai tanda strip, tidak diubah menjadi angka nol.

WeatherService melakukan HTTP GET. Pertama, searchCities mencari nama kota lewat Geocoding API. Kedua, getWeather memakai koordinat hasil yang dipilih untuk meminta current dan daily dari Forecast API, dengan timezone auto serta forecast_days tujuh. JSON respons kemudian diubah menjadi model.”

[Buka location_model.dart, weather_model.dart, kemudian kedua method service.]

## 02:45–03:40 — ViewModel dan state

“WeatherViewModel menyimpan selectedLocation, weather, results, favorites, serta status loading dan error. Ketika pengguna memilih kota, selectLocation menyimpan lokasi terakhir dan memanggil pengambilan cuaca.

Sebelum request, loading diaktifkan dan data cuaca lama dihapus agar tidak tampil sebagai data kota baru. Setelah selesai, ViewModel mengirim perubahan lewat notifyListeners. View yang menggunakan context.watch akan dibangun ulang sesuai state terbaru.

Nomor request digunakan untuk mengabaikan respons lama jika pengguna memulai pencarian atau berpindah kota dengan cepat. Dengan demikian respons yang terlambat tidak menimpa pilihan terbaru.”

[Buka search, selectLocation, _loadWeather, dan _emit.]

## 03:40–04:25 — Penyimpanan lokal

“LocalStorageService menggunakan SharedPreferencesAsync. Favorit diubah menjadi daftar JSON lalu disimpan sebagai string. Saat initialize dijalankan, string tersebut dibaca dan diubah kembali menjadi LocationModel.

Favorit dikenali berdasarkan ID lokasi agar nama kota yang sama tidak tertukar. Ketika tombol bintang ditekan, toggleFavorite menyusun daftar yang baru dan menyimpannya. Tampilan favorit baru diubah setelah penyimpanan berhasil. Jika gagal, aplikasi menampilkan pesan error.

Yang disimpan adalah lokasi favorit dan lokasi terakhir, bukan cache cuaca. Jadi untuk mengambil cuaca terbaru tetap dibutuhkan internet.”

[Buka local_storage_service.dart dan toggleFavorite.]

## 04:25–05:15 — View, widget dan error

“WeatherScreen adalah StatelessWidget karena state utama ada di ViewModel. LocationScreen adalah StatefulWidget untuk mengelola TextEditingController dan membersihkannya melalui dispose.

Pada halaman cuaca, kondisi loading menampilkan indikator proses, sedangkan kegagalan menampilkan pesan dan tombol coba lagi. Pada pencarian, hasil kosong menampilkan pesan kota tidak ditemukan. Request juga diberi timeout.

Layout menggunakan ListView agar dapat digulir, ConstrainedBox agar nyaman pada layar lebar, serta LayoutBuilder dan Wrap agar jumlah kolom detail cuaca mengikuti lebar layar.”

[Tunjukkan cabang loading/error dan LayoutBuilder.]

## 05:15–05:45 — Pemeriksaan dan penutup

“Saya memeriksa aplikasi menggunakan flutter analyze dan flutter test, kemudian menguji fitur pada perangkat saya. Pengujian mencakup parsing data, request API, favorit, penanganan error dan respons request yang datang tidak berurutan.

Data contoh di folder test hanya digunakan untuk tes otomatis, sedangkan aplikasi yang berjalan mengambil data dari Open-Meteo. Dokumentasi struktur dan screenshot tersedia pada README di repository GitHub. Terima kasih.”

[Ucapkan bagian pemeriksaan perangkat hanya setelah benar-benar melakukannya. Tampilkan hasil terminal sendiri bila diperlukan.]

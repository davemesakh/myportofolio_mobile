# myportofolio_mobile

Aplikasi mobile portofolio pribadi berbasis **Flutter**, dibuat sebagai bagian dari Proyek Individu mata kuliah **Pemrograman Berbasis Platform (CSGE602022)**, Fasilkom UI, Semester Gasal 2026/2027.

Aplikasi ini adalah perluasan dari website portofolio pribadi ke ranah mobile. Setiap minggu, fitur baru ditambahkan mengikuti topik Tutorial dan Individual Assignment.

| | |
|---|---|
| **Nama** | David Mesakh |
| **NPM** | 2506604503 |
| **Kelas** | PBP C |

## Fitur Saat Ini

- Halaman utama (`MyHomePage`) yang dipisahkan ke `lib/menu.dart`, terpisah dari `lib/main.dart`.
- Tiga kartu informasi (`InfoCard`): NPM, Name, dan Class.
- Tiga tombol aksi (`ItemCard`): **Lihat Proyek**, **Tambah Proyek**, dan **Logout**, masing-masing dengan ikon dan warna berbeda (biru, hijau, merah).
- `SnackBar` yang menampilkan pesan `Kamu telah menekan tombol [Nama Tombol]!` saat sebuah tombol ditekan.
- Warna tombol disimpan sebagai atribut `color` pada model `ItemHomepage`, sehingga tidak ada logika `if-else` pewarnaan yang berulang.

## Struktur Proyek (ringkas)

```
lib/
├── main.dart   # Titik masuk aplikasi: runApp() dan MaterialApp
└── menu.dart   # MyHomePage, InfoCard, ItemHomepage, ItemCard
```

## Cara Menjalankan

Prasyarat: Flutter SDK sudah terpasang dan `flutter doctor` tidak menunjukkan masalah pada platform yang dipakai.

```bash
# 1. Clone repositori
git clone https://github.com/davemesakh/myportofolio_mobile.git
cd myportofolio_mobile

# 2. Unduh dependensi
flutter pub get

# 3. Periksa kualitas kode (target: No issues found!)
flutter analyze

# 4. Jalankan aplikasi (contoh: di Chrome)
flutter run -d chrome
```

Gunakan `flutter devices` untuk melihat daftar perangkat yang tersedia (Chrome, Windows, atau emulator Android).

---

### Tugas 7

1. **Widget tree dan hubungan parent-child**

   Di Flutter, hampir semua elemen antarmuka adalah widget: teks, tombol, tata letak, bahkan padding. Widget-widget itu tersusun bersarang membentuk struktur pohon yang disebut **widget tree**. Akar pohonnya adalah widget yang dipasang lewat `runApp()`, dan setiap widget di bawahnya adalah cabang atau daun.

   Hubungan **parent-child** berarti sebuah widget (parent) membungkus widget lain (child) di dalam propertinya, misalnya `child:` atau `children:`. Parent menentukan batasan ukuran dan posisi bagi child-nya, sedangkan child menentukan ukuran sendiri di dalam batasan itu. Data dan konfigurasi seperti tema juga mengalir dari parent ke child lewat tree.

   Pada proyek ini, bentuk sederhananya seperti berikut:

   ```
   MaterialApp
   └── MyHomePage
       └── Scaffold
           ├── AppBar
           │   └── Text ("MyPortfolio")
           └── Padding
               └── Column
                   ├── Row
                   │   ├── InfoCard (NPM)
                   │   ├── InfoCard (Name)
                   │   └── InfoCard (Class)
                   ├── SizedBox
                   └── Center
                       └── Column
                           ├── Padding → Text (pesan sambutan)
                           └── GridView
                               ├── ItemCard (Lihat Proyek)
                               ├── ItemCard (Tambah Proyek)
                               └── ItemCard (Logout)
   ```

   `Scaffold` adalah parent dari `AppBar` dan `Padding`; `Row` adalah parent dari tiga `InfoCard`; dan seterusnya. Jika sebuah parent dibangun ulang, child-nya ikut dievaluasi ulang, sehingga susunan tree sangat memengaruhi tampilan dan perilaku aplikasi.

2. **Widget yang digunakan dalam proyek ini dan fungsinya**

   | Widget | Fungsi |
   |---|---|
   | `MaterialApp` | Widget root yang menyediakan tema Material Design, navigasi, dan konfigurasi dasar aplikasi. |
   | `MyHomePage` | Widget halaman utama buatan sendiri (`StatelessWidget`) yang menyusun seluruh isi halaman. |
   | `Scaffold` | Kerangka dasar halaman Material: menyediakan slot untuk `AppBar`, `body`, dan menjadi tempat tampilnya `SnackBar`. |
   | `AppBar` | Bar di bagian atas halaman, berisi judul "MyPortfolio". |
   | `Text` | Menampilkan teks (judul, isi kartu, pesan sambutan, label tombol, isi SnackBar). |
   | `Padding` | Memberi jarak di sekeliling child-nya. |
   | `Column` | Menyusun child secara vertikal. |
   | `Row` | Menyusun child secara horizontal; dipakai untuk menjajarkan tiga `InfoCard`. |
   | `SizedBox` | Kotak kosong berukuran tertentu, dipakai sebagai spasi antar-elemen. |
   | `Center` | Menempatkan child di tengah ruang yang tersedia. |
   | `GridView.count` | Menampilkan child dalam kisi dengan jumlah kolom tetap (3 kolom untuk `ItemCard`). |
   | `InfoCard` | Widget buatan sendiri untuk menampilkan pasangan judul dan isi (NPM, Name, Class). |
   | `Card` | Kartu bergaya Material dengan sudut membulat dan bayangan (elevasi). |
   | `Container` | Wadah serbaguna untuk mengatur ukuran, padding, dan dekorasi child. |
   | `ItemCard` | Widget buatan sendiri untuk tombol aksi portofolio; menerima data dari `ItemHomepage`. |
   | `Material` | Permukaan Material yang mendukung warna latar dan sudut membulat untuk `ItemCard`. |
   | `InkWell` | Membuat area yang bisa ditekan dan memberi efek riak (ripple); menjalankan `onTap`. |
   | `Icon` | Menampilkan ikon dari `Icons` (folder, add_circle, logout). |
   | `SnackBar` | Pesan singkat di bagian bawah layar, dipanggil lewat `ScaffoldMessenger`. |

   Selain widget, ada juga kelas pendukung yang bukan widget: `ItemHomepage` (model data nama, ikon, dan warna tombol), serta objek seperti `Colors`, `Icons`, `TextStyle`, dan `EdgeInsets` untuk konfigurasi tampilan.

3. **Fungsi `MaterialApp` dan alasan dipakai sebagai root widget**

   `MaterialApp` adalah widget yang membungkus aplikasi yang memakai desain Material. Fungsi utamanya:

   - **Tema**: menyediakan `ThemeData` (warna, tipografi) yang dapat diakses semua widget di bawahnya lewat `Theme.of(context)`.
   - **Navigasi**: mengelola `Navigator` dan sistem rute untuk berpindah halaman.
   - **Halaman awal dan judul**: lewat properti `home` dan `title`.
   - **Layanan dasar**: menyiapkan hal-hal seperti `ScaffoldMessenger` (untuk `SnackBar`), lokalisasi, serta arah teks.

   `MaterialApp` umumnya dipakai sebagai root karena semua widget Material, misalnya `Scaffold`, `AppBar`, dan `SnackBar`, bergantung pada layanan yang disediakan widget ini. Dengan menaruhnya di puncak tree, tema dan navigasi tersedia untuk seluruh aplikasi dari satu tempat, tanpa perlu diatur ulang di tiap halaman.

4. **Perbedaan `StatelessWidget` dan `StatefulWidget`**

   - **`StatelessWidget`** tidak memiliki state yang dapat berubah. Tampilannya hanya bergantung pada properti yang diberikan saat widget dibuat, sehingga untuk input yang sama hasilnya selalu sama. Contoh di proyek ini: `MyHomePage`, `InfoCard`, dan `ItemCard`.
   - **`StatefulWidget`** memiliki objek `State` terpisah yang bisa berubah selama aplikasi berjalan. Saat state berubah dan `setState()` dipanggil, Flutter memanggil `build()` ulang sehingga tampilan ikut diperbarui.

   **Kapan memilih yang mana:**
   - Pakai `StatelessWidget` jika tampilan hanya bergantung pada data yang diterima dan tidak berubah sendiri, seperti kartu informasi, label, atau tata letak statis. Lebih sederhana dan ringan.
   - Pakai `StatefulWidget` jika widget perlu menyimpan data yang berubah karena interaksi atau waktu, misalnya input form, penghitung, checkbox, atau animasi.

   Untuk aplikasi saat ini, semua widget cukup `StatelessWidget` karena tombol hanya menampilkan `SnackBar` dan tidak mengubah data di layar. Jika nanti ada fitur yang menyimpan perubahan (misalnya menambah item portofolio ke daftar), baru dibutuhkan state.

5. **`BuildContext`**

   `BuildContext` adalah objek yang merepresentasikan **posisi sebuah widget di dalam widget tree**. Lewat context, sebuah widget bisa "melihat ke atas" tree untuk mengambil informasi dari widget leluhurnya.

   Ini penting karena data seperti tema, ukuran layar, dan layanan seperti `ScaffoldMessenger` berada di widget yang lebih tinggi di tree, dan context adalah cara mengaksesnya.

   Di dalam metode `build(BuildContext context)`, context dipakai misalnya pada kode proyek ini:
   - `Theme.of(context).colorScheme.primary` untuk mengambil warna tema pada `AppBar`.
   - `MediaQuery.of(context).size.width` untuk menentukan lebar `InfoCard` sesuai lebar layar.
   - `ScaffoldMessenger.of(context).showSnackBar(...)` untuk menampilkan `SnackBar` pada `Scaffold` terdekat.

   Karena context terikat pada posisi widget, context yang berbeda bisa menghasilkan hasil `.of(context)` yang berbeda.

6. **Hot reload, hot restart, dan kapan harus restart penuh**

   - **Hot reload** menyuntikkan kode baru ke aplikasi yang sedang berjalan lalu membangun ulang tampilan. Prosesnya cepat dan **state aplikasi dipertahankan**. Cocok untuk perubahan tampilan, seperti mengubah teks, warna, atau tata letak.
   - **Hot restart** memulai ulang aplikasi dari awal di dalam sesi debug yang sama. Kode dimuat ulang dan **state direset** ke kondisi awal. Lebih lambat daripada hot reload tetapi jauh lebih cepat daripada menjalankan ulang dari awal.
   - **Full restart** berarti menghentikan aplikasi (`q` di terminal atau tombol stop) lalu menjalankan `flutter run` lagi, sehingga seluruh proses build diulang.

   **Kapan hot reload saja tidak cukup:**
   - Hot restart dibutuhkan jika perubahan menyangkut inisialisasi, misalnya isi `main()`, nilai awal variabel global atau `static`, atau perubahan tipe tertentu (seperti `enum` dan struktur class) yang tidak bisa disuntikkan ke kode yang sedang berjalan.
   - Full restart dibutuhkan jika perubahan menyentuh sisi native atau konfigurasi build, misalnya menambah paket atau dependensi baru di `pubspec.yaml`, menambah aset, atau mengubah kode di folder `android/` atau `ios/` seperti `AndroidManifest.xml`.

---

## AI Disclosure

**Tools yang digunakan:** Claude (Anthropic), lewat antarmuka chat.

**Cara penggunaan:** Saya memakai Claude sebagai pemandu langkah demi langkah, bukan untuk menghasilkan seluruh proyek sekaligus. Alurnya: saya mengunggah soal tugas, Claude merangkum checklist dan menyusun urutan kerja, lalu kami mengerjakan satu langkah per sesi dan saya melaporkan hasilnya (output terminal, screenshot, dan isi kode) sebelum lanjut ke langkah berikutnya.

**Bagian yang dibantu AI:**
- Menjelaskan urutan pengerjaan dan alasan di balik tiap langkah.
- Menjelaskan cara menjalankan aplikasi (`flutter devices`, `flutter run -d chrome`, hot reload dan hot restart).
- Membimbing penerapan atribut `color` pada `ItemHomepage` sesuai petunjuk di soal.
- Membimbing alur Git (add, commit, push).

**Bagian yang saya kerjakan dan verifikasi sendiri:**
- Mengganti data contoh dengan identitas saya (NPM, nama, kelas).
- Mengetik dan menerapkan sendiri perubahan kode pada `menu.dart`, lalu menjalankannya di Chrome.
- Menguji ketiga tombol satu per satu dan memastikan teks `SnackBar` sesuai.
- Menjalankan `flutter analyze` dan memastikan hasilnya `No issues found!`.
- Menjalankan sendiri perintah Git di terminal dan memeriksa hasil push di GitHub.
- [ISI: perubahan atau perbaikan manual lain yang benar-benar kamu lakukan, misalnya hasil membaca ulang dan memahami jawaban README.]

**Keterbatasan AI yang saya temui:**
- Saran awal untuk membagi commit memakai `git add -p` ternyata terlalu rumit untuk kondisi saya, karena perubahan data diri dan perubahan warna berada dalam satu potongan (hunk). Saya sempat salah memasukkan perintah ke prompt interaktif tersebut, lalu keluar dengan `q` dan beralih ke satu commit dengan pesan deskriptif.
- AI tidak dapat melihat proyek saya secara langsung, sehingga ia bergantung pada output dan kode yang saya tempelkan. Karena itu semua hasil saya uji sendiri di perangkat.
- [ISI: keterbatasan lain yang kamu alami, jika ada.]
# myportofolio_mobile

[![CI](https://github.com/davemesakh/myportofolio_mobile/actions/workflows/main.yaml/badge.svg)](https://github.com/davemesakh/myportofolio_mobile/actions/workflows/main.yaml)

Aplikasi mobile portofolio pribadi berbasis **Flutter**, dibuat sebagai bagian dari Proyek Individu mata kuliah **Pemrograman Berbasis Platform (CSGE602022)**, Fasilkom UI, Semester Gasal 2026/2027.

Aplikasi ini adalah perluasan dari website portofolio pribadi ke ranah mobile yang terintegrasi dengan backend **Django REST Framework (DRF)** melalui autentikasi token dan pipeline CI/CD GitHub Actions.

| | |
|---|---|
| **Nama** | David Mesakh |
| **NPM** | 2506604503 |
| **Kelas** | PBP C |
| **Backend Django Repo** | https://github.com/davemesakh/myportofolio |
| **Backend API (PWS Deploy)** | https://david-mesakh-myportofolio.pws.cs.ui.ac.id |

## Fitur Saat Ini

- Halaman utama (`MyHomePage`) dengan tiga `InfoCard` (NPM, Name, Class) dan tombol aksi portofolio (**Lihat Proyek**, **Tambah Proyek**, **Lihat Pengalaman**, **Tambah Pengalaman**, dan **Logout**).
- Navigasi konsisten melalui `LeftDrawer` dengan status login dinamis (`Login` / `Logout`).
- **Integrasi Backend DRF (`ApiClient` + `AuthState` via `MultiProvider`):**
  - Operasi baca publik (`GET /api/v1/projects/` dan `GET /api/v1/experiences/`) dengan `FutureBuilder` (diinisialisasi di `initState()`), `RefreshIndicator`, serta penanganan state *loading*, *error* (tombol **Retry**), dan *empty*.
  - Halaman detail (`ProjectDetailScreen` & `ExperienceDetailScreen`) untuk menampilkan seluruh field entri.
  - Operasi tulis terautentikasi berbasis `Authorization: Token <key>` (`POST` untuk membuat entri baru, serta **fitur ekstra `PATCH` dan `DELETE`** pada Experience) yang dilindungi oleh `ensureLoggedIn(context)`.
  - Penanganan `ApiException` termasuk **HTTP 401** (menghapus sesi dan mengarahkan login ulang).
- **Model JSON & Code Generation:** `Project` dan `Experience` menggunakan `@JsonSerializable(fieldRename: FieldRename.snake)` dan `@JsonKey(includeToJson: false)` pada field read-only server.
- **Pengujian Otomatis & CI/CD:** Unit test `ApiClient` dengan `MockClient`, ditambah workflow GitHub Actions (`.github/workflows/main.yaml`) menggunakan `very_good_workflows` dan build artefak `app-release-apk`.

## Struktur Proyek (ringkas)

```
lib/
├── config.dart                        # Konfigurasi API_BASE_URL (--dart-define)
├── main.dart                          # Entry point & MultiProvider (ApiClient, AuthState)
├── models/
│   ├── project.dart                   # Model JSON Project (@JsonSerializable)
│   └── experience.dart                # Model JSON Experience (@JsonSerializable)
├── services/
│   ├── api_client.dart                # HTTP client DRF (GET, POST, PATCH, DELETE, auth)
│   └── auth_state.dart                # State manajemen token & login/logout
├── screens/
│   ├── menu.dart                      # Halaman utama (MyHomePage, InfoCard)
│   ├── login_screen.dart              # Halaman login token DRF
│   ├── project_list_screen.dart       # Daftar proyek (GET publik)
│   ├── project_detail_screen.dart     # Detail proyek
│   ├── project_form.dart              # Form tambah proyek (POST terautentikasi)
│   ├── experience_list_screen.dart    # Daftar pengalaman (GET publik)
│   ├── experience_detail_screen.dart  # Detail pengalaman (+ Edit PATCH & Delete DELETE)
│   └── experience_form.dart           # Form tambah/edit pengalaman (POST/PATCH terautentikasi)
└── widgets/
    ├── auth_guard.dart                # Helper ensureLoggedIn(context)
    ├── left_drawer.dart               # Drawer navigasi
    └── project_card.dart              # Kartu aksi halaman utama (ItemHomepage, ItemCard)
```

## Cara Menjalankan

Prasyarat: Flutter SDK sudah terpasang (`flutter doctor` bersih) dan backend Django (`myportofolio`) sedang berjalan di lokal (`python manage.py runserver`) atau menggunakan URL PWS yang sudah di-deploy.

```bash
# 1. Clone repositori
git clone https://github.com/davemesakh/myportofolio_mobile.git
cd myportofolio_mobile

# 2. Unduh dependensi
flutter pub get

# 3. Generate berkas *.g.dart (wajib karena *.g.dart diabaikan di .gitignore)
dart run build_runner build --delete-conflicting-outputs

# 4. Verifikasi format, static analysis, dan unit test
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

# 5. Jalankan aplikasi
# - Emulator Android (default API_BASE_URL=http://10.0.2.2:8000):
flutter run

# - Chrome / Web (arah ke backend lokal):
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000

# - Arah ke backend PWS yang sudah di-deploy:
flutter run -d chrome --dart-define=API_BASE_URL=https://david-mesakh-myportofolio.pws.cs.ui.ac.id
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
### Tugas 8

1. **Perbedaan `push()`, `pushReplacement()`, `pop()`, dan alur opsi Home**

   Navigator mengelola halaman sebagai stack (tumpukan route).

   - `Navigator.push()` menambahkan route baru di atas stack. Route lama tetap ada di bawahnya, sehingga tombol Back mengembalikan pengguna ke halaman sebelumnya.
   - `Navigator.pushReplacement()` mengganti route teratas dengan route baru. Route lama dibuang dari stack, sedangkan route di bawahnya tidak berubah.
   - `Navigator.pop()` membuang route teratas dan kembali ke route di bawahnya. Di proyek ini `pop()` dipakai untuk menutup dialog ringkasan saat tombol OK ditekan.

   Untuk membuka formulir dari kartu aksi saya memakai `Navigator.push()`, supaya pengguna bisa kembali ke halaman utama dengan tombol Back bawaan perangkat atau browser.

   Opsi **Home** di drawer memakai `Navigator.pushReplacement()` ke `MyHomePage()`. Halaman formulir yang sedang tampil diganti dengan halaman utama, jadi pengguna langsung sampai di beranda. Karena `pushReplacement()` hanya mengganti route teratas, route di bawahnya tidak ikut berubah. Kalau formulir sebelumnya dibuka lewat kartu aksi (`push()`), halaman utama yang lama masih ada di bawah stack.

2. **Scaffold, AppBar, Drawer, dan konsistensi struktur halaman**

   `Scaffold` menyediakan kerangka halaman Material dengan slot `appBar`, `drawer`, dan `body`. Semua halaman di aplikasi ini (halaman utama, formulir proyek, formulir pengalaman) memakai kerangka yang sama, sehingga letak judul, ikon menu (☰), dan area isi selalu konsisten. Komponen `LeftDrawer` dibuat sekali di `lib/widgets/left_drawer.dart` lalu dipakai di semua halaman lewat `drawer: const LeftDrawer()`. Dengan begitu menu navigasi selalu sama dan tidak perlu ditulis ulang.

   Contoh tema warna yang dipakai di lebih dari satu halaman: `Colors.indigo` digunakan pada `AppBar` halaman Add Project Form dan Add Experience Form, pada `DrawerHeader`, dan pada tombol Simpan. Teks putih (`Colors.white`) dipakai di semua `AppBar` agar kontras.

3. **Alasan pemilihan tata letak formulir, serta peran widget jarak dan penggulir**

   Formulir disusun sebagai `Form` → `SingleChildScrollView` → `Column`, dengan `crossAxisAlignment: CrossAxisAlignment.start`. `Column` dipilih karena input formulir memang berurutan dari atas ke bawah. Tiap input dibungkus `Padding` (8 piksel) agar tidak menempel satu sama lain atau ke tepi layar, dan tombol Simpan ditempatkan dengan `Align` dan `Padding` di bagian bawah. Kolom deskripsi memakai `maxLines: 5` supaya ruang mengetiknya lebih lega.

   `SingleChildScrollView` penting ketika ruang layar terbatas. `Column` tidak bisa di-scroll sendiri, jadi tanpa pembungkus ini formulir yang lebih tinggi dari layar (atau yang tertutup papan ketik) akan overflow dan tombol Simpan tidak bisa dijangkau. Masalah serupa pernah saya temui di halaman utama. Setelah menambah kartu keempat (Tambah Pengalaman), Chrome menampilkan pesan "BOTTOM OVERFLOWED BY 208 PIXELS". Saya memperbaikinya dengan membungkus `body` dengan `SingleChildScrollView` dan menonaktifkan scroll milik `GridView` (`NeverScrollableScrollPhysics`) supaya hanya halaman yang di-scroll.

4. **Peran `GlobalKey<FormState>`, `validator`, dan `validate()`**

   - `GlobalKey<FormState>` (`_formKey`) adalah pegangan ke state widget `Form`. Dengan key ini, tombol Simpan, yang berada di luar widget input, bisa memanggil operasi pada seluruh form, seperti `validate()` dan `reset()`.
   - `validator` adalah fungsi yang dimiliki setiap `TextFormField`. Ia menerima isi input dan mengembalikan teks pesan kesalahan jika tidak valid, atau `null` jika valid. Pesan itu ditampilkan di bawah kolom terkait.
   - `validate()` menjalankan semua `validator` sekaligus dan menghasilkan `true` hanya jika semuanya mengembalikan `null`. Di proyek ini dialog ringkasan hanya dibuka di dalam `if (_formKey.currentState!.validate())`.

   Contoh nilai yang ditolak: judul pengalaman yang hanya berisi spasi (`"   "`). Validator memakai `value.trim().isEmpty` sehingga isian itu dianggap kosong. Contoh lain: tanggal selesai yang lebih awal daripada tanggal mulai, yang ditolak lewat `_endDate!.isBefore(_startDate!)`.

   Memilih jenis input atau papan ketik saja tidak cukup karena itu hanya mengatur tampilan dan kemudahan, bukan aturan data. Misalnya `keyboardType: TextInputType.url` hanya mengubah bentuk papan ketik, sehingga pengguna tetap bisa mengetik `abc`, dan validator yang memeriksa skema `http`/`https` tetap diperlukan. Begitu pula `showDatePicker()` memastikan format tanggal benar, tetapi tidak menjamin tanggal selesai tidak mendahului tanggal mulai.

---

### Assignment 9

1. **Mengapa menggunakan `@JsonSerializable(fieldRename: FieldRename.snake)` dan `@JsonKey(includeToJson: false)` alih-alih `Map<String, dynamic>` mentah, serta bug yang dicegah pada model `Experience`:**

   Menggunakan kelas model Dart bertipe kuat (`Experience`) dengan `@JsonSerializable(fieldRename: FieldRename.snake)` menjamin kontrak data antara Flutter (konvensi `camelCase`) dan Django REST Framework (konvensi `snake_case`) diperiksa secara statis saat kompilasi. Semua proses pemetaan key JSON, konversi tipe, dan nilai default dihasilkan otomatis oleh `json_serializable` di `experience.g.dart`, sehingga widget form tidak perlu merakit `Map<String, dynamic>` secara manual. Sementara itu, `@JsonKey(includeToJson: false)` memastikan field yang hanya ditetapkan atau dihitung oleh server—seperti `id`, `star_count`, `is_starred`, dan `logo_url`—tetap dibaca saat `fromJson`, tetapi tidak pernah ikut dikirim pada payload `POST`/`PATCH`.

   **Contoh bug yang dicegah pada model `Experience`:** Tanpa `FieldRename.snake` dan model bertipe kuat, sangat mudah terjadi *typo* key seperti mengirim `startYear` atau `logoStaticPath` (camelCase) alih-alih `start_year` dan `logo_static_path` (snake_case), sehingga DRF diam-diam mengabaikan field tersebut dan menyimpan data kosong/null di database. Selain itu, tanpa `@JsonKey(includeToJson: false)` pada `id` (UUID read-only) atau `star_count`, klien berisiko mengirim `"id": null` atau nilai dummy saat `POST /api/v1/experiences/` yang dapat memicu error validasi atau perilaku tak terduga di serializer.

2. **Mengapa `Future` untuk `FutureBuilder` harus diinisialisasi di `initState()` dan mengapa `ApiClient` melempar `ApiException` daripada mengembalikan `null`:**

   Metode `build()` di Flutter bisa dipanggil berkali-kali oleh framework (misalnya saat animasi, rotasi layar, membuka `Drawer`, munculnya `SnackBar`, atau perubahan state dari `Provider`). Jika `apiClient.getExperiences()` dipanggil langsung di dalam `build()`, setiap rebuild akan menciptakan `Future` baru dan menembak permintaan HTTP GET berulang-ulang—menyebabkan tampilan berkedip (*loading flicker*), pemborosan bandwidth, dan beban berlebih ke server. Dengan menyimpannya di field `late Future<List<Experience>> _experiencesFuture` di dalam `initState()`, permintaan hanya dijalankan sekali saat layar dibuat dan baru diulang secara eksplisit ketika pengguna memicu `_reload()` (pull-to-refresh atau tombol **Retry**).

   Sementara itu, melempar `ApiException(statusCode, message)` pada respons HTTP non-2xx jauh lebih aman daripada mengembalikan `null` karena:
   - Mempertahankan informasi penting (`statusCode` dan pesan respons dari server) sehingga lapisan UI dapat membedakan penyebab kegagalan: misalnya status `401` ditangani khusus dengan menghapus sesi (`AuthState.logout()`) dan meminta login ulang, sedangkan `400`/`500` menampilkan `SnackBar` pesan error yang spesifik.
   - Pada `FutureBuilder`, melempar exception membuat `snapshot.hasError` bernilai `true` sehingga UI otomatis menampilkan tampilan error lengkap dengan tombol **Retry**, bukan salah menganggap respons gagal sebagai daftar kosong (*empty state*).

3. **Perbandingan `SessionAuthentication` (Django) vs `TokenAuthentication` (DRF) dan alasan keduanya dipakai bersama:**

   | Aspek | `SessionAuthentication` (Django) | `TokenAuthentication` (DRF) |
   |---|---|---|
   | **Mekanisme kredensial** | Cookie `sessionid` yang dikelola browser otomatis | Header HTTP `Authorization: Token <key>` dikirim eksplisit tiap request |
   | **State di server** | Menyimpan data session di tabel `django_session` | Menyimpan key unik per user di tabel `authtoken_token` |
   | **Proteksi CSRF** | Memerlukan `csrftoken` untuk request mutasi (`POST`/`PATCH`/`DELETE`) | Tidak memerlukan CSRF karena token tidak dikirim otomatis oleh browser |
   | **Cocok untuk** | Aplikasi web berbasis browser (DTL, form HTML, AJAX, Django Admin) | Klien non-browser / *decoupled* seperti aplikasi mobile Flutter atau CLI |

   `myportofolio_mobile` menggunakan `TokenAuthentication` karena aplikasi mobile Flutter tidak mengandalkan *cookie jar* browser maupun mekanisme CSRF token; cukup menyimpan satu string token di `AuthState` dan menyertakannya pada header `Authorization` untuk operasi tulis (`POST`, `PATCH`, `DELETE`). Di sisi lain, `SessionAuthentication` tetap diaktifkan pada backend Django agar antarmuka web portofolio, fitur AJAX di halaman web, serta Django Admin tetap berfungsi normal bagi pengguna browser tanpa mengganggu klien mobile.

4. **Peran job `build` (`very_good_workflows`) dan `build_apk` di `.github/workflows/main.yaml`, serta alasan `*.g.dart` masuk `.gitignore`:**

   - **Job `build` (`VeryGoodOpenSource/very_good_workflows/.github/workflows/flutter_package.yml@v2`):** Bertindak sebagai gerbang kualitas (*quality gate*) otomatis di setiap `push` ke `main` dan `pull_request`. Di balik layar, workflow reusable ini menjalankan langkah `setup` (`dart run build_runner build --delete-conflicting-outputs`), memeriksa format kode (`dart format --output=none --set-exit-if-changed`), menjalankan analisis statis (`flutter analyze`), serta mengeksekusi seluruh pengujian (`flutter test`) beserta pengecekan cakupan kode (*coverage*, dengan mengecualikan `**/*.g.dart`).
   - **Job `build_apk` (`needs: build`):** Hanya berjalan apabila job `build` lulus. Job ini meng-checkout kode, memasang Flutter sesuai versi yang di-pin, menjalankan `flutter pub get` dan `dart run build_runner build --delete-conflicting-outputs`, membangun rilis Android (`flutter build apk --release`), lalu mengunggah berkas `build/app/outputs/flutter-apk/app-release.apk` sebagai artefak `app-release-apk` yang dapat diunduh langsung dari tab GitHub Actions.
   - **Mengapa `*.g.dart` dimasukkan ke `.gitignore` meskipun dibutuhkan CI:** Berkas `*.g.dart` adalah *build artifact* yang dihasilkan secara deterministik dari sumber model (`*.dart`). Menyimpannya di Git menimbulkan *diff* yang bising saat review, rawan *merge conflict* antar cabang, dan berisiko tidak sinkron (*stale*) dengan definisi kelas aslinya. Dengan mengecualikannya dari Git dan menjalankan `build_runner` sebagai langkah `setup` di CI, repositori tetap bersih dan kode hasil generasi selalu segar serta konsisten dengan model terbaru.


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

**Keterbatasan AI yang saya temui:**
- Saran awal untuk membagi commit memakai `git add -p` ternyata terlalu rumit untuk kondisi saya, karena perubahan data diri dan perubahan warna berada dalam satu potongan (hunk). Saya sempat salah memasukkan perintah ke prompt interaktif tersebut, lalu keluar dengan `q` dan beralih ke satu commit dengan pesan deskriptif.
- AI tidak dapat melihat proyek saya secara langsung, sehingga ia bergantung pada output dan kode yang saya tempelkan. Karena itu semua hasil saya uji sendiri di perangkat.

### AI Disclosure Tugas 8

**Tools yang digunakan:** Claude (Anthropic) lewat antarmuka chat. Saya tidak memakai coding agent atau tool AI lain.

**Strategi prompting:** Saya mengunggah PDF soal, lalu meminta Claude memandu pengerjaan langkah demi langkah. Setelah tiap langkah saya mengirim hasilnya (output `flutter analyze`, screenshot aplikasi di Chrome, isi file Dart, dan output Git), lalu Claude memberi langkah berikutnya atau membantu mendiagnosis masalah. Saya juga menempelkan `models.py` dari proyek Django saya agar form dipetakan ke model `Experience` yang sebenarnya.

**Bagian yang dibantu AI:**
- Merangkum checklist tugas dan menyusun urutan pengerjaan.
- Memetakan field model `Experience` ke input formulir (judul, organisasi, kategori, tanggal mulai dan selesai, "masih berlangsung", URL thumbnail) beserta aturan validasinya.
- Menyusun draf kode `experience_form.dart` (validasi, date picker, dialog ringkasan, reset form), tombol kartu, dan opsi drawer secara bertahap.
- Mendiagnosis error `BOTTOM OVERFLOWED` pada halaman utama dan menyarankan perbaikannya.
- Menyusun rencana commit (conventional commits) dan draf awal jawaban refleksi ini.

**Bagian yang saya kerjakan dan verifikasi sendiri:**
- Memilih bagian Pengalaman dan memberikan model Django sebagai dasar field.
- Menempatkan kode ke berkas yang benar (`lib/screens/`, `lib/widgets/`) dan menjalankan `flutter analyze` hingga `No issues found!`.
- Menguji manual di Chrome: akses form dari kartu dan drawer, kolom kosong, tanggal selesai sebelum tanggal mulai, checkbox "Masih berlangsung", URL tidak valid, dialog ringkasan dan reset form, serta navigasi Home.
- Menemukan bug overflow saat menguji, lalu memverifikasi perbaikannya dengan melebarkan jendela browser.
- Menjalankan sendiri perintah Git di terminal dan membaca serta menyunting jawaban refleksi.

**Keterbatasan AI yang saya temui:**
- AI tidak dapat melihat proyek saya langsung. Instruksi seperti "tempel di antara dua baris" ternyata ambigu, dan tombol Simpan sempat tidak tertempel di posisi yang benar. Solusinya: saya mengirim isi file lengkap, lalu AI memeriksa dan memberi versi file utuh.
- Usulan field pertama dibuat sebelum AI melihat model Django saya, sehingga perlu disesuaikan. Misalnya `started_at` ternyata `auto_now_add` dan bukan input pengguna, sehingga tanggal mulai diambil dari `start_year`/`start_month`.
- AI tidak menjalankan aplikasi. Bug overflow baru terlihat setelah saya mengujinya di Chrome, dan bug itu sempat tampak hilang hanya karena jendela browser lebih sempit. Jadi pengujian di berbagai ukuran layar tetap harus saya lakukan sendiri.

### AI Disclosure Tugas 9

**Tools yang digunakan:** Antigravity (Google DeepMind coding agent) di lingkungan IDE lokal.

**Strategi prompting:** Saya mengunggah PDF spesifikasi Assignment 9, meminta pemecahan pekerjaan per fase sesuai kondisi repositori saat ini, lalu mengeksekusi integrasi end-to-end untuk bagian `Experience` (model JSON, perluasan `ApiClient`, list/detail/form terautentikasi, fitur ekstra `PATCH`/`DELETE`, unit test `MockClient`, dan dokumentasi) dengan verifikasi langsung terhadap repositori backend Django lokal (`myportofolio`).

**Bagian yang dibantu AI:**
- Memeriksa kontrak `ExperienceSerializer` dan `api_views.py` di backend Django agar seluruh field `snake_case`, field read-only, dan validator URL/logo pada model `Experience` Flutter cocok 100%.
- Menyusun `lib/models/experience.dart`, memperluas `lib/services/api_client.dart` (`GET`, `POST`, `PATCH`, `DELETE`), membangun `ExperienceListScreen` dan `ExperienceDetailScreen`, serta me-refactor `ExperienceFormPage` dengan `ensureLoggedIn(context)` dan penanganan `ApiException` (termasuk HTTP 401).
- Menulis unit test `MockClient` di `test/api_client_test.dart` serta menyusun draf awal jawaban Pertanyaan Reflektif dan pembaruan `README.md`.

**Bagian yang saya kerjakan dan verifikasi sendiri:**
- Menentukan bagian portofolio (`Experience`) serta target fitur tambahan (`PATCH`/`DELETE` dan unit test `MockClient`).
- Menjalankan verifikasi lokal (`build_runner`, `dart format`, `flutter analyze`, `flutter test`), pengujian end-to-end terhadap server Django lokal, serta memastikan workflow GitHub Actions hijau dan artefak `app-release-apk` dapat diunduh.
- Meninjau seluruh perubahan kode, jawaban refleksi, dan riwayat commit sebelum push ke GitHub dan submisi di SCELE.

**Analisis kritis terhadap keterbatasan AI & perbaikan manual yang diterapkan:**
- Tanpa membaca langsung kode backend Django (`main/serializers.py` dan `main/image_utils.py`), form Assignment 8 sebelumnya menggunakan asumsi field `thumbnail` dan `start_date`/`end_date` yang ternyata berbeda dari serializer Django sebenarnya (`logo_static_path` dengan validasi HTTPS/static path, serta `start_year`/`start_month`/`end_year`/`end_month`). Verifikasi langsung ke backend mencegah error HTTP 400 saat integrasi.
- Pemeriksaan `main/api_views.py` di backend juga mengungkap bahwa endpoint `experience_list` dan `experience_detail` dari Assignment 6 masih memasang `@authentication_classes([SessionAuthentication])` secara eksplisit, sehingga perlu diperbarui di repositori backend agar menerima `TokenAuthentication` dari Flutter.
- Perintah shell yang digenerasi awal menggunakan operator `&&` yang tidak didukung Windows PowerShell 5.1 sehingga perlu disesuaikan dengan pemeriksaan `$LASTEXITCODE` agar alur format, analisis, dan test berjalan akurat di lingkungan Windows.
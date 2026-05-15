# Educu

Educu adalah aplikasi manajemen belajar dan produktivitas pribadi yang dirancang khusus untuk membantu pengguna merencanakan jadwal belajar, melacak progres, mengelola catatan, serta meningkatkan fokus menggunakan teknik Pomodoro.


## 🌟 Fitur Utama

### 1. Manajemen Program Belajar
- **Pembuatan Program:** Pengguna dapat membuat program belajar (misalnya: "Persiapan Ujian Matematika") dan membaginya ke dalam beberapa sesi dengan topik yang berbeda.
- **Penjadwalan Cerdas:** Dilengkapi dengan validasi jadwal cerdas yang mencegah bentrok (overlap) jadwal antar sesi, memastikan rentang tanggal yang dipilih valid, serta memiliki opsi setelan waktu default untuk memudahkan input.
- **Proteksi Data:** Saat sedang membuat atau mengedit program, sistem akan meminta konfirmasi jika pengguna tidak sengaja menekan tombol kembali (*back*), mencegah hilangnya data yang belum tersimpan.

### 2. Timer Pomodoro Terintegrasi
- **Fokus Maksimal:** Sesi belajar dapat dijalankan menggunakan Timer Pomodoro terintegrasi.
- **Validasi Waktu Sesi:** Pengguna hanya dapat menekan tombol "Mulai" ketika jadwal sesi memang sudah tiba. Jika mencoba memulai lebih awal, akan muncul dialog peringatan.
- **Siklus Istirahat:** Memiliki siklus otomatis antara waktu belajar (fokus), istirahat pendek (*short break*), dan istirahat panjang (*long break*).
- **Progres Sesi:** Timer dilengkapi UI berbentuk sirkular yang interaktif dan memantau persentase jadwal belajar yang telah diselesaikan.

### 3. Dashboard Hari Ini (Home)
- Menampilkan ringkasan progres belajar: Total Program, Total Sesi, dan Sesi yang harus diselesaikan Hari Ini.
- Menampilkan daftar jadwal belajar yang spesifik untuk hari tersebut beserta indikator apakah sesi tersebut sudah diselesaikan atau belum.
- Dilengkapi dengan *Quotes* motivasi harian yang berganti secara otomatis.

### 4. Catatan Pribadi (Notes)
- **Kelola Catatan:** Pengguna dapat membuat, mengedit, dan menghapus catatan penting terkait pembelajaran.
- **Validasi Keluar:** Terdapat proteksi dialog jika pengguna ingin kembali ketika sedang menulis catatan baru atau mengedit catatan tanpa menyimpannya terlebih dahulu.
- **Empty State:** UI yang rapi dengan indikator khusus ketika belum ada catatan yang dibuat.

### 5. Akun & Personalisasi
- Sistem Autentikasi yang terintegrasi penuh menggunakan Firebase (Login, Register).
- **Profil Pengguna:** Manajemen data profil termasuk sinkronisasi foto (*real-time*).
- **Keamanan:** Fitur untuk mengganti *password* secara aman.
- Dukungan **Light Mode** dan **Dark Mode**.

---

## 🔄 Flow Aplikasi (Alur Pengguna)

1. **Autentikasi (Login/Register)**
   - Pengguna baru mendaftar menggunakan email dan password, sedangkan pengguna lama bisa langsung login.
2. **Dashboard (Home Screen)**
   - Setelah masuk, pengguna disambut di Dashboard. Di sini pengguna bisa melihat statistik belajarnya, membaca *quotes*, dan melihat daftar "Jadwal Hari Ini". 
3. **Membuat Program & Jadwal Belajar**
   - Pengguna menuju menu **Program** dan menekan tombol tambah (+).
   - Pengguna memasukkan Nama Mata Pelajaran/Program dan mengatur rentang tanggal.
   - Pengguna menambahkan sesi-sesi belajar. Aplikasi akan memvalidasi agar jam tidak bentrok dan menyarankan jam default.
   - Setelah disimpan, sesi akan otomatis diurutkan secara kronologis (dari tanggal dan jam paling awal).
4. **Mulai Belajar (Eksekusi)**
   - Pada hari-H, jadwal sesi akan muncul di Dashboard pengguna.
   - Pengguna menekan tombol **"Mulai"**.
   - *Pengecekan Sistem:* Jika jam saat ini **sebelum** jadwal yang ditentukan, sistem akan memunculkan dialog konfirmasi (*"Belum Waktunya, tetap ingin memulai?"*). Jika sudah waktunya, pengguna langsung masuk ke layar **Pomodoro**.
   - Di layar Pomodoro, pengguna dapat memulai, menjeda (Pause), mereset (dengan dialog konfirmasi), dan menyelesaikan sesi. Saat waktu habis, sesi ditandai sebagai **Selesai**.
5. **Mencatat Materi**
   - Setelah atau saat belajar, pengguna dapat menuju tab **Notes**.
   - Pengguna menulis rangkuman pelajaran dan menyimpannya (disertai keterangan tanggal). Jika terjadi perubahan yang belum disimpan dan pengguna ingin keluar, aplikasi akan memperingatkan agar data tidak hilang.

---

## 🛠️ Teknologi yang Digunakan
- **Framework:** Flutter (Dart)
- **Backend/Database:** Firebase Authentication & Cloud Firestore
- **State Management & Navigasi:** Material App (Standar Flutter) + Sinkronisasi Data Stream
- **Local Storage:** Shared Preferences (Untuk state timer/tema)

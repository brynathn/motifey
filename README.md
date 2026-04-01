# Motifey 🎧

Motifey adalah aplikasi pemutar musik full-stack yang terinspirasi dari Spotify. Project ini dibangun menggunakan **Flutter** untuk sisi client dan **Node.js (Express)** untuk sisi backend, dengan **PostgreSQL** sebagai database utamanya.

## 🚀 Fitur Utama
- **Autentikasi**: Signup dan Login menggunakan JWT.
- **Playlist Management**: Mengambil daftar playlist dari database.
- **Audio Player**: Pemutar musik lengkap dengan fungsi play, pause, seek, next, dan previous.
- **Search**: Mencari lagu dan playlist secara instan.
- **Mini Player**: Kontrol musik yang tetap aktif saat bernavigasi antar menu.
- **Dockerized Backend**: Backend mudah dijalankan menggunakan Docker.

## 🛠️ Stack Teknologi
- **Frontend**: [Flutter](https://flutter.dev) (Dart)
- **Backend**: [Node.js](https://nodejs.org) (Express)
- **Database**: PostgreSQL (Hosted on Supabase/Local)
- **Storage**: Supabase Storage (untuk mp3 dan cover)
- **Containerization**: Docker

## 📂 Struktur Project
motifey-app/
├── frontend/    # Flutter Mobile App
└── backend/     # Node.js Express API

## ⚙️ Cara Menjalankan
1. Persiapan Backend
Pastikan Anda memiliki Docker terinstal. Masuk ke folder backend:

Bash
cd backend
Jalankan container menggunakan perintah berikut (sesuaikan koneksi DB di db.js):

Bash
docker run -it --rm --name motifey-backend \
  -p 3000:3000 \
  -v ${PWD}:/app \
  -v /app/node_modules \
  -w /app \
  node:22-slim \
  npx nodemon -L server.js
2. Persiapan Frontend
Masuk ke folder frontend:

Bash
cd frontend
Pastikan alamat baseUrl di lib/services/api_service.dart sudah sesuai dengan IP Address laptop Anda. Lalu jalankan aplikasi:

Bash
flutter pub get
flutter run

## 📝 Catatan Penting
Ganti baseUrl di api_service.dart menggunakan IP lokal (misal: 192.168.x.x) agar bisa diakses oleh emulator atau perangkat fisik.

Jalankan endpoint /seed (POST) pada backend untuk mengisi data awal ke database.

👤 Author
brynathn


---

### Tips Sebelum Push ke GitHub:
1. **Periksa URL**: Pastikan di `api_service.dart` kamu tidak menggunakan `localhost`, tapi gunakan IP Address laptopmu (seperti `192.167.1.13`) agar HP/Emulator bisa konek.
2. **Commit pertama**:
   git add .
   git commit -m "feat: initial commit motifey app with docker backend and flutter frontend"
   git push origin main
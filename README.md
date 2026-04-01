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

```Bash
cd backend
Jalankan container menggunakan perintah berikut (sesuaikan koneksi DB di db.js):
```

```Bash
docker run -it --rm --name motifey-backend \
  -p 3000:3000 \
  -v ${PWD}:/app \
  -v /app/node_modules \
  -w /app \
  node:22-slim \
  npx nodemon -L server.js
```
2. Persiapan Frontend
Masuk ke folder frontend:

```Bash
cd frontend
Pastikan alamat baseUrl di lib/services/api_service.dart sudah sesuai dengan IP Address laptop Anda. Lalu jalankan aplikasi:
```
```Bash
flutter pub get
flutter run
```
## 📝 Catatan Penting
Ganti baseUrl di api_service.dart menggunakan IP lokal (misal: 192.168.x.x) agar bisa diakses oleh emulator atau perangkat fisik.

Jalankan endpoint /seed (POST) pada backend untuk mengisi data awal ke database.

## Hasil

## 📸 App Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/0652f311-c831-42ae-942d-aff222734651" width="200" alt="motifey1">
  <img src="https://github.com/user-attachments/assets/9652ab03-006e-4b9f-8a92-98da966960fb" width="200" alt="motifey2">
  <img src="https://github.com/user-attachments/assets/0f9b8845-87ab-4087-b92e-f57f102e2a38" width="200" alt="motifey3">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/f66e1b82-c89c-4717-a764-f4d0cd75f4a8" width="200" alt="motifey4">
  <img src="https://github.com/user-attachments/assets/ce8a5cd8-d90f-4030-8e07-42096ff1113a" width="200" alt="motifey5">
  <img src="https://github.com/user-attachments/assets/cb57b3f0-652d-4e33-aad5-28e93ab2a12e" width="200" alt="motifey6">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/7bedd022-95f7-45c6-89c8-f30f52b73ca4" width="200" alt="motifey7">
  <img src="https://github.com/user-attachments/assets/41b1cd4f-d14a-4624-aeac-241936a8377c" width="200" alt="motifey8">
  <img src="https://github.com/user-attachments/assets/98025b14-bc7f-4cc3-82e4-af02cc38c47d" width="200" alt="motifey9">
</p>

![motifey1](https://github.com/user-attachments/assets/0652f311-c831-42ae-942d-aff222734651)

![motifey2](https://github.com/user-attachments/assets/9652ab03-006e-4b9f-8a92-98da966960fb)

![motifey3](https://github.com/user-attachments/assets/0f9b8845-87ab-4087-b92e-f57f102e2a38)

![motifey4](https://github.com/user-attachments/assets/f66e1b82-c89c-4717-a764-f4d0cd75f4a8)

![motifey5](https://github.com/user-attachments/assets/ce8a5cd8-d90f-4030-8e07-42096ff1113a)

![motifey6](https://github.com/user-attachments/assets/cb57b3f0-652d-4e33-aad5-28e93ab2a12e)

![motifey7](https://github.com/user-attachments/assets/7bedd022-95f7-45c6-89c8-f30f52b73ca4)

![motifey8](https://github.com/user-attachments/assets/41b1cd4f-d14a-4624-aeac-241936a8377c)

![motifey9](https://github.com/user-attachments/assets/98025b14-bc7f-4cc3-82e4-af02cc38c47d)


👤 Author
brynathn


---

### Tips Sebelum Push ke GitHub:
1. **Periksa URL**: Pastikan di `api_service.dart` kamu tidak menggunakan `localhost`, tapi gunakan IP Address laptopmu (seperti `192.167.1.13`) agar HP/Emulator bisa konek.
2. **Commit pertama**:
   git add .
   git commit -m "feat: initial commit motifey app with docker backend and flutter frontend"
   git push origin main

# 🕒 Aplikasi Pengelola Waktu (Firebase Version)

Aplikasi manajemen waktu yang dibangun dengan Flutter dan Firebase untuk membantu pengguna mengelola tugas-tugas harian mereka dengan efisien.

## 🔥 **PENTING: Aplikasi Telah Dimigrasi ke Firebase!**

> ⚠️ **Aplikasi ini telah sepenuhnya direfactor dari SQLite lokal ke Firebase.**  
> Lihat file `README_FIREBASE.md` untuk panduan lengkap setup Firebase.

## 📱 Fitur Utama

- 🔐 **Login & Registrasi** dengan Firebase Auth
- 📝 **Manajemen Tugas (CRUD)** tersimpan di Cloud Firestore
- ⏰ **Reminder Otomatis** (Push Notification)
- 📊 **Statistik Produktivitas** (Grafik Harian/Mingguan)
- 🎯 **Tandai Tugas Selesai / Belum**
- ☁️ **Penyimpanan Cloud** dengan Firebase
- 🔄 **Real-time sync** antar device

---

## 🛠️ Teknologi yang Digunakan

| Komponen         | Teknologi                       |
| ---------------- | ------------------------------- |
| Framework        | Flutter + Dart                  |
| Backend          | **Firebase** (Auth + Firestore) |
| Authentication   | **Firebase Auth**               |
| Database         | **Cloud Firestore**             |
| Notifikasi       | `flutter_local_notifications`   |
| Grafik Statistik | `fl_chart`                      |
| State Management | `provider`                      |
| IDE              | Android Studio / VS Code        |

---

## 🚀 Quick Start

### 1. **Setup Firebase (WAJIB!)**

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 2. **Install Dependencies**

```bash
flutter pub get
```

### 3. **Run App**

```bash
flutter run
```

⚠️ **Penting**: Anda harus membuat project Firebase sendiri dan mengkonfigurasinya. Lihat `README_FIREBASE.md` untuk panduan lengkap.

---

## 📋 Setup Requirements

1. ✅ **Flutter SDK** (latest stable)
2. ✅ **Firebase Account** dan project
3. ✅ **FlutterFire CLI** untuk konfigurasi
4. ✅ **Android/iOS development setup**

---

## 🗑️ Yang Sudah Tidak Digunakan (Dihapus)

- ❌ `sqflite` (SQLite database)
- ❌ `path` (local file system)
- ❌ `shared_preferences` (untuk session management)
- ❌ Local `DatabaseHelper`
- ❌ Local `UserRepository`
- ❌ Local `TaskRepository`
- ❌ Local `AuthService`

## ✅ Yang Baru (Firebase)

- 🆕 `firebase_core`
- 🆕 `firebase_auth`
- 🆕 `cloud_firestore`
- 🆕 `FirebaseAuthService`
- 🆕 `FirebaseTaskRepository`
- 🆕 `FirebaseService`

---

## 📖 Dokumentasi Lengkap

**📘 Untuk setup Firebase lengkap, baca: [`README_FIREBASE.md`](./README_FIREBASE.md)**

File tersebut berisi:

- Langkah-langkah setup Firebase project
- Konfigurasi authentication & Firestore
- Security rules
- Troubleshooting
- Database structure
- Migration notes

---

## ⚡ Keuntungan Firebase

1. **🔄 Real-time sync** - Data langsung tersinkronisasi antar device
2. **☁️ Cloud storage** - Data aman di cloud, tidak hilang saat ganti device
3. **🔐 Secure auth** - Firebase Auth handle keamanan
4. **📱 Multi-platform** - Data sama di Android, iOS, Web
5. **🔌 Offline support** - Tetap bisa digunakan tanpa internet
6. **📈 Scalable** - Siap untuk banyak user

---

## 🎯 Cara Penggunaan

1. **Register/Login** - Buat akun atau masuk dengan email
2. **Tambah Tugas** - Klik "+" untuk membuat tugas baru
3. **Set Reminder** - Pilih waktu untuk notifikasi
4. **Track Progress** - Lihat statistik di tab Report
5. **Manage Profile** - Edit profil di tab Profile

---

## 🤝 Contributing

Jika ingin berkontribusi:

1. Fork repository
2. Setup Firebase project Anda sendiri
3. Buat feature branch
4. Submit pull request

---

## 📞 Support & Issues

- 📋 **Issues**: Gunakan GitHub Issues untuk bug reports
- 📖 **Firebase Docs**: https://firebase.google.com/docs/flutter
- 🔧 **Setup Help**: Lihat `README_FIREBASE.md`

---

**🎉 Happy coding with Firebase! 🔥**

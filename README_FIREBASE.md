# 🕒 Aplikasi Pengelola Waktu (Firebase Version)

Aplikasi manajemen waktu yang dibangun dengan Flutter dan Firebase untuk membantu pengguna mengelola tugas-tugas harian mereka dengan efisien.

## 🔥 Migrasi ke Firebase

Aplikasi ini telah direfactor dari menggunakan database lokal SQLite ke **Firebase** sebagai backend. Perubahan utama meliputi:

### ✅ Yang Sudah Dimigrasi ke Firebase:

- **Authentication** - Firebase Auth untuk login/register
- **Database** - Cloud Firestore untuk menyimpan data tugas dan profil user
- **Real-time sync** - Data tersinkronisasi antar device
- **Cloud storage** - Data tersimpan di cloud, bukan lokal

### 🗑️ Yang Dihapus (SQLite Dependencies):

- `sqflite` package
- `DatabaseHelper` service
- `TaskRepository` (local)
- `UserRepository` (local)
- `AuthService` (local)

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

| Komponen         | Teknologi                     |
| ---------------- | ----------------------------- |
| Framework        | Flutter + Dart                |
| Backend          | Firebase (Auth + Firestore)   |
| Authentication   | Firebase Auth                 |
| Database         | Cloud Firestore               |
| Notifikasi       | `flutter_local_notifications` |
| Grafik Statistik | `fl_chart`                    |
| State Management | `provider`                    |
| IDE              | Android Studio / VS Code      |

---

## 🚀 Setup Firebase

### 1. Buat Project Firebase

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Create a project"
3. Ikuti langkah-langkah setup

### 2. Enable Services

- **Authentication** - Enable Email/Password provider
- **Cloud Firestore** - Create database dalam mode test

### 3. Setup Flutter App

1. Install Flutter CLI tools:

   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase untuk Flutter:

   ```bash
   flutterfire configure
   ```

3. Pilih project Firebase yang sudah dibuat
4. Pilih platform (Android/iOS/Web)

### 4. Update Firebase Configuration

File `lib/firebase_options.dart` akan otomatis di-generate. Pastikan konfigurasi sudah benar.

---

## 📂 Struktur Folder Baru (Firebase)

```bash
lib/
│
├── main.dart
├── firebase_options.dart          # Auto-generated Firebase config
├── models/
│   ├── task_model.dart           # Support Firestore & legacy
│   └── user_model.dart           # Support Firestore & legacy
├── screens/
│   ├── login_screen.dart         # ✅ Firebase Auth
│   ├── signup_screen.dart        # ✅ Firebase Auth
│   ├── dashboard_screen.dart     # ✅ Firebase Firestore
│   ├── add_task_screen.dart      # ✅ Firebase Firestore
│   ├── task_list_screen.dart     # ✅ Firebase Firestore
│   ├── reminder_screen.dart      # ✅ Firebase Firestore
│   ├── report_screen.dart        # ✅ Firebase Firestore
│   ├── profile_screen.dart       # ✅ Firebase Auth & Firestore
│   └── user_management_screen.dart # ✅ Firebase Auth & Firestore
├── services/
│   ├── firebase_service.dart           # 🆕 Firebase core
│   ├── firebase_auth_service.dart      # 🆕 Authentication
│   ├── firebase_task_repository.dart   # 🆕 Task management
│   └── notification_service.dart       # Unchanged
└── widgets/                       # (if any)
```

---

## 📋 Installation & Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd manajemen_waktu
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase (Important!)

⚠️ **Anda harus setup Firebase project sendiri:**

1. Buat project di [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password)
3. Enable Cloud Firestore
4. Jalankan `flutterfire configure` di terminal
5. File `firebase_options.dart` akan ter-update otomatis

### 4. Run Application

```bash
flutter run
```

---

## 🗄️ Database Structure (Firestore)

### Collection: `users`

```javascript
{
  uid: "string",           // Firebase Auth UID
  username: "string",
  email: "string",         // Dari Firebase Auth
  tanggalLahir: "timestamp",
  role: "user",           // Default
  createdAt: "timestamp"
}
```

### Collection: `tasks`

```javascript
{
  id: "string",           // Firestore auto-generated
  title: "string",
  description: "string",
  startTime: "timestamp",
  endTime: "timestamp",
  priority: "High|Medium|Low",
  isCompleted: "boolean",
  userId: "string",       // Reference ke Firebase Auth UID
  createdAt: "timestamp"
}
```

---

## 🔄 Perubahan Major dari Versi SQLite

### Authentication

- **Before**: Manual auth dengan SQLite
- **After**: Firebase Auth dengan email/password

### Data Storage

- **Before**: SQLite lokal di device
- **After**: Cloud Firestore (real-time, cloud-based)

### User Management

- **Before**: CRUD users di SQLite
- **After**: Firebase Auth handles users, profile di Firestore

### Task Management

- **Before**: Local SQLite dengan manual sync
- **After**: Real-time Firestore dengan auto-sync

---

## 🔐 Security Rules (Firestore)

Tambahkan security rules di Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users dapat read/write data mereka sendiri
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Tasks hanya bisa diakses oleh pemiliknya
    match /tasks/{taskId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null &&
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

---

## ⚡ Keuntungan Migrasi ke Firebase

1. **Real-time Sync** - Data tersinkronisasi otomatis antar device
2. **Cloud Backup** - Data aman tersimpan di cloud
3. **Scalable** - Dapat menangani banyak user
4. **Authentication** - Sistem auth yang robust dan aman
5. **Offline Support** - Firestore mendukung offline mode
6. **No Server Maintenance** - Firebase mengelola infrastructure

---

## 🐛 Troubleshooting

### Firebase Configuration Issues

```bash
# Re-configure Firebase
flutterfire configure

# Refresh dependencies
flutter clean
flutter pub get
```

### Authentication Errors

- Pastikan Email/Password provider enabled di Firebase Console
- Check Firebase project ID di `firebase_options.dart`

### Firestore Permission Errors

- Setup security rules di Firebase Console
- Pastikan user sudah login sebelum akses data

---

## 📞 Support

Jika mengalami masalah dengan setup Firebase:

1. Check [Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
2. Verify project configuration di Firebase Console
3. Pastikan dependencies terbaru di `pubspec.yaml`

---

## 🎯 Next Steps / Roadmap

- [ ] Implementasi offline mode yang lebih baik
- [ ] Push notifications via Firebase Cloud Messaging
- [ ] File upload untuk attachment tugas (Firebase Storage)
- [ ] Sharing tugas antar user
- [ ] Team/group management

---

**🎉 Selamat! Aplikasi Anda sekarang menggunakan Firebase dan siap untuk production!**

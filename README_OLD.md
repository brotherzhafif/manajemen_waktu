# 🕒 Aplikasi Pengelola Waktu

Aplikasi mobile Flutter untuk membantu pengguna mengatur waktu harian mereka dengan fitur Rencana Harian, Reminder (Notifikasi), dan Statistik Tugas.

---

## 📱 Fitur Utama

- 🔐 **Login & Registrasi**
- 📝 **Manajemen Tugas (CRUD)**
- ⏰ **Reminder Otomatis (Push Notification)**
- 📊 **Statistik Produktivitas (Grafik Harian/Mingguan)**
- 🎯 **Tandai Tugas Selesai / Belum**
- 💾 **Penyimpanan Lokal dengan SQLite**

---

## 🛠️ Teknologi yang Digunakan

| Komponen         | Teknologi                         |
| ---------------- | --------------------------------- |
| Framework        | Flutter + Dart                    |
| Database Lokal   | SQLite (`sqflite`)                |
| Notifikasi       | `flutter_local_notifications`     |
| Grafik Statistik | `fl_chart`                        |
| State Management | `provider`                        |
| Form Validasi    | `flutter_form_builder` (opsional) |
| IDE              | Android Studio / VS Code          |

---

## 📂 Struktur Folder

```bash
lib/
│
├── main.dart
├── models/
│   └── task_model.dart
├── screens/
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── dashboard_screen.dart
│   ├── add_task_screen.dart
│   ├── reminder_screen.dart
│   └── report_screen.dart
├── widgets/
│   └── task_card.dart
├── services/
│   ├── db_service.dart
│   └── notification_service.dart
└── utils/
    └── constants.dart
```

---

## 🚀 Cara Menjalankan Proyek

1. **Clone repository ini:**

   ```bash
   git clone https://github.com/username/manajemen_waktu.git
   cd manajemen_waktu
   ```

2. **Install dependency:**

   ```bash
   flutter pub get
   ```

3. **Jalankan proyek di emulator atau perangkat:**

   ```bash
   flutter run
   ```

---

## 🔔 Konfigurasi Notifikasi

1. Tambahkan permission di `AndroidManifest.xml`:

   ```xml
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```

2. Inisialisasi `flutter_local_notifications` di `main.dart`.

---

## 📌 To-Do Development

- [x] Login & Register (offline)
- [x] CRUD tugas harian
- [x] Reminder dengan notifikasi
- [x] Statistik dan laporan visual

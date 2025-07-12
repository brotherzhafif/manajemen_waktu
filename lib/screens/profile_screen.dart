import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = FirebaseAuthService.instance;
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Coba load session user terlebih dahulu jika belum ada currentUser
      if (_authService.currentUser == null) {
        await _authService.loadUserSession();
      }

      // Mendapatkan data user yang sedang login
      final currentUser = _authService.currentUser;

      if (currentUser == null) {
        // Jika masih null, mungkin user belum login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Silakan login terlebih dahulu')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      setState(() {
        _currentUser = currentUser;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _editProfile() {
    Navigator.pushNamed(
      context,
      '/manajemen-user',
    ).then((_) => _loadUserProfile()); // Reload data setelah kembali
  }

  void _deleteProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus akun Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              setState(() {
                _isLoading = true;
              });
              try {
                if (_currentUser != null && _currentUser!.id != null) {
                  // Hapus akun dari Firebase
                  await _authService.deleteAccount();
                  // Kembali ke halaman login
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Akun berhasil dihapus')),
                  );
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _currentUser == null
        ? const Center(child: Text('Tidak ada data pengguna'))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentUser!.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentUser!.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                _buildProfileCard(
                  title: 'Informasi Akun',
                  children: [
                    _buildInfoRow(
                      Icons.person,
                      'Username',
                      _currentUser!.username,
                    ),
                    const Divider(),
                    _buildInfoRow(Icons.email, 'Email', _currentUser!.email),
                    const Divider(),
                    _buildInfoRow(
                      Icons.cake,
                      'Tanggal Lahir',
                      _currentUser!.tanggalLahir != null
                          ? '${_currentUser!.tanggalLahir!.day}/${_currentUser!.tanggalLahir!.month}/${_currentUser!.tanggalLahir!.year}'
                          : 'Belum diatur',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ),
          );
  }

  Widget _buildProfileCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profil'),
            onPressed: _editProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              'Hapus Akun',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: _deleteProfile,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

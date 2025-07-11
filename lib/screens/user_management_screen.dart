import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userRepository = UserRepository();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isEditing = false;
  int? _editingUserId;
  String? _errorMsg;
  DateTime? _tanggalLahir;
  String _selectedRole = 'user'; // Default role adalah 'user'

  @override
  void initState() {
    super.initState();
    // Penundaan diperlukan karena ModalRoute.of(context) belum tersedia di initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _pickTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggalLahir = picked;
      });
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      // Cek apakah ada parameter dari route
      final Map<String, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args.containsKey('userId')) {
        // Jika ada userId, muat data pengguna tersebut
        final userId = int.parse(args['userId']);
        final user = await _userRepository.getUserById(userId);

        if (user != null) {
          setState(() {
            _usernameController.text = user.username;
            _emailController.text = user.email;
            _editingUserId = user.id;
            _tanggalLahir = user.tanggalLahir;
            _selectedRole = user.role ?? 'user';
            _isEditing = true;
          });
        }
      } else if (args == null || !args.containsKey('isAdmin')) {
        // Jika tidak ada parameter atau bukan dari halaman admin, muat data pengguna yang sedang login
        final currentUser = _authService.currentUser;
        if (currentUser != null) {
          setState(() {
            _usernameController.text = currentUser.username;
            _emailController.text = currentUser.email;
            _editingUserId = currentUser.id;
            _tanggalLahir = currentUser.tanggalLahir;
            _selectedRole = currentUser.role ?? 'user';
            _isEditing = true;
          });
        }
      } else {
        // Jika dari halaman admin tapi tidak ada userId, ini adalah tambah pengguna baru
        setState(() {
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _editingUserId = null;
          _tanggalLahir = null;
          _selectedRole = 'user';
          _isEditing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    // Periksa apakah password dan konfirmasi password cocok untuk pengguna baru
    if (!_isEditing &&
        _passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMsg = 'Password dan konfirmasi password tidak cocok';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      if (_isEditing && _editingUserId != null) {
        // Update existing user
        final updatedUser = User(
          id: _editingUserId,
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text.isNotEmpty
              ? _passwordController.text
              : _authService.currentUser?.password ?? '',
          tanggalLahir: _tanggalLahir,
          role: _selectedRole,
        );

        // Menggunakan metode updateUser dari UserRepository
        await _userRepository.updateUser(updatedUser);

        // Jika user yang diupdate adalah user yang sedang login, update juga di AuthService
        if (_editingUserId == _authService.currentUser?.id) {
          await _authService.updateCurrentUser(updatedUser);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
      } else {
        // Create new user
        final newUser = User(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          tanggalLahir: _tanggalLahir,
          role: _selectedRole,
        );

        // Check if email already exists
        if (await _userRepository.isEmailExists(_emailController.text)) {
          setState(() {
            _isLoading = false;
            _errorMsg = 'Email sudah terdaftar';
          });
          return;
        }

        // Check if username already exists
        if (await _userRepository.isUsernameExists(_usernameController.text)) {
          setState(() {
            _isLoading = false;
            _errorMsg = 'Username sudah digunakan';
          });
          return;
        }

        final userId = await _userRepository.createUser(newUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengguna berhasil ditambahkan')),
        );

        // Clear form after successful creation
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          _tanggalLahir = null;
        });

        // Jika halaman ini dibuka dari halaman admin, kembali ke halaman admin
        final Map<String, dynamic>? args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null && args['isAdmin'] == true) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah ada parameter dari route
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool isAdmin = args != null && args['isAdmin'] == true;
    final String title = args != null && args['title'] != null
        ? args['title']
        : (_isEditing ? 'Edit Profil' : 'Daftar Akun');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(
                    _isEditing ? Icons.person : Icons.person_add,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isEditing ? 'Edit Profil' : 'Tambah Pengguna',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_errorMsg != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMsg!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Dropdown untuk pemilihan peran (hanya ditampilkan untuk admin)
                  if (isAdmin)
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Peran',
                        prefixIcon: Icon(Icons.admin_panel_settings),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'user',
                          child: Text('Pengguna'),
                        ),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRole = value;
                          });
                        }
                      },
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!value.contains('@')) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickTanggalLahir,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Lahir',
                          prefixIcon: Icon(Icons.cake),
                          hintText: 'Pilih tanggal lahir',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: _tanggalLahir == null
                              ? ''
                              : '${_tanggalLahir!.day}/${_tanggalLahir!.month}/${_tanggalLahir!.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: _isEditing
                          ? 'Password Baru (opsional)'
                          : 'Password',
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (!_isEditing && (value == null || value.isEmpty)) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Hanya tampilkan konfirmasi password jika bukan mode edit
                  if (!_isEditing)
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Konfirmasi Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password';
                        }
                        if (value != _passwordController.text) {
                          return 'Password tidak sama';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveUser,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEditing ? 'Simpan Perubahan' : 'Daftar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

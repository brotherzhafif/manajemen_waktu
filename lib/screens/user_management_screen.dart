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
  final _userRepository = UserRepository();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isEditing = false;
  int? _editingUserId;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    // Penundaan diperlukan karena ModalRoute.of(context) belum tersedia di initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    
    try {
      // Cek apakah ada parameter dari route
      final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      if (args != null && args.containsKey('userId')) {
        // Jika ada userId, muat data pengguna tersebut
        final userId = int.parse(args['userId']);
        final user = await _userRepository.getUserById(userId);
        
        if (user != null) {
          setState(() {
            _usernameController.text = user.username;
            _emailController.text = user.email;
            _editingUserId = user.id;
            _isEditing = true;
          });
        }
      } else {
        // Jika tidak ada parameter, muat data pengguna yang sedang login
        final currentUser = _authService.currentUser;
        if (currentUser != null) {
          setState(() {
            _usernameController.text = currentUser.username;
            _emailController.text = currentUser.email;
            _editingUserId = currentUser.id;
            _isEditing = true;
          });
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

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

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
        
        // Jika halaman ini dibuka dari halaman admin, kembali ke halaman admin
        final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool isAdmin = args != null && args['isAdmin'] == true;
    final String title = args != null && args['title'] != null 
        ? args['title'] 
        : (_isEditing ? 'Edit Profil' : 'Tambah Pengguna');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorMsg != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      _errorMsg!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const Text(
                  'Informasi Pengguna',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _isEditing ? 'Password Baru (opsional)' : 'Password',
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (!_isEditing && (value == null || value.isEmpty)) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Password minimal 6 karakter';
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
                        : Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Pengguna'),
                  ),
                ),
              ],
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
    super.dispose();
  }
}
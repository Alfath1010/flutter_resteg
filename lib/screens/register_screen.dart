import 'package:crud_api_sample/api_client.dart';
import 'package:crud_api_sample/models/pelanggan.dart';
import 'package:crud_api_sample/services/pelanggan_service.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final ApiClient apiClient;
  final Function(Pelanggan) onRegisterSuccess;

  const RegisterScreen({
    super.key,
    required this.apiClient,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaPelangganController = TextEditingController();
  final _nomorMejaController = TextEditingController();
  final _noTeleponController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _namaPelangganController.dispose();
    _nomorMejaController.dispose();
    _noTeleponController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_namaPelangganController.text.isEmpty ||
        _nomorMejaController.text.isEmpty ||
        _noTeleponController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final pelanggan = await widget.apiClient.registerPelanggan({
      'nama_pelanggan': _namaPelangganController.text,
      'nomor_meja': _nomorMejaController.text,
      'no_telepon': _noTeleponController.text,
    });

    setState(() => _isLoading = false);

    if (pelanggan != null) {
      // Simpan pelanggan di PelangganService
      PelangganService().setPelanggan(pelanggan);
      widget.onRegisterSuccess(pelanggan);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi gagal')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Pelanggan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _namaPelangganController,
              decoration: const InputDecoration(
                labelText: 'Nama Pelanggan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nomorMejaController,
              decoration: const InputDecoration(
                labelText: 'Nomor Meja',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noTeleponController,
              decoration: const InputDecoration(
                labelText: 'No. Telepon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Registrasi'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:crud_api_sample/api_client.dart';
import 'package:crud_api_sample/models/menu.dart';
import 'package:crud_api_sample/models/pelanggan.dart';
import 'package:crud_api_sample/screens/pesanan_screen.dart';
import 'package:flutter/material.dart';

class MenuListScreen extends StatefulWidget {
  final Pelanggan pelanggan;
  final ApiClient apiClient;

  const MenuListScreen({
    super.key,
    required this.pelanggan,
    required this.apiClient,
  });

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  late Future<List<MenuItem>?> _menuFuture;

  @override
  void initState() {
    super.initState();
    _menuFuture = widget.apiClient.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.pelanggan.namaPelanggan,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Meja: ${widget.pelanggan.nomorMeja} | ID: ${widget.pelanggan.idPelanggan}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<MenuItem>?>(
        future: _menuFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Gagal memuat menu'));
          }

          final menuList = snapshot.data!;
          return ListView.builder(
            itemCount: menuList.length,
            itemBuilder: (context, index) {
              final menuItem = menuList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(menuItem.namaMenu),
                  subtitle: Text('Rp ${menuItem.harga.toString()}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _createOrder(menuItem);
                    },
                    child: const Text('Pesan'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _createOrder(MenuItem menuItem) async {
    final pesanan = await widget.apiClient.createPesanan({
      'id_pelanggan': widget.pelanggan.idPelanggan,
      'tanggal_pesanan': DateTime.now().toIso8601String(),
      'status_pesanan': 'Draft',
    });

    if (pesanan != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PesananScreen(
            pelanggan: widget.pelanggan,
            pesanan: pesanan,
            apiClient: widget.apiClient,
          ),
        ),
      );
    }
  }
}

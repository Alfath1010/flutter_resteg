import 'package:crud_api_sample/api_client.dart';
import 'package:crud_api_sample/models/menu.dart';
import 'package:crud_api_sample/models/pelanggan.dart';
import 'package:crud_api_sample/screens/pesanan_screen.dart';
import 'package:crud_api_sample/screens/register_screen.dart';
import 'package:crud_api_sample/services/pelanggan_service.dart';
import 'package:crud_api_sample/services/pesanan_service.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _menuFuture = widget.apiClient.getAll();
    _initializePesanan();
  }

  /// Initialize pesanan once per pelanggan session
  Future<void> _initializePesanan() async {
    if (PesananServiceActive().getPesanan() == null) {
      final pesanan = await widget.apiClient.createPesanan({
        'id_pelanggan': widget.pelanggan.idPelanggan,
        'tanggal_pesanan': DateTime.now().toIso8601String(),
        'status_pesanan': 'Draft',
      });
      if (pesanan != null) {
        PesananServiceActive().setPesanan(pesanan);
      }
    }
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
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
                    onPressed: _isLoading ? null : () => _addItemAndNavigate(menuItem),
                    child: const Text('Pesan'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToPesanan,
        backgroundColor: Colors.orange,
        label: const Text('Lihat Pesanan'),
        icon: const Icon(Icons.shopping_cart),
      ),
    );
  }

  Future<void> _goToPesanan() async {
    final pesanan = PesananServiceActive().getPesanan();
    if (pesanan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan tidak tersedia')),
      );
      return;
    }
    
    if (mounted) {
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

  Future<void> _addItemAndNavigate(MenuItem menuItem) async {
    // Show qty dialog
    final qty = await _showQtyDialog(menuItem);
    if (qty == null || qty <= 0) return;

    final pesanan = PesananServiceActive().getPesanan();
    if (pesanan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan tidak tersedia. Silakan refresh.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await widget.apiClient.addPesananItem(
      pesanan.idPesanan,
      {'id_menu': menuItem.idMenu, 'jumlah': qty},
    );

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${menuItem.namaMenu} x$qty ditambahkan')),
      );
      // Tetap di menu, tidak navigasi ke pesanan
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan item')),
      );
    }
  }

  Future<int?> _showQtyDialog(MenuItem menuItem) async {
    int qty = 1;
    return showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(menuItem.namaMenu),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Harga: Rp ${menuItem.harga}'),
            const SizedBox(height: 16),
            const Text('Pilih Jumlah:'),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (context, setState) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: qty > 1 ? () => setState(() => qty--) : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$qty',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => qty++),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, qty),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Tambahkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Anda yakin ingin keluar dan mengakhiri pesanan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      PesananServiceActive().clearPesanan();
      await PelangganService().clearPelanggan();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterScreen(
              apiClient: widget.apiClient,
              onRegisterSuccess: (pelanggan) {},
            ),
          ),
        );
      }
    }
  }
}

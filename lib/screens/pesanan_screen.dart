import 'package:crud_api_sample/api_client.dart';
import 'package:crud_api_sample/models/detail_pesanan.dart';
import 'package:crud_api_sample/models/menu.dart';
import 'package:crud_api_sample/models/pelanggan.dart';
import 'package:crud_api_sample/models/pesanan.dart';
import 'package:flutter/material.dart';
import 'checkout_screen.dart';
import 'package:crud_api_sample/services/pelanggan_service.dart';
import 'package:crud_api_sample/services/pesanan_service.dart';
import 'register_screen.dart';

class PesananScreen extends StatefulWidget {
  final Pelanggan pelanggan;
  final Pesanan pesanan;
  final ApiClient apiClient;

  const PesananScreen({
    super.key,
    required this.pelanggan,
    required this.pesanan,
    required this.apiClient,
  });

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  late List<DetailPesanan> _items = [];
  late Future<List<MenuItem>?> _menuFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _menuFuture = widget.apiClient.getAll();
    _loadPesananItems();
    // Update service dengan pesanan terbaru
    PesananServiceActive().setPesanan(widget.pesanan);
  }

  Future<void> _loadPesananItems() async {
    final items = await widget.apiClient.getPesananItems(widget.pesanan.idPesanan);
    setState(() {
      _items = items ?? [];
    });
  }

  Future<void> _addItemToPesanan(MenuItem menuItem) async {
    // Show qty dialog
    final qty = await _showQtyDialog(menuItem);
    if (qty == null || qty <= 0) return;

    setState(() => _isLoading = true);
    
    final result = await widget.apiClient.addPesananItem(
      widget.pesanan.idPesanan,
      {'id_menu': menuItem.idMenu, 'jumlah': qty},
    );

    setState(() => _isLoading = false);

    if (result != null) {
      await _loadPesananItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${menuItem.namaMenu} x$qty ditambahkan')),
        );
      }
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

  Future<void> _deleteItem(DetailPesanan item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item'),
        content: const Text('Yakin ingin menghapus item ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await widget.apiClient.deletePesananItem(
      widget.pesanan.idPesanan,
      item.idDetail,
    );

    if (success) {
      await _loadPesananItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item dihapus')),
        );
      }
    }
  }

  Future<void> _checkout() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan item sebelum checkout')),
      );
      return;
    }

    final result = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          pelanggan: widget.pelanggan,
          pesanan: widget.pesanan,
          items: _items,
          apiClient: widget.apiClient,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context);
    }
  }

  int _getTotalBayar() {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesanan #${widget.pesanan.idPesanan}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Text('Belum ada item. Pilih dari menu di bawah.'),
                  )
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item.namaMenu),
                        subtitle: Text(
                          'Qty: ${item.jumlah} x Rp ${item.hargaSatuan} = Rp ${item.subtotal}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(item),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
              color: Colors.grey[50],
            ),
            child: Text(
              'Total: Rp ${_getTotalBayar()}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            height: 200,
            child: FutureBuilder<List<MenuItem>?>(
              future: _menuFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Gagal memuat menu'));
                }

                final menuList = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: menuList.length,
                  itemBuilder: (context, index) {
                    final menuItem = menuList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    menuItem.namaMenu,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${menuItem.harga}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _addItemToPesanan(menuItem),
                              child: const Text('Tambah'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _items.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _isLoading ? null : _checkout,
              backgroundColor: Colors.green,
              label: const Text('Checkout'),
              icon: const Icon(Icons.payment),
            ),
    );
  }
}

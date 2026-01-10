import 'package:crud_api_sample/api_client.dart';
import 'package:crud_api_sample/models/detail_pesanan.dart';
import 'package:crud_api_sample/models/menu.dart';
import 'package:crud_api_sample/models/pelanggan.dart';
import 'package:crud_api_sample/models/pesanan.dart';
import 'package:flutter/material.dart';

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
  }

  Future<void> _loadPesananItems() async {
    final items = await widget.apiClient.getPesananItems(widget.pesanan.idPesanan);
    setState(() {
      _items = items ?? [];
    });
  }

  Future<void> _addItemToPesanan(MenuItem menuItem) async {
    setState(() => _isLoading = true);
    
    final result = await widget.apiClient.addPesananItem(
      widget.pesanan.idPesanan,
      {'id_menu': menuItem.idMenu, 'jumlah': 1},
    );

    setState(() => _isLoading = false);

    if (result != null) {
      await _loadPesananItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${menuItem.namaMenu} ditambahkan')),
        );
      }
    }
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

    setState(() => _isLoading = true);
    
    final updatedPesanan = await widget.apiClient.checkoutPesanan(
      widget.pesanan.idPesanan,
    );

    setState(() => _isLoading = false);

    if (updatedPesanan != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dikonfirmasi')),
      );
      Navigator.pop(context);
    }
  }

  int _getTotalBayar() {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesanan #${widget.pesanan.idPesanan}'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total: Rp ${_getTotalBayar()}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
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
    );
  }
}

import 'package:crud_api_sample/api_client.dart';
import 'package:crud_api_sample/models/detail_pesanan.dart';
import 'package:crud_api_sample/models/pelanggan.dart';
import 'package:crud_api_sample/models/pesanan.dart';
import 'package:crud_api_sample/services/pelanggan_service.dart';
import 'package:crud_api_sample/services/pesanan_service.dart';
import 'package:flutter/material.dart';
import 'register_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Pelanggan pelanggan;
  final Pesanan pesanan;
  final List<DetailPesanan> items;
  final ApiClient apiClient;

  const CheckoutScreen({
    super.key,
    required this.pelanggan,
    required this.pesanan,
    required this.items,
    required this.apiClient,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'Cash';
  int _paidAmount = 0;
  bool _isProcessing = false;

  int get _total => widget.items.fold(0, (s, it) => s + it.subtotal);

  void _onPaidChanged(String v) {
    final parsed = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    setState(() => _paidAmount = parsed);
  }

  Future<void> _confirmPayment() async {
    if (_paymentMethod == 'Cash' && _paidAmount < _total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah pembayaran kurang dari total')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final updated = await widget.apiClient.checkoutPesanan(widget.pesanan.idPesanan);

    setState(() => _isProcessing = false);

    if (updated != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran berhasil. Terima kasih.')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memproses pembayaran')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final change = (_paidAmount - _total).clamp(0, double.infinity).toInt();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout / Pembayaran'), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
          tooltip: 'Logout',
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pesanan #${widget.pesanan.idPesanan}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, i) {
                  final it = widget.items[i];
                  return ListTile(
                    title: Text(it.namaMenu),
                    subtitle: Text('Qty: ${it.jumlah} x Rp ${it.hargaSatuan}'),
                    trailing: Text('Rp ${it.subtotal}'),
                  );
                },
              ),
            ),
            const Divider(),
            Text('Total: Rp $_total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    items: const [
                      DropdownMenuItem(value: 'Cash', child: Text('Tunai / Cash')),
                      DropdownMenuItem(value: 'Debit', child: Text('Debit / Kartu')),
                      DropdownMenuItem(value: 'QR', child: Text('QR / E-Wallet')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _paymentMethod = v ?? 'Cash';
                        if (_paymentMethod != 'Cash') _paidAmount = _total;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Metode Pembayaran'),
                  ),
                  const SizedBox(height: 8),
                  if (_paymentMethod == 'Cash') ...[
                    TextFormField(
                      initialValue: _paidAmount == 0 ? '' : '$_paidAmount',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Jumlah Bayar (Rp)'),
                      onChanged: _onPaidChanged,
                    ),
                    const SizedBox(height: 8),
                    Text('Kembalian: Rp $change'),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text('Pembayaran non-tunai. Transaksi akan diproses oleh gateway.'),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _confirmPayment,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _isProcessing
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : const Text('Konfirmasi Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
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

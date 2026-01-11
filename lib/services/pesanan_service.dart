import 'package:crud_api_sample/models/pesanan.dart';

/// Service untuk mengelola pesanan yang sedang berlangsung
class PesananServiceActive {
  static final PesananServiceActive _instance = PesananServiceActive._internal();
  
  Pesanan? _currentPesanan;

  factory PesananServiceActive() {
    return _instance;
  }

  PesananServiceActive._internal();

  /// Set pesanan yang sedang aktif
  void setPesanan(Pesanan pesanan) {
    _currentPesanan = pesanan;
  }

  /// Ambil pesanan yang sedang aktif
  Pesanan? getPesanan() {
    return _currentPesanan;
  }

  /// Clear pesanan saat ini (saat logout atau selesai)
  void clearPesanan() {
    _currentPesanan = null;
  }
}

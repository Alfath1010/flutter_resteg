import 'package:crud_api_sample/models/pelanggan.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola state pelanggan di aplikasi
class PelangganService {
  static final PelangganService _instance = PelangganService._internal();
  
  Pelanggan? _currentPelanggan;

  factory PelangganService() {
    return _instance;
  }

  PelangganService._internal();

  /// Inisialisasi service, load data dari SharedPreferences jika ada
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id_pelanggan');
    final nama = prefs.getString('nama_pelanggan');
    if (id != null && nama != null) {
      _currentPelanggan = Pelanggan(
        idPelanggan: id,
        namaPelanggan: nama,
        nomorMeja: prefs.getString('nomor_meja') ?? '',
        noTelepon: prefs.getString('no_telepon') ?? '',
        createdAt: prefs.getString('created_at') ?? '',
        updatedAt: prefs.getString('updated_at') ?? '',
      );
      print('✓ Pelanggan dimuat dari prefs: ID=$id, Nama=$nama');
    }
  }

  /// Simpan pelanggan yang telah registrasi (juga persist ke SharedPreferences)
  Future<void> setPelanggan(Pelanggan pelanggan) async {
    _currentPelanggan = pelanggan;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id_pelanggan', pelanggan.idPelanggan);
    await prefs.setString('nama_pelanggan', pelanggan.namaPelanggan);
    await prefs.setString('nomor_meja', pelanggan.nomorMeja);
    await prefs.setString('no_telepon', pelanggan.noTelepon);
    await prefs.setString('created_at', pelanggan.createdAt);
    await prefs.setString('updated_at', pelanggan.updatedAt);
    print('✓ Pelanggan tersimpan: ID=${pelanggan.idPelanggan}, Nama=${pelanggan.namaPelanggan}');
  }

  /// Ambil pelanggan yang tersimpan
  Pelanggan? getPelanggan() {
    return _currentPelanggan;
  }

  /// Ambil ID pelanggan
  int? getIdPelanggan() {
    return _currentPelanggan?.idPelanggan;
  }

  /// Ambil nama pelanggan
  String? getNamaPelanggan() {
    return _currentPelanggan?.namaPelanggan;
  }

  /// Cek apakah ada pelanggan yang tersimpan
  bool hasPelanggan() {
    return _currentPelanggan != null;
  }

  /// Hapus data pelanggan (logout)
  Future<void> clearPelanggan() async {
    _currentPelanggan = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_pelanggan');
    await prefs.remove('nama_pelanggan');
    await prefs.remove('nomor_meja');
    await prefs.remove('no_telepon');
    await prefs.remove('created_at');
    await prefs.remove('updated_at');
    print('✓ Data pelanggan dihapus');
  }
}

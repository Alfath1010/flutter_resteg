import 'package:crud_api_sample/models/detail_pesanan.dart';

class Pesanan {
  final int idPesanan;
  final int idPelanggan;
  final String? namaPelanggan;
  final String? nomorMeja;
  final String tanggalPesanan;
  final int totalBayar;
  final String statusPesanan;
  final List<DetailPesanan>? items;
  final int? itemsCount;

  Pesanan({
    required this.idPesanan,
    required this.idPelanggan,
    this.namaPelanggan,
    this.nomorMeja,
    required this.tanggalPesanan,
    required this.totalBayar,
    required this.statusPesanan,
    this.items,
    this.itemsCount,
  });

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    List<DetailPesanan>? items;
    if (json['items'] != null) {
      items = List<DetailPesanan>.from(
        json['items'].map((item) => DetailPesanan.fromJson(item)),
      );
    }
    
    return Pesanan(
      idPesanan: _toInt(json['id_pesanan']),
      idPelanggan: _toInt(json['id_pelanggan']),
      namaPelanggan: json['nama_pelanggan'],
      nomorMeja: json['nomor_meja'],
      tanggalPesanan: json['tanggal_pesanan'] ?? '',
      totalBayar: _toInt(json['total_bayar']),
      statusPesanan: json['status_pesanan'] ?? '',
      items: items,
      itemsCount: _toIntNullable(json['items_count']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _toIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

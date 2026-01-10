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
      idPesanan: json['id_pesanan'] ?? 0,
      idPelanggan: json['id_pelanggan'] ?? 0,
      namaPelanggan: json['nama_pelanggan'],
      nomorMeja: json['nomor_meja'],
      tanggalPesanan: json['tanggal_pesanan'] ?? '',
      totalBayar: json['total_bayar'] ?? 0,
      statusPesanan: json['status_pesanan'] ?? '',
      items: items,
      itemsCount: json['items_count'],
    );
  }
}

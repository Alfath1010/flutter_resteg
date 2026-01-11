class DetailPesanan {
  final int idDetail;
  final int idPesanan;
  final int idMenu;
  final String namaMenu;
  final int jumlah;
  final int hargaSatuan;
  final int subtotal;
  final String? catatanKhusus;

  DetailPesanan({
    required this.idDetail,
    required this.idPesanan,
    required this.idMenu,
    required this.namaMenu,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
    this.catatanKhusus,
  });

  factory DetailPesanan.fromJson(Map<String, dynamic> json) {
    return DetailPesanan(
      idDetail: _toInt(json['id_detail']),
      idPesanan: _toInt(json['id_pesanan']),
      idMenu: _toInt(json['id_menu']),
      namaMenu: json['nama_menu'] ?? '',
      jumlah: _toInt(json['jumlah']),
      hargaSatuan: _toInt(json['harga_satuan']),
      subtotal: _toInt(json['subtotal']),
      catatanKhusus: json['catatan_khusus'],
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

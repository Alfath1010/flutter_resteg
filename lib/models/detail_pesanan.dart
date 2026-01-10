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
      idDetail: json['id_detail'] ?? 0,
      idPesanan: json['id_pesanan'] ?? 0,
      idMenu: json['id_menu'] ?? 0,
      namaMenu: json['nama_menu'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      hargaSatuan: json['harga_satuan'] ?? 0,
      subtotal: json['subtotal'] ?? 0,
      catatanKhusus: json['catatan_khusus'],
    );
  }
}

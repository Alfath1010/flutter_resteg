class Pelanggan {
  final int idPelanggan;
  final String namaPelanggan;
  final String nomorMeja;
  final String noTelepon;
  final String createdAt;
  final String updatedAt;

  Pelanggan({
    required this.idPelanggan,
    required this.namaPelanggan,
    required this.nomorMeja,
    required this.noTelepon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pelanggan.fromJson(Map<String, dynamic> json) {
    return Pelanggan(
      idPelanggan: _toInt(json['id_pelanggan']),
      namaPelanggan: json['nama_pelanggan'] ?? '',
      nomorMeja: json['nomor_meja'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

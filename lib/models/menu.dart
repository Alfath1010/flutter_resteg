class MenuItem {
  final int idMenu;
  final String namaMenu;
  final int harga;
  final int idKategori;

  MenuItem({
    required this.idMenu,
    required this.namaMenu,
    required this.harga,
    required this.idKategori,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      idMenu: _toInt(json['id_menu']),
      namaMenu: json['nama_menu'] ?? '',
      harga: _toInt(json['harga']),
      idKategori: _toInt(json['id_kategori']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

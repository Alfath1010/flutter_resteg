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
      idMenu: json['id_menu'] ?? 0,
      namaMenu: json['nama_menu'] ?? '',
      harga: json['harga'] ?? 0,
      idKategori: json['id_kategori'] ?? 0,
    );
  }
}

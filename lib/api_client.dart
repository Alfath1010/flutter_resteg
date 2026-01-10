import 'dart:convert';

import 'package:crud_api_sample/models/detail_pesanan.dart';
import 'package:crud_api_sample/models/menu.dart';
import 'package:crud_api_sample/models/pelanggan.dart';
import 'package:crud_api_sample/models/pesanan.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  late String apiUrl;

  ApiClient(this.apiUrl) {
    _init();
  }

  void _init() async {
    print("ApiClient terinisialisasi");
  }

  Future<void> createItem(Map<String, String> requests) async {
    try {
      var postUri = Uri.parse("$apiUrl/create");
      var request = http.MultipartRequest("POST", postUri);

      requests.forEach((key, value) {
        request.fields[key] = value;
      });

      await request.send();
    } catch (e) {
      //
    }
  }

  Future<void> updateItem(Map<String, String> requests, String key) async {
    try {
      var postUri = Uri.parse("$apiUrl/update/$key");
      var request = http.MultipartRequest("POST", postUri);

      requests.forEach((key, value) {
        request.fields[key] = value;
      });
      
      await request.send();
    } catch (e) {
      //
    }
  }

  Future<List<dynamic>?> getItem(String key) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/get/$key"));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body;
      } else {
        return null;
      }
    } catch (e) {
      //
    }
    return null;
  }

  Future<List<MenuItem>?> getAll() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/menu/get"));

      if (response.statusCode == 200) {
        List<MenuItem> returnData = <MenuItem>[];
        List<dynamic> body = await jsonDecode(response.body);
        for (var value in body) {
          var menuItem = MenuItem.fromJson(value);
          returnData.add(menuItem);
        }
        return returnData;
      } else {
        return null;
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  Future<void> deleteItem(String key) async {
    try {
      var postUri = Uri.parse("$apiUrl/delete/$key");
      var request = http.MultipartRequest("DELETE", postUri);

      await request.send();
    } catch (e) {
      //
    }
  }

  // PELANGGAN ENDPOINTS
  Future<Pelanggan?> registerPelanggan(Map<String, String> data) async {
    try {
      var postUri = Uri.parse("$apiUrl/create");
      var request = http.MultipartRequest("POST", postUri);

      data.forEach((key, value) {
        request.fields[key] = value;
      });

      var response = await request.send();
      if (response.statusCode == 201) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        return Pelanggan.fromJson(jsonResponse);
      }
    } catch (e) {
      print("Error registering pelanggan: $e");
    }
    return null;
  }

  Future<Pelanggan?> getPelanggan(int idPelanggan) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/get/$idPelanggan"));
      if (response.statusCode == 200) {
        return Pelanggan.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Error fetching pelanggan: $e");
    }
    return null;
  }

  // PESANAN ENDPOINTS
  /// Membuat pesanan baru
  /// 
  /// API memvalidasi:
  /// - id_pelanggan: required, harus ada di tabel pelanggan
  /// - tanggal_pesanan: optional, default Carbon::now() jika tidak dikirim
  /// - status_pesanan: optional, default 'Draft' jika tidak dikirim
  /// 
  /// total_bayar selalu 0 (diatur di backend)
  Future<Pesanan?> createPesanan(Map<String, dynamic> data) async {
    try {
      // Validasi minimal di client
      if (!data.containsKey('id_pelanggan') || data['id_pelanggan'] == null) {
        throw Exception('id_pelanggan is required');
      }

      final payload = {
        'id_pelanggan': data['id_pelanggan'],
      };

      // Tambahkan field opsional jika ada
      if (data.containsKey('tanggal_pesanan') && data['tanggal_pesanan'] != null) {
        payload['tanggal_pesanan'] = data['tanggal_pesanan'];
      }

      if (data.containsKey('status_pesanan') && data['status_pesanan'] != null) {
        payload['status_pesanan'] = data['status_pesanan'];
      }

      final response = await http.post(
        Uri.parse("$apiUrl/pesanan/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        return Pesanan.fromJson(jsonDecode(response.body));
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error creating pesanan: $e");
    }
    return null;
  }

  Future<List<Pesanan>?> getAllPesanan({int? idPelanggan}) async {
    try {
      String url = "$apiUrl/pesanan/get";
      if (idPelanggan != null) {
        url += "?id_pelanggan=$idPelanggan";
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Pesanan.fromJson(item)).toList();
      }
    } catch (e) {
      print("Error fetching pesanan: $e");
    }
    return null;
  }

  Future<Pesanan?> getPesananDetail(int idPesanan) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/pesanan/get/$idPesanan"));
      if (response.statusCode == 200) {
        return Pesanan.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Error fetching pesanan detail: $e");
    }
    return null;
  }

  // PESANAN ITEMS ENDPOINTS
  Future<DetailPesanan?> addPesananItem(
    int idPesanan,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/pesanan/$idPesanan/items"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        return DetailPesanan.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Error adding pesanan item: $e");
    }
    return null;
  }

  Future<List<DetailPesanan>?> getPesananItems(int idPesanan) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/pesanan/$idPesanan/items"));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => DetailPesanan.fromJson(item)).toList();
      }
    } catch (e) {
      print("Error fetching pesanan items: $e");
    }
    return null;
  }

  Future<bool> deletePesananItem(int idPesanan, int idDetail) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiUrl/pesanan/$idPesanan/items/$idDetail"),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting pesanan item: $e");
    }
    return false;
  }

  Future<Pesanan?> checkoutPesanan(int idPesanan) async {
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/pesanan/$idPesanan/checkout"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status_pesanan": "Proses"}),
      );
      if (response.statusCode == 200) {
        return Pesanan.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Error checking out pesanan: $e");
    }
    return null;
  }
}

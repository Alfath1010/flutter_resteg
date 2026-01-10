import 'package:crud_api_sample/api_client.dart';
import 'package:crud_api_sample/models/pelanggan.dart';
import 'package:crud_api_sample/screens/menu_list_screen.dart';
import 'package:crud_api_sample/screens/register_screen.dart';
import 'package:crud_api_sample/services/pelanggan_service.dart';
import 'package:flutter/material.dart';

final ApiClient _apiClient = ApiClient("http://localhost:8000/api");

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PelangganService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restoran Ordering',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Pelanggan? _currentPelanggan;

  @override
  void initState() {
    super.initState();
    // Cek apakah ada pelanggan yang sudah tersimpan (sudah dimuat di main.init)
    _currentPelanggan = PelangganService().getPelanggan();
    if (_currentPelanggan != null) {
      // jika sudah terdaftar, langsung navigasi ke menu
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MenuListScreen(
              pelanggan: _currentPelanggan!,
              apiClient: _apiClient,
            ),
          ),
        );
      });
    }
  }

  void _handleRegisterSuccess(Pelanggan pelanggan) {
    setState(() {
      _currentPelanggan = pelanggan;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MenuListScreen(
          pelanggan: pelanggan,
          apiClient: _apiClient,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegisterScreen(
      apiClient: _apiClient,
      onRegisterSuccess: _handleRegisterSuccess,
    );
  }
}
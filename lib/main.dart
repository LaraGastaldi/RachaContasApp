import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:rachacontas/providers.dart';
import 'package:rachacontas/screens/add_debt_screen.dart';
import 'package:rachacontas/screens/configuration_screen.dart';
import 'package:rachacontas/screens/dashboard_screen.dart';
import 'package:rachacontas/screens/debt_screen.dart';
import 'package:rachacontas/screens/edit_user_screen.dart';
import 'package:rachacontas/screens/login_screen.dart';
import 'package:rachacontas/screens/pay_debt_screen.dart';
import 'package:rachacontas/screens/register_screen.dart';

String? jwt;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerProviders();

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    jwt = await const FlutterSecureStorage().read(key: 'token');
    runApp(const MyApp());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Racha Contas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => jwt != null ? DashboardScreen() : LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => DashboardScreen(),
        '/register': (context) => RegisterScreen(),
        '/config': (context) => ConfigurationScreen(),
        '/add-debt': (context) => AddDebtScreen(),
        '/debt': (context) => DebtScreen(),
        '/edit-user': (context) => EditUserScreen(),
        '/pay-debt': (context) => PayDebtScreen(),
      },
      initialRoute: '/',
    );
  }
}
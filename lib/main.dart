import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'models/adresse.dart';
import 'models/client.dart';
import 'pages/carte_page.dart';
import 'pages/client_page.dart';
import 'pages/datagrid_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/picture_page.dart';
import 'pages/qrcode_page.dart';
import 'pages/register_page.dart';
import 'pages/splash_page.dart';

Future<void> main() async {
  // Obligatoire avant tout appel asynchrone dans main()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Supabase avec l'URL du projet et la clé anonyme.
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );

  // Initialisation de Hive (cache local) et enregistrement des adapters.
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ClientAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(AdresseAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase',
      // désactivation du mode debug
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      // définition des routes
      initialRoute: LoginPage.route,
      routes: {
        LoginPage.route: (context) => const LoginPage(),
        RegisterPage.route: (context) => const RegisterPage(),
        SplashPage.route: (context) => const SplashPage(),
        HomePage.route: (context) => const HomePage(),
        CartePage.route: (context) => const CartePage(),
        PicturePage.route: (context) => const PicturePage(),
        ClientPage.route: (context) => const ClientPage(),
        DatagridPage.route: (context) => const DatagridPage(),
        QrPage.route: (context) => const QrPage(),
      },
    );
  }
}

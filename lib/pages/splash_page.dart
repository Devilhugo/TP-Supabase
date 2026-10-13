import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../services/client_service.dart';
import 'home_page.dart';

/// Splash screen affiché après la connexion :
/// charge les clients Supabase dans le cache Hive.
class SplashPage extends StatefulWidget {
  static const route = '/splash';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  final Logger logger = Logger();
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  late final Animation<double> _scale = Tween<double>(begin: 0.8, end: 1.15)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  Timer? _timer;
  String _statut = 'Chargement des clients...';

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final debut = DateTime.now();
    try {
      final nb = await ClientService()
          .syncClients()
          .timeout(const Duration(seconds: 10));
      _statut = '$nb clients mis en cache';
    } catch (e) {
      logger.e('Chargement Supabase impossible : $e');
      _statut = 'Hors ligne : utilisation du cache local';
    }
    if (!mounted) return;
    setState(() {});

    // Durée minimale d'affichage de 2 secondes (Timer demandé par le TP)
    final reste = const Duration(seconds: 2) - DateTime.now().difference(debut);
    _timer = Timer(reste.isNegative ? Duration.zero : reste, () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomePage.route);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: const Icon(Icons.cloud_download,
                    size: 100, color: Colors.blue),
              ),
              const SizedBox(height: 30),
              const LinearProgressIndicator(),
              const SizedBox(height: 15),
              Text(_statut),
            ],
          ),
        ),
      ),
    );
  }
}

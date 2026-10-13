import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/authentification_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/app_drawer.dart';

class _Lien {
  final IconData icone;
  final String titre;
  final String url;
  final bool verifierInternet;
  const _Lien(this.icone, this.titre, this.url, {this.verifierInternet = false});
}

class HomePage extends StatefulWidget {
  static const route = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Logger logger = Logger();
  final AuthentificationService _authService = AuthentificationService();
  // Pseudo de l'utilisateur (ou son email s'il n'a pas de pseudo).
  String? _nom;
  StreamSubscription<AuthState>? _authSub;

  static const List<_Lien> _liens = [
    _Lien(Icons.public, 'Lequipe', 'https://www.lequipe.fr',
        verifierInternet: true),
    _Lien(Icons.calendar_month, 'Agenda', 'content://com.android.calendar/time/'),
    _Lien(Icons.email, 'Email', 'mailto:contact@greta.fr',
        verifierInternet: true),
    _Lien(Icons.phone, 'Telephone', 'tel:0512234534'),
    _Lien(Icons.sms, 'SMS', 'sms:0550101234'),
  ];

  @override
  void initState() {
    super.initState();
    _chargerNom();
    // Mise à jour de l'AppBar quand le pseudo est modifié depuis le profil.
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.userUpdated) _chargerNom();
    });
  }

  Future<void> _chargerNom() async {
    final nom = await _authService.getNomAffiche();
    if (mounted) setState(() => _nom = nom);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _ouvrir(_Lien lien) async {
    final messenger = ScaffoldMessenger.of(context);

    if (lien.verifierInternet && !await ConnectivityService.checkInternet()) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Probleme de connexion Internet.')),
      );
      return;
    }

    try {
      final ok = await launchUrl(
        Uri.parse(lien.url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        messenger.showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir ${lien.url}')),
        );
      }
    } catch (e) {
      logger.e('Erreur url_launcher : $e');
      messenger.showSnackBar(
        SnackBar(content: Text('Aucune application pour ouvrir ${lien.url}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          'Accueil - Bienvenue ${_nom ?? ''}',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _liens.length,
        itemBuilder: (context, index) {
          final lien = _liens[index];
          return Card(
            child: ListTile(
              leading: Icon(lien.icone),
              title: Text(lien.titre),
              subtitle: Text(lien.url, style: const TextStyle(fontSize: 12)),
              onTap: () => _ouvrir(lien),
            ),
          );
        },
      ),
    );
  }
}

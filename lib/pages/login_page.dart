import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/authentification_service.dart';
import 'splash_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const route = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Contrôleurs des champs email et mot de passe.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthentificationService _authService = AuthentificationService();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  /// Processus de connexion.
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final pwd = _passwordController.text;
    if (email.isEmpty || pwd.isEmpty) {
      _snack('Saisissez votre email et votre mot de passe.', Colors.orange);
      return;
    }

    setState(() => _loading = true);
    try {
      final ok = await _authService.login(login: email, pwd: pwd);
      if (!mounted) return;
      if (ok) {
        _snack('Connexion réussie.', Colors.green);
        // Redirection vers le splash screen (chargement du cache)
        // puis l'accueil, en passant l'email entre les écrans.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashPage(email: email)),
        );
      } else {
        _snack('La connexion a échouée pour une raison inconnue !', Colors.red);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _snack('Erreur durant la connexion : ${e.message}', Colors.red);
    } catch (e) {
      if (!mounted) return;
      _snack("Une erreur s'est produite !", Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _motDePasseOublie() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _snack('Saisissez d\'abord votre email.', Colors.orange);
      return;
    }
    try {
      await _authService.resetPassword(email);
      if (!mounted) return;
      _snack('Email de réinitialisation envoyé à $email.', Colors.green);
    } catch (e) {
      if (!mounted) return;
      _snack('Envoi impossible : $e', Colors.red);
    }
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[200],
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 100),
                const SizedBox(height: 40),
                Text('Bienvenue!', style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: _decoration('Login'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _decoration('Mot de passe'),
                  onFieldSubmitted: (_) => _login(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _motDePasseOublie,
                    child: Text('Mot de passe oublié?',
                        style: TextStyle(color: Colors.grey[600])),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Connexion'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

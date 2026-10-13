import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/authentification_service.dart';
import 'splash_page.dart';

/// Page d'inscription : création d'un compte Supabase (email + mot de passe).
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const route = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Contrôleurs des champs email, mot de passe et confirmation.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final AuthentificationService _authService = AuthentificationService();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  /// Processus d'inscription.
  Future<void> _register() async {
    final email = _emailController.text.trim();
    final pwd = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || pwd.isEmpty) {
      _snack('Saisissez votre email et votre mot de passe.', Colors.orange);
      return;
    }
    if (!email.contains('@')) {
      _snack('Adresse email invalide.', Colors.orange);
      return;
    }
    // Supabase impose 6 caractères minimum par défaut.
    if (pwd.length < 6) {
      _snack('Le mot de passe doit contenir au moins 6 caractères.',
          Colors.orange);
      return;
    }
    if (pwd != confirm) {
      _snack('Les mots de passe ne correspondent pas.', Colors.orange);
      return;
    }

    setState(() => _loading = true);
    try {
      final connecte = await _authService.signUp(email: email, pwd: pwd);
      if (!mounted) return;
      if (connecte) {
        _snack('Inscription réussie.', Colors.green);
        // Même parcours qu'après une connexion : splash puis accueil.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashPage(email: email)),
        );
      } else {
        // Confirmation par email activée dans Supabase.
        _snack(
          'Compte créé ! Confirmez votre email ($email) puis connectez-vous.',
          Colors.green,
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _snack("Erreur durant l'inscription : ${e.message}", Colors.red);
    } catch (e) {
      if (!mounted) return;
      _snack("Une erreur s'est produite !", Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
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
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Inscription'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, size: 100),
                const SizedBox(height: 40),
                Text('Créez votre compte',
                    style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: _decoration('Email'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _decoration('Mot de passe (6 caractères min.)'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: _decoration('Confirmer le mot de passe'),
                  onFieldSubmitted: (_) => _register(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("S'inscrire"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Déjà un compte ? Se connecter',
                      style: TextStyle(color: Colors.grey[600])),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

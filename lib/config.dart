/// Configuration de l'application.
/// Remplace les deux valeurs Supabase par celles de TON projet
/// (Project Settings > API dans le dashboard Supabase).
class AppConfig {
  static const String supabaseUrl = 'https://VOTRE-PROJET.supabase.co';
  static const String supabaseAnonKey = 'VOTRE_ANON_KEY';

  // Coordonnées du Greta (Vannes)
  static const double gretaLat = 47.64816378970705;
  static const double gretaLng = -2.775053361868542;
}

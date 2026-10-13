# TP Supabase – Flutter

Application Flutter du TP Supabase : authentification, liste de clients
synchronisée depuis Supabase avec cache local Hive, carte OpenStreetMap,
photo / scan de documents en PDF, scanner de QR codes et DataGrid Syncfusion.

## 1. Installation

Prérequis : Flutter (Dart SDK >= 3.8).

```bash
git clone https://github.com/Devilhugo/TP-Supabase.git
cd TP-Supabase
flutter pub get
```

Toutes les dépendances sont déjà déclarées dans `pubspec.yaml`, et les
dossiers des plateformes sont inclus dans le dépôt. L'appli est prévue
pour Android.

Les adapters Hive (`client.g.dart`, `adresse.g.dart`) sont déjà fournis.
Pour les régénérer, ajoute d'abord `build_runner` et `hive_generator` :

```bash
flutter pub add dev:build_runner dev:hive_generator
dart run build_runner build --delete-conflicting-outputs
```

Si `hive_generator` refuse de s'installer (conflit de versions avec un SDK
Dart récent), ce n'est pas grave : les fichiers `.g.dart` fournis suffisent.

## 2. Supabase

1. Crée un projet sur supabase.com.
2. Authentication > Users > Add user : crée un utilisateur de test
   (coche "Auto Confirm User").
3. SQL Editor : exécute `supabase_setup.sql` (tables, clé étrangère,
   données, policies RLS).
4. Project Settings > API Keys : copie l'URL du projet et la
   **publishable key** (`sb_publishable_...`, ou la clé `anon` dans l'onglet
   Legacy) dans `lib/config.dart`.

Le fichier `lib/config.dart` du dépôt est déjà configuré avec le projet
Supabase du TP. Pour utiliser ton propre projet, remplace ces deux valeurs.

> Ne mets jamais la **secret key** (`sb_secret_...` / `service_role`) dans
> l'appli : elle contourne les règles RLS et donne tous les droits sur la
> base. La publishable key, elle, peut être publique : ce sont les policies
> RLS de `supabase_setup.sql` qui protègent les données (lecture réservée
> aux utilisateurs connectés).

## 3. Android

Les permissions et les `<queries>` nécessaires sont déjà déclarées dans
`android/app/src/main/AndroidManifest.xml` :

- permissions `INTERNET`, `ACCESS_NETWORK_STATE` et `CAMERA` ;
- `<queries>` pour ouvrir les liens `https`, `tel`, `sms` et `mailto`
  (utilisés par url_launcher).

`minSdk` reprend la valeur par défaut de Flutter (`flutter.minSdkVersion`
dans `android/app/build.gradle.kts`). Si mobile_scanner ou
cunning_document_scanner réclament une version plus élevée, mets `minSdk = 23`.
Pour les erreurs Gradle/JDK, voir l'annexe du TP.

## 4. Arborescence

```
lib/
├── main.dart                 init Supabase + Hive, routes
├── config.dart               URL + clé anon Supabase
├── models/                   Client, Adresse (+ adapters Hive)
├── storage/databaseHelper.dart  CRUD Hive
├── services/
│   ├── authentification_service.dart  login/logout + shared_preferences
│   ├── client_service.dart            Supabase -> cache Hive
│   └── connectivity_service.dart      vérification Internet
├── widgets/app_drawer.dart   menu
└── pages/
    ├── login_page.dart       étapes 17-20, 23
    ├── splash_page.dart      étape 36 (chargement du cache)
    ├── home_page.dart        étapes 2-3 (url_launcher)
    ├── carte_page.dart       étapes 3-5 (OpenStreetMap + marker)
    ├── picture_page.dart     étapes 7-12 (photo, galerie, scan -> PDF)
    ├── pdf_screen.dart       visualisation + partage du PDF
    ├── client_page.dart      étapes 29-35 (liste + jointure)
    ├── datagrid_page.dart    étape 38 (Syncfusion)
    └── qrcode_page.dart      étape 37 (mobile_scanner)

test/widget_test.dart         tests des modèles Client / Adresse
supabase_setup.sql            script de création de la base
```

## 5. Lancer et tester

```bash
flutter run          # lance l'appli sur l'appareil / émulateur
flutter analyze      # vérifie le code
flutter test         # lance les tests
```

Les tests vérifient la conversion des données Supabase (JSON) en objets
`Client` / `Adresse` ; ils ne nécessitent pas de connexion à Supabase.

## Parcours de l'appli

Login -> splash (synchro Supabase -> Hive, 2 s minimum) -> Accueil
(email dans l'AppBar). Toutes les pages reviennent sur `/home` via la
flèche ; Déconnexion vide la session, les préférences et le cache, puis
renvoie sur `/login`.

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
dossiers des plateformes (android, ios, web, windows, linux, macos) sont
inclus dans le dépôt.

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
4. Project Settings > API : copie l'URL et la clé `anon` dans
   `lib/config.dart` (à la place de `VOTRE-PROJET` et `VOTRE_ANON_KEY`).
   Sans ça, l'appli ne peut pas se connecter.

## 3. Android

Dans `android/app/src/main/AndroidManifest.xml`, avant `<application>` :

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

Et dans le bloc `<queries>` (il existe déjà dans le template Flutter) :

```xml
<intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
<intent><action android:name="android.intent.action.VIEW"/><data android:scheme="tel"/></intent>
<intent><action android:name="android.intent.action.VIEW"/><data android:scheme="sms"/></intent>
<intent><action android:name="android.intent.action.SENDTO"/><data android:scheme="mailto"/></intent>
```

Dans `android/app/build.gradle(.kts)`, vérifie `minSdk` >= 21
(mets 23 si mobile_scanner ou cunning_document_scanner le réclament).
Pour les erreurs Gradle/JDK, voir l'annexe du TP.

## 4. iOS (si besoin)

Dans `ios/Runner/Info.plist` :

```xml
<key>NSCameraUsageDescription</key>
<string>Prendre des photos et scanner des documents/QR codes</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Choisir une image dans la galerie</string>
```

## 5. Arborescence

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

## 6. Lancer et tester

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

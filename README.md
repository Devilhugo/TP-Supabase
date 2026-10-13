# TP Supabase – Flutter

## 1. Installation

Pars du projet du prof (repo `tpsupabase`) et remplace le dossier `lib/`
par celui-ci. Puis, à la racine du projet :

```bash
flutter pub add supabase_flutter url_launcher internet_connection_checker \
  flutter_map latlong2 logger image_picker cunning_document_scanner pdf \
  flutter_pdfview path_provider share_plus shared_preferences hive \
  hive_flutter mobile_scanner syncfusion_flutter_datagrid
flutter pub add dev:build_runner dev:hive_generator
```

Les adapters Hive (`client.g.dart`, `adresse.g.dart`) sont déjà fournis.
Tu peux les régénérer avec :

```bash
dart run build_runner build --delete-conflicting-outputs
```

Si `hive_generator` refuse de s'installer (conflit de versions avec un SDK
Dart récent), retire-le : les fichiers `.g.dart` fournis suffisent.

## 2. Supabase

1. Crée un projet sur supabase.com.
2. Authentication > Users > Add user : crée un utilisateur de test
   (coche "Auto Confirm User").
3. SQL Editor : exécute `supabase_setup.sql` (tables, clé étrangère,
   données, policies RLS).
4. Project Settings > API : copie l'URL et la clé `anon` dans
   `lib/config.dart`.

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
```

## Parcours de l'appli

Login -> splash (synchro Supabase -> Hive, 2 s minimum) -> Accueil
(email dans l'AppBar). Toutes les pages reviennent sur `/home` via la
flèche ; Déconnexion vide la session, les préférences et le cache, puis
renvoie sur `/login`.

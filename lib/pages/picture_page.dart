import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_screen.dart';

class PicturePage extends StatefulWidget {
  static const route = '/picture';
  const PicturePage({super.key});

  @override
  State<PicturePage> createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  final Logger logger = Logger();
  final ImagePicker _picker = ImagePicker();

  File? image; // image de la galerie
  File? photo; // photo prise avec l'appareil
  String? pathFile; // chemin du dernier PDF généré

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Méthode pour insérer des images de la galerie
  Future<void> pickGalerie() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      // Si l'utilisateur annule la récupération de l'image
      if (picked == null) return;
      setState(() => image = File(picked.path));
    } catch (e) {
      logger.e('Erreur au chargement de l\'image: $e');
      _snack('Impossible de charger l\'image.');
    }
  }

  /// Méthode pour prendre une photo
  Future<void> pickPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => photo = File(picked.path));
    } catch (e) {
      logger.e('Erreur à la prise de photo: $e');
      _snack('Impossible de prendre la photo.');
    }
  }

  /// Méthode pour construire une photo
  Widget buildPhoto(String path) {
    return Image.file(
      File(path),
      // fit image in its width and height
      fit: BoxFit.cover,
      // set the alignment of image
      alignment: Alignment.center,
    );
  }

  /// Méthode pour lancer le scanner et convertir le scan en PDF
  Future<void> startScan(BuildContext context) async {
    // liste des images scannées par l'appli
    List<String> pictures;
    try {
      pictures = await CunningDocumentScanner.getPictures() ?? [];
    } catch (exception) {
      logger.e(exception);
      _snack('Le scanner n\'a pas pu démarrer.');
      return;
    }
    // Si l'utilisateur annule le scan
    if (!mounted || pictures.isEmpty) return;

    try {
      final pdf = pw.Document();
      for (final picture in pictures) {
        // Créer une image à partir du fichier
        final img = pw.MemoryImage(await File(picture).readAsBytes());
        pdf.addPage(pw.Page(
          build: (pw.Context ctx) =>
              pw.Center(child: pw.Image(img, fit: pw.BoxFit.contain)),
        ));
      }

      // path du document pour le pdf
      final Directory output = await getApplicationDocumentsDirectory();
      final now = DateTime.now(); // utilisé pour créer le nom du fichier
      final pathFichier = '${output.path}/pdf-${now.day}-${now.month}-'
          '${now.year}-${now.hour}-${now.minute}-${now.second}.pdf';

      // écriture du PDF et sauvegarde dans le dossier de l'application
      await File(pathFichier).writeAsBytes(await pdf.save());
      logger.i('PDF créé : $pathFichier');

      if (!mounted) return;
      setState(() => pathFile = pathFichier);
      _openPDF(this.context, pathFichier);
    } catch (exception) {
      logger.e(exception);
      _snack('Erreur lors de la création du PDF.');
    }
  }

  /// Méthode pour ouvrir le PDF : on passe le fichier à PDFScreen
  /// via le constructeur (passage de données entre écrans).
  void _openPDF(BuildContext context, String? fichier) {
    if (fichier == null) {
      _snack('Aucun PDF : lancez d\'abord un scan.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PDFScreen(path: fichier)),
    );
  }

  Widget _apercu(File? fichier) {
    if (fichier == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        height: 250,
        child: buildPhoto(fichier.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Photos et Galerie')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Divider(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickGalerie,
              child: const Text('Image de la galerie'),
            ),
            _apercu(image),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickPhoto,
              child: const Text('Image Photo'),
            ),
            _apercu(photo),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => startScan(context),
              child: const Text('SCANNER'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _openPDF(context, pathFile),
              child: const Text('Ouvrir le PDF'),
            ),
            if (pathFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(pathFile!.split('/').last,
                    style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

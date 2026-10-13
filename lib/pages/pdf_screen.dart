import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';

/// Cette classe affiche un fichier PDF
class PDFScreen extends StatefulWidget {
  // chemin du fichier PDF, reçu depuis PicturePage
  final String? path;

  const PDFScreen({super.key, this.path});

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  final Logger logger = Logger();

  Future<void> _partager() async {
    if (widget.path == null) return;
    try {
      // API share_plus >= 11. Sur une version plus ancienne :
      // Share.shareXFiles([XFile(widget.path!)], text: 'SCAN PDF');
      await SharePlus.instance.share(
        ShareParams(files: [XFile(widget.path!)], text: 'SCAN PDF'),
      );
    } catch (e) {
      logger.e('Erreur partage : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _partager),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (nbPages) {
              // (le code du TP écrivait `pages = pages`, ce qui ne
              // modifiait jamais l'attribut de la classe)
              setState(() {
                pages = nbPages ?? 0;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() => errorMessage = error.toString());
              logger.e(error.toString());
            },
            onPageError: (page, error) {
              setState(() => errorMessage = '$page: ${error.toString()}');
              logger.e('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              if (!_controller.isCompleted) {
                _controller.complete(pdfViewController);
              }
            },
            onLinkHandler: (String? uri) => logger.i('goto uri: $uri'),
            onPageChanged: (int? page, int? total) {
              logger.i('page change: $page/$total');
              setState(() => currentPage = page ?? 0);
            },
          ),
          if (errorMessage.isNotEmpty)
            Center(child: Text(errorMessage))
          else if (!isReady)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, snapshot) {
          if (snapshot.hasData && pages > 0) {
            return FloatingActionButton.extended(
              label: Text('Page ${currentPage + 1}/$pages'),
              // passe à la page suivante (revient au début à la fin)
              onPressed: () async {
                await snapshot.data!.setPage((currentPage + 1) % pages);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

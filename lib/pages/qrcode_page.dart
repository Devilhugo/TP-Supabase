import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QrPage extends StatefulWidget {
  static const route = '/qrCode';
  const QrPage({super.key});

  @override
  State<QrPage> createState() => _BarcodeScannerSimpleState();
}

class _BarcodeScannerSimpleState extends State<QrPage> {
  Barcode? _barcode;

  Widget _buildBarcode(Barcode? value) {
    if (value == null) {
      return const Text(
        'Scannez quelque chose!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }
    return Text(
      value.displayValue ?? 'Aucune valeur à afficher.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      setState(() => _barcode = barcodes.barcodes.firstOrNull);
    }
  }

  bool get _estUnLien {
    final v = _barcode?.displayValue ?? '';
    return v.startsWith('http://') || v.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QRCode/Code Barre'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleBarcode),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.center,
              height: 100,
              color: Colors.black.withValues(alpha: 0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Center(child: _buildBarcode(_barcode))),
                  // Si le QR code contient une URL, bouton pour l'ouvrir
                  if (_estUnLien)
                    IconButton(
                      icon: const Icon(Icons.open_in_browser,
                          color: Colors.white),
                      onPressed: () => launchUrl(
                        Uri.parse(_barcode!.displayValue!),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

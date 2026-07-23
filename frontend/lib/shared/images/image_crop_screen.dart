import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Éditeur de recadrage in-app (carré 1:1) — garantit des images uniformes.
///
/// Renvoie via [Navigator.pop] les octets de l'image recadrée (non compressée),
/// ou `null` si l'utilisateur revient en arrière. La compression est appliquée
/// ensuite par le pipeline appelant.
class ImageCropScreen extends StatefulWidget {
  const ImageCropScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final _controller = CropController();
  bool _cropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Recadrer'),
        actions: [
          if (_cropping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Symbols.check),
              tooltip: 'Valider',
              onPressed: () {
                setState(() => _cropping = true);
                _controller.crop();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              controller: _controller,
              image: widget.imageBytes,
              aspectRatio: 1,
              baseColor: Colors.black,
              maskColor: Colors.black.withValues(alpha: 0.6),
              radius: 12,
              interactive: true,
              cornerDotBuilder: (size, edgeAlignment) =>
                  const DotControl(color: Colors.white),
              onCropped: (result) {
                switch (result) {
                  case CropSuccess(:final croppedImage):
                    Navigator.of(context).pop(croppedImage);
                  case CropFailure():
                    if (!mounted) return;
                    setState(() => _cropping = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Échec du recadrage. Réessayez.')),
                    );
                }
              },
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Pincez pour zoomer · glissez pour cadrer',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

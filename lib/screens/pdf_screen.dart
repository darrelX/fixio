import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

// Page de prévisualisation PDF
class PdfPreviewScreen extends StatelessWidget {
  final File pdfFile;

  const PdfPreviewScreen({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prévisualisation du PDF'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              // Sauvegarder le fichier PDF de manière permanente
              final savedFile = await savePDF(pdfFile);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PDF sauvegardé : ${savedFile.path}')),
              );
            },
          ),
        ],
      ),
      body: PDFView(
        filePath: pdfFile.path,
      ),
    );
  }

  // Fonction pour sauvegarder le PDF dans un répertoire permanent
  Future<File> savePDF(File pdfFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final savedFile = File('${directory.path}/fixio.pdf');
    await pdfFile.copy(savedFile.path);
    return savedFile;
  }
}

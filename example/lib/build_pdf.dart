import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

Future<Uint8List> buildPdf(PdfPageFormat format) async {
  final pdf = Document();

  pdf.addPage(
    Page(
      pageFormat: format,
      build: (context) {
        return Center(
          child: Text('Hello World!'),
        ); // Center
      },
    ),
  );

  return await pdf.save();
}

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:star_print/star_print.dart';

import 'build_pdf.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final StarPrint _starPrint = StarPrint();

  Future<List<StarPrinter>> future() async {
    final statuses = await [
      Permission.bluetoothConnect,
    ].request();
    if (statuses.values.every((element) => element.isGranted)) {
      return _starPrint.discover();
    }
    throw Exception('Permission denied');
  }

  Future printPdf(StarPrinter printer) async {
    try {
      final pdf = await buildPdf(PdfPageFormat.roll80);
      await for (final page in Printing.raster(pdf)) {
        await _starPrint.printImage(
          printer: printer,
          bytes: await page.toPng(),
          width: page.width,
          copies: 2,
        );
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: future(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: [
                for (final printer in snapshot.data!)
                  ListTile(
                    onTap: () => printPdf(printer).catchError((e) {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: const Text('Error'),
                                content: Text('$e'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ));
                    }),
                    title: Text(printer.model.toString()),
                    subtitle: Text([
                      printer.address,
                      printer.interfaceType.name,
                      printer.emulation
                    ].join('\n')),
                  ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

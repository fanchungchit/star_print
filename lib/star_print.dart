import 'star_print_platform_interface.dart';

import 'star_printer.dart';

export 'star_printer.dart';

class StarPrint {
  Future<List<StarPrinter>> discover() async {
    return (await StarPrintPlatform.instance.discover())
        .map((e) => StarPrinter.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> printImage({
    required StarPrinter printer,
    required List<int> bytes,
    int? width,
    int? copies,
  }) async {
    return StarPrintPlatform.instance.printImage(
      printer: printer,
      bytes: bytes,
      width: width,
      copies: copies,
    );
  }

  Future<void> printPath({
    required StarPrinter printer,
    required String path,
    int? width,
    int? copies,
  }) async {
    return StarPrintPlatform.instance.printPath(
      printer: printer,
      path: path,
      width: width,
      copies: copies,
    );
  }
}

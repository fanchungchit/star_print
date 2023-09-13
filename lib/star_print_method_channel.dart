import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'star_print_platform_interface.dart';
import 'star_printer.dart';

/// An implementation of [StarPrintPlatform] that uses method channels.
class MethodChannelStarPrint extends StarPrintPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('star_print');

  @override
  Future<List> discover() async {
    return await methodChannel.invokeMethod('discover');
  }

  @override
  Future<void> printImage({
    required StarPrinter printer,
    required List<int> bytes,
    int? width,
    int? copies,
  }) async {
    return await methodChannel.invokeMethod('printImage', {
      'interfaceType': printer.interfaceType.name,
      'address': printer.address,
      'bytes': bytes,
      'width': width,
      'copies': copies,
    });
  }

  @override
  Future<void> printPath({
    required StarPrinter printer,
    required String path,
    int? width,
    int? copies,
  }) async {
    return await methodChannel.invokeMethod('printPath', {
      'interfaceType': printer.interfaceType.name,
      'address': printer.address,
      'path': path,
      'width': width,
      'copies': copies,
    });
  }
}

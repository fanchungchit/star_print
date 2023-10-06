import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'star_printer.dart';
import 'star_print_method_channel.dart';

abstract class StarPrintPlatform extends PlatformInterface {
  /// Constructs a StarPrintPlatform.
  StarPrintPlatform() : super(token: _token);

  static final Object _token = Object();

  static StarPrintPlatform _instance = MethodChannelStarPrint();

  /// The default instance of [StarPrintPlatform] to use.
  ///
  /// Defaults to [MethodChannelStarPrint].
  static StarPrintPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StarPrintPlatform] when
  /// they register themselves.
  static set instance(StarPrintPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List> discover() {
    throw UnimplementedError('discover() has not been implemented.');
  }

  Future<void> printImage({
    required StarPrinter printer,
    required List<int> bytes,
    int? width,
    int? copies,
    bool withDrawer = false,
  }) {
    throw UnimplementedError('printReceipt() has not been implemented.');
  }

  Future<void> printPath({
    required StarPrinter printer,
    required String path,
    int? width,
    int? copies,
    bool withDrawer = false,
  }) {
    throw UnimplementedError('printPath() has not been implemented.');
  }
}

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}


import 'star_print_platform_interface.dart';

class StarPrint {
  Future<String?> getPlatformVersion() {
    return StarPrintPlatform.instance.getPlatformVersion();
  }
}

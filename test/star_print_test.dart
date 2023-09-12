import 'package:flutter_test/flutter_test.dart';
import 'package:star_print/star_print.dart';
import 'package:star_print/star_print_platform_interface.dart';
import 'package:star_print/star_print_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStarPrintPlatform
    with MockPlatformInterfaceMixin
    implements StarPrintPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final StarPrintPlatform initialPlatform = StarPrintPlatform.instance;

  test('$MethodChannelStarPrint is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelStarPrint>());
  });

  test('getPlatformVersion', () async {
    StarPrint starPrintPlugin = StarPrint();
    MockStarPrintPlatform fakePlatform = MockStarPrintPlatform();
    StarPrintPlatform.instance = fakePlatform;

    expect(await starPrintPlugin.getPlatformVersion(), '42');
  });
}

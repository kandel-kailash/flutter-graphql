import 'dart:io';

enum DeviceType {
  mobile,
  desktop;

  factory DeviceType._() {
    if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
      return DeviceType.mobile;
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return DeviceType.desktop;
    }

    throw UnsupportedError('Unsupported platform');
  }

  static bool get isMobile => DeviceType._() == DeviceType.mobile;
  static bool get isDesktop => DeviceType._() == DeviceType.desktop;
}

enum StarPrinterInterfaceType {
  lan,
  bluetooth,
  usb;

  factory StarPrinterInterfaceType.fromString(String value) {
    switch (value) {
      case 'Lan':
        return StarPrinterInterfaceType.lan;
      case 'Bluetooth':
        return StarPrinterInterfaceType.bluetooth;
      case 'Usb':
        return StarPrinterInterfaceType.usb;
      default:
        throw Exception('Unknown value: $value');
    }
  }
}

class StarPrinter {
  const StarPrinter({
    required this.address,
    this.model,
    this.emulation,
    required this.interfaceType,
  });

  final String address;

  final String? model;

  final String? emulation;

  final StarPrinterInterfaceType interfaceType;

  factory StarPrinter.fromMap(Map<String, dynamic> map) {
    return StarPrinter(
      address: map['address'],
      model: map['model'],
      emulation: map['emulation'],
      interfaceType: StarPrinterInterfaceType.fromString(map['interfaceType']),
    );
  }
}

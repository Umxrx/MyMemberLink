import 'dart:io';

class TestConfig {
  List<String> ipv4s = [];
  String interfaceName = '';

  Future<void> printIps() async {
    
    for (var interface in await NetworkInterface.list()) {
      interfaceName = interface.name;
      print('== Interface: $interfaceName ==');
      for (var addr in interface.addresses) {
        if (addr.type.name == 'IPv4') {
          ipv4s.add(addr.address);
          print('${addr.address} ${addr.host} ${addr.isLoopback} ${addr.rawAddress} ${addr.type.name}');
        }
      }
    }
    String selectedIP = ipv4s[(ipv4s.length) - 1];
    print('== Interface name  : $interfaceName');
    print('== Used IPv4       : $selectedIP');
  }

  Future<String> getIp() async {
    await printIps();
    String trueIP = ipv4s[(ipv4s.length) - 1];
    ipv4s.clear();
    return 'http://$trueIP';
  }
}
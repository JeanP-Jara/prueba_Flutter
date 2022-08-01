import 'dart:io';

Future<bool> internetConnectivity() async {
  bool val = false;
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      val = true;
    }
  } on SocketException catch (_) {
    val = false;
  }
  return val;
}
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
class PasswordCrypto {
  Future<String> generateMd5(String data) async {
    return crypto.md5.convert(utf8.encode(data)).toString();
  }
}
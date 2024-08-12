import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _encryptionKey = 'encryptionKey'; // TODO: Change this key
const String _userNameBoxKey = 'settings';
const secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    keyCipherAlgorithm:
        KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
  ),
  iOptions: IOSOptions(),
  lOptions: LinuxOptions(),
  mOptions: MacOsOptions(),
  wOptions: WindowsOptions(),
  webOptions: WebOptions(),
);

class Database {
  static final Database _instance = Database._internal();
  Database._internal();
  factory Database() => _instance;
  Box<dynamic> get _settingsBox => Hive.box(_userNameBoxKey);

  void registerAdapter<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  bool hasName() => _settingsBox.containsKey('name');

  String? getName() => _settingsBox.get('name');

  Future<void> setName(String name) async {
    await _settingsBox.put('name', name);
  }

  Future<void> init() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    var hasKey = await secureStorage.containsKey(key: _encryptionKey);
    if (!hasKey) {
      var key = Hive.generateSecureKey();
      await secureStorage.write(
        key: _encryptionKey,
        value: base64UrlEncode(key),
      );
    }
    final key =
        base64Url.decode((await secureStorage.read(key: _encryptionKey))!);
    final cipher = HiveAesCipher(key);
    await Future.wait([
      Hive.openBox(_userNameBoxKey, encryptionCipher: cipher),
    ]);
  }

  Future<void> clear() async {
    await Future.wait([
      Hive.box(_userNameBoxKey).clear(),
    ]);
  }
}

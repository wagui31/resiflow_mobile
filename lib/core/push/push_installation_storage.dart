import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final pushInstallationStorageProvider = Provider<PushInstallationStorage>((ref) {
  return const PushInstallationStorage();
});

class PushInstallationStorage {
  const PushInstallationStorage();

  static const String _installationIdKey = 'push.installationId';

  Future<String> readOrCreateInstallationId() async {
    final preferences = await SharedPreferences.getInstance();
    final persisted = preferences.getString(_installationIdKey)?.trim();
    if (persisted != null && persisted.isNotEmpty) {
      return persisted;
    }

    final installationId = _generateInstallationId();
    await preferences.setString(_installationIdKey, installationId);
    return installationId;
  }

  String _generateInstallationId() {
    final random = Random.secure();
    final buffer = StringBuffer('inst_');
    for (var index = 0; index < 24; index++) {
      buffer.write(random.nextInt(16).toRadixString(16));
    }
    return buffer.toString();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_storage.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => AuthStorage.isLoggedIn();

  Future<void> loginBypass() async {
    await AuthStorage.setLoggedIn(true);
    state = const AsyncData(true);
  }

  Future<void> logout() async {
    await AuthStorage.setLoggedIn(false);
    state = const AsyncData(false);
  }
}

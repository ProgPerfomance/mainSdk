abstract interface class SelektSessionStore {
  String? get userId;
  String? get authToken;

  Future<void> saveSession({
    required String userId,
    required String token,
  });

  Future<void> clearSession();
}

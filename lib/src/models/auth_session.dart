import 'selekt_user.dart';

class AuthSession {
  const AuthSession({required this.userId, required this.token, this.user});

  final String userId;
  final String token;
  final SelektUser? user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final user = rawUser is Map
        ? SelektUser.fromJson(Map<String, dynamic>.from(rawUser))
        : _tryParseUser(json);
    final userId =
        (json['_id'] ?? json['userId'] ?? user?.id)?.toString() ?? '';
    final token = json['token']?.toString() ?? '';

    if (userId.isEmpty || token.isEmpty) {
      throw const FormatException('Invalid auth session response');
    }

    return AuthSession(userId: userId, token: token, user: user);
  }

  static SelektUser? _tryParseUser(Map<String, dynamic> json) {
    if (json['_id'] == null || json['email'] == null) {
      return null;
    }
    return SelektUser.fromJson(json);
  }
}

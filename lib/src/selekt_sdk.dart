import 'package:dio/dio.dart';

import 'models/auth_session.dart';
import 'models/app_version_settings.dart';
import 'models/selekt_api_exception.dart';
import 'models/selekt_user.dart';
import 'models/wish.dart';
import 'models/wish_request.dart';
import 'selekt_sdk_config.dart';
import 'selekt_session_store.dart';

class SelektSdk {
  SelektSdk({
    required SelektSdkConfig config,
    SelektSessionStore? sessionStore,
    Dio? dio,
  }) : _config = config,
       _sessionStore = sessionStore,
       _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
      headers: {
        'Content-Type': 'application/json',
        'X-App-Id': config.normalizedAppId,
        if (config.languageCode != null) 'Accept-Language': config.languageCode,
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-App-Id'] = _config.normalizedAppId;
          final token = _sessionStore?.authToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    if (config.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  final SelektSdkConfig _config;
  final SelektSessionStore? _sessionStore;
  final Dio _dio;

  String get appId => _config.normalizedAppId;

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? appliedReferralCode,
    String? avatarUrl,
  }) async {
    final session = await _postAuthSession('/api/v1/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'appliedReferralCode': appliedReferralCode,
      'avatarUrl': avatarUrl,
    });
    await _sessionStore?.saveSession(
      userId: session.userId,
      token: session.token,
    );
    return session;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _postAuthSession('/api/v1/auth/login', {
      'email': email,
      'password': password,
    });
    await _sessionStore?.saveSession(
      userId: session.userId,
      token: session.token,
    );
    return session;
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _post('/api/v1/auth/password-reset/request', {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    await _post('/api/v1/auth/password-reset/confirm', {
      'email': email,
      'code': code,
      'password': password,
    });
  }

  Future<SelektUser> getProfile(String userId) async {
    final data = await _post('/api/v1/auth/profile', {'userId': userId});
    return SelektUser.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<SelektUser?> getCurrentProfile() async {
    final userId = _sessionStore?.userId;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return getProfile(userId);
  }

  Future<SelektUser> applyReferralCode({
    required String userId,
    required String referralCode,
  }) async {
    final data = await _post('/api/v1/auth/referral/apply', {
      'userId': userId,
      'appliedReferralCode': referralCode,
    });
    return SelektUser.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> deleteAccount({required String userId}) async {
    await _post('/api/v1/auth/delete', {'userId': userId});
    await _sessionStore?.clearSession();
  }

  Future<AppVersionSettings> getAppVersionSettings() async {
    final data = await _get('/api/v1/app/version');
    return AppVersionSettings.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<Wish>> listWishes() async {
    final data = await _get('/api/v1/wishes');
    return List<Map<String, dynamic>>.from(
      (data as List).map((item) => Map<String, dynamic>.from(item as Map)),
    ).map(Wish.fromJson).toList();
  }

  Future<Wish> reactToWish({
    required String wishId,
    required WishReactionType reaction,
    WishReactionType? previousReaction,
  }) async {
    final data = await _post('/api/v1/wishes/$wishId/reaction', {
      'reaction': reaction.apiValue,
      if (previousReaction != null)
        'previousReaction': previousReaction.apiValue,
    });
    return Wish.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<WishRequest> createWishRequest({
    required String text,
    String? userId,
  }) async {
    final data = await _post('/api/v1/wishes/requests', {
      'text': text,
      if (userId != null && userId.trim().isNotEmpty) 'userId': userId,
    });
    return WishRequest.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<AuthSession> _postAuthSession(
    String path,
    Map<String, dynamic> data,
  ) async {
    final responseData = await _post(path, data);
    return AuthSession.fromJson(Map<String, dynamic>.from(responseData as Map));
  }

  Future<dynamic> _post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        path,
        data: {
          ...data,
          'appId': _config.normalizedAppId,
          'app_id': _config.normalizedAppId,
        },
      );
      return response.data['data'];
    } on DioException catch (error) {
      throw SelektApiException.fromResponse(
        responseData: error.response?.data,
        fallbackMessage: error.message,
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<dynamic> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: {
          if (queryParameters != null) ...queryParameters,
          'appId': _config.normalizedAppId,
        },
      );
      return response.data['data'];
    } on DioException catch (error) {
      throw SelektApiException.fromResponse(
        responseData: error.response?.data,
        fallbackMessage: error.message,
        statusCode: error.response?.statusCode,
      );
    }
  }
}

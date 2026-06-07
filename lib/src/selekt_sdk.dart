import 'package:dio/dio.dart';

import 'models/auth_session.dart';
import 'models/app_version_settings.dart';
import 'models/ai_billing.dart';
import 'models/billing_history.dart';
import 'models/custom_content.dart';
import 'models/related_apps.dart';
import 'models/referral_summary.dart';
import 'models/request_package.dart';
import 'models/selekt_api_exception.dart';
import 'models/selekt_user.dart';
import 'models/subscription_settings.dart';
import 'models/tbank_payment.dart';
import 'models/transaction.dart';
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

  Future<ReferralSummary> getReferrals({required String userId}) async {
    final data = await _post('/api/v1/auth/referrals', {'userId': userId});
    return ReferralSummary.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> deleteAccount({required String userId}) async {
    await _post('/api/v1/auth/delete', {'userId': userId});
    await _sessionStore?.clearSession();
  }

  Future<({SelektTransaction transaction, double newBalance})> deposit({
    required String userId,
    required double amount,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    final data = await _post('/api/v1/billing/deposit', {
      'userId': userId,
      'amount': amount,
      'description': ?description,
      if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
    });
    final json = Map<String, dynamic>.from(data as Map);
    return (
      transaction: SelektTransaction.fromJson(
        Map<String, dynamic>.from(json['transaction'] as Map),
      ),
      newBalance: (json['newBalance'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<AiRequestPreparation> prepareAiRequest({
    required String userId,
  }) async {
    final data = await _post('/api/v1/billing/ai/prepare', {'userId': userId});
    return AiRequestPreparation.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<AiRequestCharge> chargeAiRequest({
    required String userId,
    required double requestPrice,
    required DateTime sessionStartedAt,
    required int sessionRequestIndex,
  }) async {
    final data = await _post('/api/v1/billing/ai/charge', {
      'userId': userId,
      'requestPrice': requestPrice,
      'sessionStartedAt': sessionStartedAt.toUtc().toIso8601String(),
      'sessionRequestIndex': sessionRequestIndex,
    });
    return AiRequestCharge.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<BillingHistory> getBillingHistory({
    required String userId,
    int? limit,
  }) async {
    final data = await _post('/api/v1/billing/history', {
      'userId': userId,
      'limit': ?limit?.clamp(1, 200),
    });
    return BillingHistory.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<RequestPackage>> listRequestPackages({String? scope}) async {
    final data = await _get(
      '/api/v1/billing/request-packages',
      queryParameters: {'scope': ?scope},
    );
    return List<Map<String, dynamic>>.from(
      (data as List).map((item) => Map<String, dynamic>.from(item as Map)),
    ).map(RequestPackage.fromJson).toList();
  }

  Future<SubscriptionSettings> getSubscriptionSettings({String? scope}) async {
    final data = await _get(
      '/api/v1/billing/subscription',
      queryParameters: {'scope': ?scope},
    );
    return SubscriptionSettings.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<TBankPaymentInit> initTBankSubscription({
    required String userId,
    String? description,
    String? language,
    String? deviceOs,
    String? deviceBrowser,
    bool autoRenew = false,
    String? scope,
  }) async {
    final data = await _post('/api/v1/billing/subscription/tbank/init', {
      'userId': userId,
      'description': ?description,
      'language': ?language,
      'deviceOs': ?deviceOs,
      'deviceBrowser': ?deviceBrowser,
      'autoRenew': autoRenew,
      'scope': ?scope,
    });
    return TBankPaymentInit.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<TBankPaymentConfirm> confirmTBankSubscription({
    required String userId,
    String? paymentId,
    String? orderId,
  }) async {
    final data = await _post('/api/v1/billing/subscription/tbank/confirm', {
      'userId': userId,
      'paymentId': ?paymentId,
      'orderId': ?orderId,
    });
    return TBankPaymentConfirm.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<TBankPaymentConfirm> buySubscriptionWithBalance({
    required String userId,
    String? scope,
  }) async {
    final data = await _post('/api/v1/billing/subscription/buy-balance', {
      'userId': userId,
      'scope': ?scope,
    });
    return TBankPaymentConfirm.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<SelektUser> cancelSubscriptionAutoRenew({
    required String userId,
    String? scope,
  }) async {
    final data = await _post('/api/v1/billing/subscription/auto-renew/cancel', {
      'userId': userId,
      'scope': ?scope,
    });
    return SelektUser.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<RequestPackagePurchase> buyRequestPackageWithBalance({
    required String userId,
    required String packageId,
  }) async {
    final data = await _post('/api/v1/billing/request-packages/buy-balance', {
      'userId': userId,
      'packageId': packageId,
    });
    return RequestPackagePurchase.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<TBankPaymentInit> initTBankTopUp({
    required String userId,
    required double amount,
    String? description,
    String? language,
    String? deviceOs,
    String? deviceBrowser,
  }) async {
    final data = await _post('/api/v1/billing/tbank/init', {
      'userId': userId,
      'amount': amount,
      'description': ?description,
      'language': ?language,
      'deviceOs': ?deviceOs,
      'deviceBrowser': ?deviceBrowser,
    });
    return TBankPaymentInit.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<TBankPaymentInit> initTBankRequestPackage({
    required String userId,
    required String packageId,
    String? description,
    String? language,
    String? deviceOs,
    String? deviceBrowser,
  }) async {
    final data = await _post('/api/v1/billing/request-packages/tbank/init', {
      'userId': userId,
      'packageId': packageId,
      'description': ?description,
      'language': ?language,
      'deviceOs': ?deviceOs,
      'deviceBrowser': ?deviceBrowser,
    });
    return TBankPaymentInit.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<TBankPaymentConfirm> confirmTBankRequestPackage({
    required String userId,
    String? paymentId,
    String? orderId,
  }) async {
    final data = await _post('/api/v1/billing/request-packages/tbank/confirm', {
      'userId': userId,
      'paymentId': ?paymentId,
      'orderId': ?orderId,
    });
    return TBankPaymentConfirm.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<TBankPaymentConfirm> confirmTBankTopUp({
    required String userId,
    String? paymentId,
    String? orderId,
  }) async {
    final data = await _post('/api/v1/billing/tbank/confirm', {
      'userId': userId,
      'paymentId': ?paymentId,
      'orderId': ?orderId,
    });
    return TBankPaymentConfirm.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<({SelektTransaction transaction, double newBalance})> applyPromoCode({
    required String userId,
    required String promoCode,
  }) async {
    final data = await _post('/api/v1/billing/promo/apply', {
      'userId': userId,
      'promoCode': promoCode,
    });
    final json = Map<String, dynamic>.from(data as Map);
    return (
      transaction: SelektTransaction.fromJson(
        Map<String, dynamic>.from(json['transaction'] as Map),
      ),
      newBalance: (json['newBalance'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<AppVersionSettings> getAppVersionSettings() async {
    final data = await _get('/api/v1/app/version');
    return AppVersionSettings.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<RelatedAppsFeed> getRelatedApps() async {
    final data = await _get('/api/v1/app/other-apps');
    return RelatedAppsFeed.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<CustomContentCollection>> listContentCollections() async {
    final data = await _get('/api/v1/content/collections');
    return List<Map<String, dynamic>>.from(
      (data as List).map((item) => Map<String, dynamic>.from(item as Map)),
    ).map(CustomContentCollection.fromJson).toList();
  }

  Future<List<CustomContentItem>> listContentItems({
    required String collectionKey,
    String? q,
    List<String> tags = const [],
    int? limit,
    int? skip,
  }) async {
    final data = await _get(
      '/api/v1/content/${Uri.encodeComponent(collectionKey)}',
      queryParameters: {
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        if (tags.isNotEmpty) 'tags': tags.join(','),
        if (limit != null) 'limit': limit.clamp(1, 500),
        if (skip != null) 'skip': skip < 0 ? 0 : skip,
      },
    );
    return List<Map<String, dynamic>>.from(
      (data as List).map((item) => Map<String, dynamic>.from(item as Map)),
    ).map(CustomContentItem.fromJson).toList();
  }

  Future<CustomContentItem> getContentItem({
    required String collectionKey,
    required String itemId,
  }) async {
    final data = await _get(
      '/api/v1/content/${Uri.encodeComponent(collectionKey)}/${Uri.encodeComponent(itemId)}',
    );
    return CustomContentItem.fromJson(Map<String, dynamic>.from(data as Map));
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

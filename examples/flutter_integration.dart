import 'package:main_sdk/selekt_sdk.dart';

/// Copy this file into a Flutter app and adjust appId/path/imports.
///
/// Required:
/// - Add `main_sdk` to pubspec.yaml.
/// - Create the same appId in the admin app registry.
/// - Configure T-Bank in admin if this app accepts card payments.
///
/// In a real app, replace [InMemorySelektSessionStore] with a persistent
/// implementation backed by SharedPreferences, secure storage, Hive, or the
/// app's existing session storage.
const mainApiBaseUrl = 'http://80.93.61.208:5195';
const exampleAppId = 'your_app_id';

class InMemorySelektSessionStore implements SelektSessionStore {
  String? _userId;
  String? _authToken;

  @override
  String? get userId => _userId;

  @override
  String? get authToken => _authToken;

  @override
  Future<void> saveSession({
    required String userId,
    required String token,
  }) async {
    _userId = userId;
    _authToken = token;
  }

  @override
  Future<void> clearSession() async {
    _userId = null;
    _authToken = null;
  }
}

SelektSdk createSelektSdk({
  String appId = exampleAppId,
  String languageCode = 'ru',
  SelektSessionStore? sessionStore,
}) {
  return SelektSdk(
    config: SelektSdkConfig(
      appId: appId,
      baseUrl: mainApiBaseUrl,
      languageCode: languageCode,
    ),
    sessionStore: sessionStore ?? InMemorySelektSessionStore(),
  );
}

Future<AuthSession> loginExample(
  SelektSdk sdk, {
  required String email,
  required String password,
}) async {
  final session = await sdk.login(email: email, password: password);
  await sdk.getProfile(session.userId);

  // Load/map the profile into the app's local User/Profile model here.
  // The SDK has already persisted userId/token through the session store.
  return session;
}

Future<SelektUser?> restoreProfileExample(SelektSdk sdk) async {
  final profile = await sdk.getCurrentProfile();
  if (profile == null) {
    // Show auth screen.
    return null;
  }

  // Show the main app.
  return profile;
}

Future<AppVersionSettings> appVersionExample(
  SelektSdk sdk, {
  required String currentVersionLabel,
}) async {
  final settings = await sdk.getAppVersionSettings();
  if (settings.requiredVersion.trim() != currentVersionLabel.trim()) {
    // Show update screen or block old app version.
  }
  return settings;
}

Future<List<Wish>> wishesExample(
  SelektSdk sdk, {
  required String userId,
}) async {
  final wishes = await sdk.listWishes();
  if (wishes.isNotEmpty) {
    await sdk.reactToWish(
      wishId: wishes.first.id,
      reaction: WishReactionType.like,
      previousReaction: wishes.first.userReaction,
    );
  }

  await sdk.createWishRequest(
    userId: userId,
    text: 'Add the feature users keep asking for',
  );

  return wishes;
}

Future<BillingHistory> balanceAndPackagesExample(
  SelektSdk sdk, {
  required String userId,
}) async {
  final history = await sdk.getBillingHistory(userId: userId, limit: 50);

  final packages = await sdk.listRequestPackages(scope: 'app');
  if (packages.isEmpty) {
    return history;
  }

  await sdk.buyRequestPackageWithBalance(
    userId: userId,
    packageId: packages.first.id,
  );
  return sdk.getBillingHistory(userId: userId, limit: 50);
}

Future<TBankPaymentInit> tBankTopUpExample(
  SelektSdk sdk, {
  required String userId,
}) {
  return sdk.initTBankTopUp(
    userId: userId,
    amount: 500,
    language: 'ru',
    description: 'Balance top-up',
  );
}

Future<TBankPaymentConfirm> confirmTopUpExample(
  SelektSdk sdk, {
  required String userId,
  required TBankPaymentInit payment,
}) async {
  final result = await sdk.confirmTBankTopUp(
    userId: userId,
    paymentId: payment.paymentId,
    orderId: payment.orderId,
  );

  if (result.confirmed && result.applied) {
    // Refresh the user balance/history in app UI.
  }
  return result;
}

Future<void> aiBillingExample(
  SelektSdk sdk, {
  required String userId,
  required Future<void> Function() runAiOperation,
}) async {
  final preparation = await sdk.prepareAiRequest(userId: userId);

  await runAiOperation();

  await sdk.chargeAiRequest(
    userId: userId,
    requestPrice: preparation.requestPrice,
    sessionStartedAt: preparation.sessionStartedAt,
    sessionRequestIndex: preparation.sessionRequestIndex,
  );
}

Future<TBankPaymentInit?> subscriptionExample(
  SelektSdk sdk, {
  required String userId,
}) async {
  final settings = await sdk.getSubscriptionSettings(scope: 'app');
  if (settings.price <= 0) {
    return null;
  }

  final payment = await sdk.initTBankSubscription(
    userId: userId,
    language: 'ru',
    autoRenew: false,
    description: '${settings.name} subscription',
  );

  // Open `payment.paymentUrl` in a WebView/browser, then confirm by IDs.
  return payment;
}

Future<String?> handleSdkErrorExample(SelektSdk sdk) async {
  try {
    await sdk.getCurrentProfile();
  } on SelektApiException catch (error) {
    if (error.errorCode == 'INSUFFICIENT_BALANCE') {
      // Show billing screen.
      return error.errorCode;
    }

    // Show error.message in app UI.
    return error.message;
  }
  return null;
}

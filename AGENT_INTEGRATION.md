# Agent Integration Guide

Use this guide when adding `main_sdk` to a new Flutter application.

The SDK is the shared client for `mainApi`. It should replace app-local code for
auth, profile, app version, wishes, shared billing, T-Bank, request packages,
promo codes, subscriptions, AI billing, and related-app blocks. Keep
app-specific APIs only for app-specific content such as characters, doctors,
chats, food analysis, or other domain data.

## Required Order

1. Pick a stable `appId`.
2. Create the same `appId` in the admin app before release.
3. Add `main_sdk` to `pubspec.yaml`.
4. Implement `SelektSessionStore`.
5. Create one `SelektSdk` instance and inject/reuse it.
6. Replace old auth/profile/version/wishes/billing calls with SDK calls.
7. Keep app-specific backend calls separate.
8. Run `flutter analyze`.
9. Run focused tests for auth and billing flows.
10. Launch the app on simulator/device and check login/profile at minimum.

## Current Production Values

```text
mainApi: http://80.93.61.208:5195
admin:   http://80.93.61.208:5196
```

Known app IDs:

```text
psychology
med_app
gdz
callories
```

## Admin Requirement

Every SDK app must exist in the admin app registry with the same `appId`.

Minimum app registry fields:

```json
{
  "appId": "your_app_id",
  "name": "Human App Name",
  "platform": "mobile",
  "settings": {
    "usesMainSdk": true,
    "hasSubscriptions": false
  }
}
```

If the app accepts T-Bank payments, configure T-Bank settings in the admin UI.
Raw keys must live in encrypted Mongo settings, not in the mobile app.

## Dependency

Local workspace example:

```yaml
dependencies:
  main_sdk:
    path: ../new/mainSdk
```

Adjust the path based on the app location.

## Session Store

The SDK needs a `SelektSessionStore` so it can attach the JWT token and save
sessions after login/register.

```dart
class AppSessionStore implements SelektSessionStore {
  AppSessionStore(this.prefs);

  final SharedPreferences prefs;

  @override
  String? get userId => prefs.getString('auth.user_id');

  @override
  String? get authToken => prefs.getString('auth.token');

  @override
  Future<void> saveSession({
    required String userId,
    required String token,
  }) async {
    await prefs.setString('auth.user_id', userId);
    await prefs.setString('auth.token', token);
  }

  @override
  Future<void> clearSession() async {
    await prefs.remove('auth.user_id');
    await prefs.remove('auth.token');
  }
}
```

## SDK Construction

```dart
final sdk = SelektSdk(
  config: const SelektSdkConfig(
    appId: 'your_app_id',
    baseUrl: 'http://80.93.61.208:5195',
    languageCode: 'ru',
  ),
  sessionStore: AppSessionStore(prefs),
);
```

Create this once and reuse it through your app's DI/provider/controller layer.

## Replace These Old API Areas

Replace local or app-specific calls for:

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/profile`
- `POST /api/v1/auth/delete`
- `POST /api/v1/auth/referral/apply`
- `POST /api/v1/auth/referrals`
- `POST /api/v1/auth/password-reset/request`
- `POST /api/v1/auth/password-reset/confirm`
- `GET /api/v1/app/version`
- `GET /api/v1/content/collections`
- `GET /api/v1/content/<collectionKey>`
- `GET /api/v1/content/<collectionKey>/<itemId>`
- `GET /api/v1/wishes`
- `POST /api/v1/wishes/<id>/reaction`
- `POST /api/v1/wishes/requests`
- `POST /api/v1/billing/*`
- `GET /api/v1/billing/*`

Keep old/app-specific APIs only when they are not shared platform features.

## Common Flows

Auth:

```dart
final session = await sdk.login(email: email, password: password);
final profile = await sdk.getProfile(session.userId);
```

Profile restore:

```dart
final profile = await sdk.getCurrentProfile();
```

Version:

```dart
final version = await sdk.getAppVersionSettings();
if (version.requiredVersion != currentVersionLabel) {
  // Show update screen.
}
```

Related apps:

```dart
final relatedApps = await sdk.getRelatedApps();
for (final block in relatedApps.blocks) {
  if (block.isBanner) {
    // Render a wide adaptive banner using this app's own design system.
  }
  if (block.isGrid) {
    // Render a responsive app icon grid. Backend recommendation: 3 columns.
  }
}
```

Do not hardcode colors/layout inside SDK integration code. The SDK returns
data and `block.type`; the app owns the visual implementation.
When opening an app from the block, prefer `app.ruStoreUrl`; use `apiBaseUrl`
only as a temporary fallback.

Custom content:

```dart
final collections = await sdk.listContentCollections();
final doctors = await sdk.listContentItems(collectionKey: 'doctors');
final doctor = await sdk.getContentItem(
  collectionKey: 'doctors',
  itemId: 'doctor_anna',
);
```

Use this for app-specific entities of any shape: doctors, psychologists,
categories, lessons, cards, plans, etc. The SDK provides `CustomContentItem`
with common display fields and arbitrary `data`. Keep typed app models in the
app:

```dart
class Doctor {
  Doctor.fromContent(CustomContentItem item)
      : id = item.itemId,
        name = item.title,
        price = (item.data['price'] as num?)?.toInt() ?? 0;

  final String id;
  final String name;
  final int price;
}
```

Do not add a new SDK model for every app-specific entity. Add a custom content
collection in the admin, document its `data` shape in collection `schema`, then
map it inside the app.

Wishes:

```dart
final wishes = await sdk.listWishes();
await sdk.createWishRequest(userId: userId, text: text);
await sdk.reactToWish(wishId: wishId, reaction: WishReactionType.like);
```

Balance and history:

```dart
final history = await sdk.getBillingHistory(userId: userId);
final promo = await sdk.applyPromoCode(userId: userId, promoCode: code);
```

Request packages:

```dart
final packages = await sdk.listRequestPackages(scope: 'app');
final purchase = await sdk.buyRequestPackageWithBalance(
  userId: userId,
  packageId: packageId,
);
```

T-Bank top-up:

```dart
final payment = await sdk.initTBankTopUp(
  userId: userId,
  amount: 500,
  language: 'ru',
);

final result = await sdk.confirmTBankTopUp(
  userId: userId,
  paymentId: payment.paymentId,
  orderId: payment.orderId,
);
```

AI billing:

```dart
final preparation = await sdk.prepareAiRequest(userId: userId);

// Run the app-specific AI operation here.

final charge = await sdk.chargeAiRequest(
  userId: userId,
  requestPrice: preparation.requestPrice,
  sessionStartedAt: preparation.sessionStartedAt,
  sessionRequestIndex: preparation.sessionRequestIndex,
);
```

Subscriptions, only for apps that use subscriptions:

```dart
final settings = await sdk.getSubscriptionSettings(scope: 'app');
final payment = await sdk.initTBankSubscription(
  userId: userId,
  language: 'ru',
  autoRenew: false,
);
```

Apps without subscriptions should not call subscription methods. In the admin
registry, set:

```json
{ "hasSubscriptions": false }
```

## Error Handling

Every SDK request can throw `SelektApiException`.

```dart
try {
  await sdk.login(email: email, password: password);
} on SelektApiException catch (error) {
  final message = error.message;
  final code = error.errorCode;
  final details = error.details;
}
```

Use `errorCode == 'INSUFFICIENT_BALANCE'` for payment/balance UI.

## Verification Checklist

Before saying the migration is done:

- `appId` exists in admin app registry.
- T-Bank settings are configured if the app accepts card payments.
- `flutter analyze` passes.
- Login/register/profile restore work.
- App version request returns app-specific settings.
- Related-app blocks load and render without hardcoded foreign styling.
- Wishes list/request/reaction work, if the app has wishes UI.
- Balance history loads.
- Packages load for the app.
- Promo code path calls `mainApi`.
- AI charge path calls `mainApi`, if the app charges per AI request.
- Subscription UI is removed/disabled for apps without subscriptions.

## Do Not

- Do not store T-Bank keys in mobile source code.
- Do not create a new backend for shared auth/billing/profile behavior.
- Do not reuse another app's `appId`.
- Do not silently leave shared billing on an old app-specific backend.
- Do not call subscription methods in apps where subscriptions are disabled.

# main_sdk

Shared SDK for Selekt/Niami applications.

`main_sdk` is the common client layer for the shared `mainApi`. Each app keeps
its own `appId`, but uses the same API for users, auth, profile, app version,
wishes, billing catalog entities, and admin operations.

Current production `mainApi`:

```text
http://80.93.61.208:5195
```

For agent-to-agent handoff and new app migrations, start with
[`AGENT_INTEGRATION.md`](AGENT_INTEGRATION.md). A copyable Flutter example is in
[`examples/flutter_integration.dart`](examples/flutter_integration.dart).

## What The SDK Owns

Flutter/client SDK:

- app configuration through `appId`;
- `X-App-Id` header on every request;
- auth token forwarding through `Authorization: Bearer ...`;
- registration;
- login;
- password reset request and confirmation;
- profile loading;
- referral code application;
- account deletion;
- app version settings;
- published wishes;
- wish reactions;
- user wish requests.
- balance and transaction history;
- promo code application;
- request package listing and purchase;
- T-Bank top-up and package payment flows;
- subscription settings and subscription payment flows;
- AI request prepare/charge billing.

Known production app IDs:

```text
psychology
med_app
gdz
callories
```

Every app that uses the SDK must also exist in the admin app registry with the
same `appId`. The SDK sends `appId` in `X-App-Id`, request body, and query
parameters where needed; the admin registry is what makes that `appId`
configurable in the admin UI.

TypeScript/admin SDK:

- app registry list/create/update;
- encrypted T-Bank settings per app;
- users list;
- user profile with transactions;
- user edit/delete;
- user subscription grant/update;
- subscription plans CRUD;
- request packages CRUD;
- promo codes CRUD;
- app version read/update;
- wishes CRUD;
- wish requests list/delete/clear;
- analytics aggregation for the admin UI.

## Flutter Integration

Add the SDK as a dependency.

For local development inside the current workspace:

```yaml
dependencies:
  main_sdk:
    path: ../../mainSdk
```

Then create a `SelektSdk` instance. Every application must have a stable
`appId`; for the psychology app it is currently `psychology`.

```dart
import 'package:main_sdk/selekt_sdk.dart';

final sdk = SelektSdk(
  config: const SelektSdkConfig(
    appId: 'psychology',
    baseUrl: 'http://80.93.61.208:5195',
  ),
  sessionStore: mySessionStore,
);
```

`sessionStore` is the app-side adapter that stores `userId` and JWT token.

```dart
abstract interface class SelektSessionStore {
  String? get userId;
  String? get authToken;

  Future<void> saveSession({
    required String userId,
    required String token,
  });

  Future<void> clearSession();
}
```

### Auth

```dart
final session = await sdk.login(
  email: email,
  password: password,
);

final user = await sdk.getProfile(session.userId);
```

Registration:

```dart
final session = await sdk.register(
  name: name,
  email: email,
  password: password,
  phoneNumber: phoneNumber,
  appliedReferralCode: referralCode,
);
```

Password reset:

```dart
await sdk.requestPasswordReset(email: email);

await sdk.resetPassword(
  email: email,
  code: code,
  password: newPassword,
);
```

Referral:

```dart
final updatedUser = await sdk.applyReferralCode(
  userId: userId,
  referralCode: referralCode,
);
```

Delete account:

```dart
await sdk.deleteAccount(userId: userId);
```

### Billing

Balance and transaction history:

```dart
final history = await sdk.getBillingHistory(
  userId: userId,
  limit: 100,
);

final promo = await sdk.applyPromoCode(
  userId: userId,
  promoCode: 'START500',
);
```

Request packages:

```dart
final packages = await sdk.listRequestPackages(scope: 'app');

final purchase = await sdk.buyRequestPackageWithBalance(
  userId: userId,
  packageId: packages.first.id,
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

Request package by T-Bank:

```dart
final payment = await sdk.initTBankRequestPackage(
  userId: userId,
  packageId: packageId,
  language: 'ru',
);

final result = await sdk.confirmTBankRequestPackage(
  userId: userId,
  paymentId: payment.paymentId,
  orderId: payment.orderId,
);
```

AI billing:

```dart
final preparation = await sdk.prepareAiRequest(userId: userId);

// Run app-specific AI work here.

final charge = await sdk.chargeAiRequest(
  userId: userId,
  requestPrice: preparation.requestPrice,
  sessionStartedAt: preparation.sessionStartedAt,
  sessionRequestIndex: preparation.sessionRequestIndex,
);
```

Subscriptions, only for apps with subscriptions enabled:

```dart
final settings = await sdk.getSubscriptionSettings(scope: 'app');

final payment = await sdk.initTBankSubscription(
  userId: userId,
  language: 'ru',
  autoRenew: false,
);

final result = await sdk.confirmTBankSubscription(
  userId: userId,
  paymentId: payment.paymentId,
  orderId: payment.orderId,
);
```

Apps without subscriptions, for example `gdz` and `callories`, should not call
subscription methods. Set `settings.hasSubscriptions=false` in the app registry.

### Profile

```dart
final user = await sdk.getProfile(userId);
final currentUser = await sdk.getCurrentProfile();
```

`getCurrentProfile()` uses `sessionStore.userId`. If there is no saved session,
it returns `null`.

### App Version

The app version check is shared and app-specific through `appId`.

```dart
final settings = await sdk.getAppVersionSettings();

if (settings.requiredVersion != currentVersionLabel) {
  // Show update/blocked screen.
}
```

The backend receives the app id from `X-App-Id` and query parameters generated
by the SDK.

### Wishes

List published wishes:

```dart
final wishes = await sdk.listWishes();
```

React to a wish:

```dart
final updatedWish = await sdk.reactToWish(
  wishId: wish.id,
  reaction: WishReactionType.like,
  previousReaction: previousReaction,
);
```

Create a user wish request:

```dart
await sdk.createWishRequest(
  text: 'Add a new feature',
  userId: userId,
);
```

The SDK sends the JWT automatically when `sessionStore.authToken` is available.

### Error Handling

SDK calls throw `SelektApiException`.

```dart
try {
  await sdk.login(email: email, password: password);
} on SelektApiException catch (error) {
  print(error.message);
  print(error.statusCode);
}
```

Payment screens should check `error.errorCode == 'INSUFFICIENT_BALANCE'`.

## TypeScript Admin Integration

Install/use the package from the local workspace:

```json
{
  "dependencies": {
    "main_sdk": "file:../mainSdk"
  }
}
```

Create an SDK instance:

```ts
import { MainAdminSdk } from "main_sdk";

const sdk = new MainAdminSdk({
  baseUrl: process.env.MAIN_API_URL ?? "http://80.93.61.208:5195",
  adminToken: process.env.ADMIN_API_TOKEN,
});
```

### Apps

```ts
const apps = await sdk.listApps();

const app = await sdk.createApp({
  appId: "psychology",
  name: "Psychology",
  platform: "mobile",
  apiBaseUrl: "http://80.93.61.208:5183",
});

await sdk.updateApp("psychology", {
  name: "Psychology",
  platform: "mobile",
  isActive: true,
});
```

Each app may also have encrypted T-Bank settings. `listApps()` and
`updateApp()` never return raw secrets; they only return status flags in
`app.tBankSettings`.

```ts
await sdk.updateAppTBankSettings("psychology", {
  enabled: true,
  terminalKey: process.env.TBANK_TERMINAL_KEY,
  password: process.env.TBANK_PASSWORD,
});

const revealed = await sdk.revealAppTBankSettings(
  "psychology",
  adminPassword,
);
```

`revealAppTBankSettings()` requires the admin password. Use it only for admin
UI reveal flows. Do not persist the returned raw values on the frontend.

### Users

```ts
const users = await sdk.listUsers("email@example.com");
const profile = await sdk.getUserProfile(userId);

await sdk.updateUser(userId, {
  name: "User Name",
  email: "email@example.com",
  phoneNumber: "+79990000000",
});

await sdk.deleteUser(userId);
```

`getUserProfile()` returns user data plus `transactions`.

Manual subscription grant/update:

```ts
await sdk.grantUserSubscription(userId, {
  adminName: "admin",
  subscriptionId: planId,
  days: 30,
  reason: "Manual correction",
});

await sdk.clearUserSubscription(userId, {
  scope: "app",
  appId: "psychology",
});
```

User entities include `balance`, optional `avatarUrl`, transactions, and
subscription metadata.

### Subscription Plans

Subscriptions are global catalog entities. A user stores assigned
subscriptions with expiration metadata; the plan itself is not owned by one
user.

```ts
const plans = await sdk.listSubscriptionPlans();

const plus = await sdk.createSubscriptionPlan({
  name: "Plus",
  scope: "global",
  appIds: ["global"],
  benefitType: "free_requests",
  price: 499,
  isActive: true,
});

await sdk.updateSubscriptionPlan(plus._id, {
  price: 599,
  isActive: true,
});

await sdk.deleteSubscriptionPlan(plus._id);
```

Scopes:

- `global`: applies to every app.
- `app`: applies only to selected `appIds`.

Benefits:

- `free_requests`: requests are free while the subscription is active.
- `request_discount`: each request receives `discountPercent`.

### Request Packages

Request packages are global admin catalog entities for buying a fixed amount of
requests.

```ts
const packages = await sdk.listRequestPackages();

const packageItem = await sdk.createRequestPackage({
  requestCount: 100,
  price: 999,
  scope: "app",
  appIds: ["psychology"],
  isActive: true,
});

await sdk.updateRequestPackage(packageItem._id, {
  scope: "global",
  appIds: ["global"],
  price: 1199,
});

await sdk.deleteRequestPackage(packageItem._id);
```

Scope behavior:

- `app`: visible for purchase only in the selected apps and grants requests for
  the purchase app.
- `global`: visible in all apps and grants global request balance.

### Promo Codes

Promo codes are managed globally through the admin SDK, but each code is scoped
to an app.

```ts
const promoCodes = await sdk.listPromoCodes("psychology");

const promo = await sdk.createPromoCode({
  code: "START500",
  appId: "psychology",
  campaign: "Launch",
  amount: 500,
  maxRedemptions: 100,
  expiresAt: "2026-12-31T23:59:59.000Z",
});

await sdk.updatePromoCode(promo._id, {
  amount: 700,
  isActive: true,
});

await sdk.deletePromoCode(promo._id);
```

### App Version

```ts
const version = await sdk.getAppVersionSettings("psychology");

await sdk.updateAppVersionSettings("psychology", "v1.0.2+6");
```

### Wishes

```ts
const wishes = await sdk.listWishes("psychology");
const requests = await sdk.listWishRequests("psychology");

await sdk.createWish({
  appId: "psychology",
  text: "Published wish text",
  requestId: requestId,
});

await sdk.updateWish(wishId, {
  appId: "psychology",
  text: "Updated text",
});

await sdk.deleteWish("psychology", wishId);
await sdk.deleteWishRequest("psychology", requestId);
await sdk.clearWishRequests("psychology");
```

### Analytics

```ts
const analytics = await sdk.getAnalytics();
```

Currently this aggregates app and user data client-side in the admin SDK.

## Architecture Notes

- `mainApi` is the single shared API for users and shared platform features.
- `appId` separates data and settings between apps.
- Payment provider credentials are configured per app in the admin UI and are
  stored encrypted in Mongo. The old `.env` keys are only a fallback.
- Mobile apps still may keep app-specific backends temporarily. For example,
  the psychology app still uses its old backend for psychology-specific catalog
  data, but auth/profile/version/wishes and shared billing catalog settings are
  now in `mainApi`.
- Admin UI should call `mainSdk`, not the old psychology backend.
- Agents integrating a new app should use `AGENT_INTEGRATION.md` as the source
  of truth for the migration order and verification checklist.

## Current App Values

```text
mainApi: http://80.93.61.208:5195
new admin: http://80.93.61.208:5196

psychology appId: psychology
psychology old content backend: http://80.93.61.208:5183

doctors appId: med_app
doctors content backend: http://80.93.61.208:5193

gdz appId: gdz
callories appId: callories
```

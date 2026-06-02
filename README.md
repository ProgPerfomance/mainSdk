# main_sdk

Shared SDK for Selekt/Niami applications.

`main_sdk` is the common client layer for the shared `mainApi`. Each app keeps
its own `appId`, but uses the same API for users, auth, profile, app version,
wishes, and admin operations.

Current production `mainApi`:

```text
http://80.93.61.208:5195
```

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

TypeScript/admin SDK:

- app registry list/create/update;
- users list;
- user profile with transactions;
- user edit/delete;
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
- Mobile apps still may keep app-specific backends temporarily. For example,
  the psychology app still uses its old backend for psychology-specific catalog
  data, but auth/profile/version/wishes are now shared.
- Admin UI should call `mainSdk`, not the old psychology backend.

## Current Psychology App Values

```text
appId: psychology
mainApi: http://80.93.61.208:5195
old psychology backend: http://80.93.61.208:5183
new admin: http://80.93.61.208:5196
```

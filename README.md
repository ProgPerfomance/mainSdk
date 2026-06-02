# main_sdk

Shared Dart SDK for Selekt applications.

The SDK keeps `appId` in one configuration object and sends it both as
`X-App-Id` and in request bodies for old backend endpoints.

```dart
final sdk = SelektSdk(
  config: const SelektSdkConfig(
    appId: 'psychology',
    baseUrl: 'http://80.93.61.208:5183',
  ),
  sessionStore: mySessionStore,
);

final session = await sdk.login(email: email, password: password);
final profile = await sdk.getProfile(session.userId);
```

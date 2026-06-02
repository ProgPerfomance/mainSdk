export type ApiEnvelope<T> = {
  status: "success" | "error";
  data?: T;
  error?: string;
  errorMessage?: string;
  message?: string;
};

export type MainApp = {
  _id?: string;
  appId: string;
  app_id?: string;
  name: string;
  platform: string;
  apiBaseUrl?: string | null;
  settings?: Record<string, unknown>;
  isActive: boolean;
  createdAt?: string | null;
  updatedAt?: string | null;
};

export type MainUser = {
  _id: string;
  name: string;
  email: string;
  phoneNumber?: string | null;
  avatarUrl?: string | null;
  balance: number;
  requestBalance?: number;
  referralCode?: string | null;
  referralsCount?: number;
  createdAt: string;
  updatedAt: string;
};

export type MainSubscription = {
  subscriptionId?: string;
  subscription_id?: string;
  subscriptionName?: string;
  subscription_name?: string;
  scope: "app" | "global";
  appId: string;
  app_id?: string;
  appIds?: string[];
  app_ids?: string[];
  expiresAt?: string;
  hasActiveSubscription: boolean;
  benefitType?: "free_requests" | "request_discount";
  benefit_type?: "free_requests" | "request_discount";
  discountPercent?: number;
  autoRenewEnabled?: boolean;
  nextChargeAt?: string;
  updatedAt?: string;
};

export type MainSubscriptionPlan = {
  _id: string;
  name: string;
  scope: "app" | "global";
  appIds: string[];
  app_ids?: string[];
  benefitType: "free_requests" | "request_discount";
  benefit_type?: "free_requests" | "request_discount";
  discountPercent?: number;
  price: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
};

export type MainPromoCodeRedemption = {
  userId: string;
  userName?: string | null;
  userEmail?: string | null;
  redeemedAt: string;
};

export type MainPromoCode = {
  _id: string;
  code: string;
  appId: string;
  app_id?: string;
  campaign?: string | null;
  amount: number;
  isActive: boolean;
  maxRedemptions?: number | null;
  expiresAt?: string | null;
  isExpired?: boolean;
  redemptionsCount: number;
  redemptions?: MainPromoCodeRedemption[];
  createdAt: string;
  updatedAt: string;
};

export type MainRequestPackage = {
  _id: string;
  requestCount: number;
  price: number;
  appId: string;
  app_id?: string;
  appIds?: string[];
  app_ids?: string[];
  scope: "app" | "global";
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
};

export type MainTransaction = {
  _id: string;
  userId: string;
  userName?: string | null;
  amount: number;
  type: "deposit" | "withdrawal" | "payment";
  description?: string | null;
  metadata?: Record<string, unknown>;
  createdAt: string;
};

export type MainUserProfile = MainUser & {
  transactions: MainTransaction[];
  referrals?: MainUser[];
  subscriptions?: MainSubscription[];
};

export type MainAnalytics = {
  appsCount: number;
  activeAppsCount: number;
  usersCount: number;
  totalBalance: number;
  totalRequestBalance: number;
};

export type AppVersionSettings = {
  requiredVersion: string;
  updatedAt: string;
};

export type Wish = {
  _id: string;
  requestId?: string | null;
  appId?: string;
  app_id?: string;
  text: string;
  likeCount: number;
  dislikeCount: number;
  createdAt: string;
  updatedAt: string;
};

export type WishRequest = {
  _id: string;
  appId?: string;
  app_id?: string;
  userId?: string;
  text: string;
  createdAt: string;
  updatedAt: string;
};

export type CreateMainAppInput = {
  appId: string;
  name: string;
  platform: string;
  apiBaseUrl?: string;
  settings?: Record<string, unknown>;
};

export type UpdateMainAppInput = Partial<Omit<CreateMainAppInput, "appId">> & {
  isActive?: boolean;
};

export type UpdateMainUserInput = {
  name: string;
  email: string;
  phoneNumber?: string | null;
  avatarUrl?: string | null;
};

export type GrantMainSubscriptionInput = {
  adminName: string;
  subscriptionId: string;
  days: number;
  reason?: string;
};

export type CreateMainSubscriptionPlanInput = {
  name: string;
  scope: "app" | "global";
  appIds: string[];
  benefitType: "free_requests" | "request_discount";
  discountPercent?: number;
  price: number;
  isActive?: boolean;
};

export type UpdateMainSubscriptionPlanInput =
  Partial<CreateMainSubscriptionPlanInput>;

export type CreateMainPromoCodeInput = {
  code: string;
  appId: string;
  campaign?: string | null;
  amount: number;
  maxRedemptions?: number | null;
  expiresAt?: string | null;
};

export type UpdateMainPromoCodeInput = Partial<CreateMainPromoCodeInput> & {
  isActive?: boolean;
};

export type CreateMainRequestPackageInput = {
  requestCount: number;
  price: number;
  scope: "app" | "global";
  appIds?: string[];
  appId?: string;
  isActive?: boolean;
};

export type UpdateMainRequestPackageInput =
  Partial<CreateMainRequestPackageInput>;

export type CreateWishInput = {
  appId: string;
  text: string;
  requestId?: string | null;
};

export type UpdateWishInput = {
  appId: string;
  text: string;
  requestId?: string | null;
};

export type MainSdkConfig = {
  baseUrl: string;
  adminToken?: string;
  fetcher?: typeof fetch;
};

export declare class MainSdkError extends Error {
  readonly statusCode?: number;
  constructor(message: string, statusCode?: number);
}

export declare class MainAdminSdk {
  constructor(config: MainSdkConfig);
  listApps(): Promise<MainApp[]>;
  createApp(input: CreateMainAppInput): Promise<MainApp>;
  updateApp(appId: string, input: UpdateMainAppInput): Promise<MainApp>;
  listUsers(query?: string): Promise<MainUser[]>;
  getUserProfile(userId: string): Promise<MainUserProfile>;
  updateUser(userId: string, input: UpdateMainUserInput): Promise<MainUserProfile>;
  deleteUser(
    userId: string,
  ): Promise<{ deleted: true; _id: string; transactionsDeleted: number }>;
  listSubscriptionPlans(): Promise<MainSubscriptionPlan[]>;
  createSubscriptionPlan(
    input: CreateMainSubscriptionPlanInput,
  ): Promise<MainSubscriptionPlan>;
  updateSubscriptionPlan(
    planId: string,
    input: UpdateMainSubscriptionPlanInput,
  ): Promise<MainSubscriptionPlan>;
  deleteSubscriptionPlan(planId: string): Promise<{ deleted: true; _id: string }>;
  listPromoCodes(appId?: string): Promise<MainPromoCode[]>;
  createPromoCode(input: CreateMainPromoCodeInput): Promise<MainPromoCode>;
  updatePromoCode(
    promoCodeId: string,
    input: UpdateMainPromoCodeInput,
  ): Promise<MainPromoCode>;
  deletePromoCode(promoCodeId: string): Promise<{ deleted: true; _id: string }>;
  listRequestPackages(): Promise<MainRequestPackage[]>;
  createRequestPackage(
    input: CreateMainRequestPackageInput,
  ): Promise<MainRequestPackage>;
  updateRequestPackage(
    packageId: string,
    input: UpdateMainRequestPackageInput,
  ): Promise<MainRequestPackage>;
  deleteRequestPackage(packageId: string): Promise<{ deleted: true }>;
  grantUserSubscription(
    userId: string,
    input: GrantMainSubscriptionInput,
  ): Promise<{ user: MainUserProfile; transaction?: MainTransaction }>;
  clearUserSubscription(
    userId: string,
    input: {
      adminName: string;
      subscriptionId: string;
      reason?: string;
    },
  ): Promise<{ user: MainUserProfile; transaction?: MainTransaction }>;
  getAppVersionSettings(appId: string): Promise<AppVersionSettings>;
  updateAppVersionSettings(
    appId: string,
    requiredVersion: string,
  ): Promise<AppVersionSettings>;
  listWishes(appId: string): Promise<Wish[]>;
  createWish(input: CreateWishInput): Promise<Wish>;
  updateWish(wishId: string, input: UpdateWishInput): Promise<Wish>;
  deleteWish(
    appId: string,
    wishId: string,
  ): Promise<{ deleted: true; _id: string }>;
  listWishRequests(appId: string): Promise<WishRequest[]>;
  deleteWishRequest(
    appId: string,
    requestId: string,
  ): Promise<{ deleted: true; _id: string }>;
  clearWishRequests(appId: string): Promise<{ deleted: number }>;
  getAnalytics(): Promise<MainAnalytics>;
}

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
  displayName?: string | null;
  imageUrl?: string | null;
  shortDescription?: string | null;
  ruStoreUrl?: string | null;
  platform: string;
  apiBaseUrl?: string | null;
  relatedBlockIds?: string[];
  settings?: Record<string, unknown>;
  tBankSettings?: MainTBankSettingsStatus;
  isActive: boolean;
  createdAt?: string | null;
  updatedAt?: string | null;
};

export type MainRelatedAppBlock = {
  _id?: string;
  id: string;
  blockId: string;
  type: "grid" | "banner";
  title?: string | null;
  columns: number;
  appIds: string[];
  isActive: boolean;
  createdAt?: string | null;
  updatedAt?: string | null;
};

export type MainCustomContentCollection = {
  _id?: string;
  appId: string;
  app_id?: string;
  collectionKey: string;
  key?: string;
  name: string;
  description?: string | null;
  schema: Record<string, unknown>;
  settings: Record<string, unknown>;
  isActive: boolean;
  createdAt?: string | null;
  updatedAt?: string | null;
};

export type MainCustomContentItem = {
  _id?: string;
  appId: string;
  app_id?: string;
  collectionKey: string;
  collection_key?: string;
  itemId: string;
  slug?: string;
  title: string;
  description?: string | null;
  imageUrl?: string | null;
  image_url?: string | null;
  data: Record<string, unknown>;
  tags: string[];
  sortOrder: number;
  sort_order?: number;
  isActive: boolean;
  createdAt?: string | null;
  updatedAt?: string | null;
};

export type MainTBankSettingsStatus = {
  enabled: boolean;
  terminalKeyConfigured: boolean;
  passwordConfigured: boolean;
  configured: boolean;
  updatedAt?: string | null;
};

export type MainTBankSettingsReveal = MainTBankSettingsStatus & {
  terminalKey?: string | null;
  password?: string | null;
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
  displayName?: string;
  imageUrl?: string;
  shortDescription?: string;
  ruStoreUrl?: string;
  platform: string;
  apiBaseUrl?: string;
  relatedBlockIds?: string[];
  settings?: Record<string, unknown>;
};

export type UpdateMainAppInput = Partial<Omit<CreateMainAppInput, "appId">> & {
  isActive?: boolean;
};

export type UpdateMainTBankSettingsInput = {
  enabled?: boolean;
  terminalKey?: string;
  password?: string;
  clearTerminalKey?: boolean;
  clearPassword?: boolean;
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

export type CreateMainRelatedAppBlockInput = {
  blockId: string;
  type: "grid" | "banner";
  title?: string | null;
  columns?: number;
  appIds: string[];
  isActive?: boolean;
};

export type UpdateMainRelatedAppBlockInput =
  Partial<CreateMainRelatedAppBlockInput>;

export type CreateMainCustomContentCollectionInput = {
  appId: string;
  collectionKey: string;
  name: string;
  description?: string | null;
  schema?: Record<string, unknown>;
  settings?: Record<string, unknown>;
  isActive?: boolean;
};

export type UpdateMainCustomContentCollectionInput =
  Partial<Omit<CreateMainCustomContentCollectionInput, "appId" | "collectionKey">> & {
    appId: string;
  };

export type CreateMainCustomContentItemInput = {
  appId: string;
  itemId: string;
  title: string;
  description?: string | null;
  imageUrl?: string | null;
  data?: Record<string, unknown>;
  tags?: string[];
  sortOrder?: number;
  isActive?: boolean;
};

export type UpdateMainCustomContentItemInput =
  Partial<Omit<CreateMainCustomContentItemInput, "appId" | "itemId">> & {
    appId: string;
  };

export type MainCustomContentListOptions = {
  appId?: string;
  q?: string;
  tags?: string[];
  limit?: number;
  skip?: number;
};

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

export class MainSdkError extends Error {
  constructor(
    message: string,
    public readonly statusCode?: number,
  ) {
    super(message);
    this.name = "MainSdkError";
  }
}

export class MainAdminSdk {
  private readonly baseUrl: string;
  private readonly adminToken?: string;
  private readonly fetcher: typeof fetch;

  constructor(config: MainSdkConfig) {
    this.baseUrl = config.baseUrl.replace(/\/+$/, "");
    this.adminToken = config.adminToken;
    this.fetcher = config.fetcher ?? fetch;
  }

  listApps() {
    return this.request<MainApp[]>("/admin/api/apps");
  }

  createApp(input: CreateMainAppInput) {
    return this.request<MainApp>("/admin/api/apps", {
      method: "POST",
      body: JSON.stringify(input),
    });
  }

  updateApp(appId: string, input: UpdateMainAppInput) {
    return this.request<MainApp>(`/admin/api/apps/${encodeURIComponent(appId)}`, {
      method: "PUT",
      body: JSON.stringify(input),
    });
  }

  listRelatedAppBlocks() {
    return this.request<MainRelatedAppBlock[]>("/admin/api/related-app-blocks");
  }

  createRelatedAppBlock(input: CreateMainRelatedAppBlockInput) {
    return this.request<MainRelatedAppBlock>("/admin/api/related-app-blocks", {
      method: "POST",
      body: JSON.stringify(input),
    });
  }

  updateRelatedAppBlock(blockId: string, input: UpdateMainRelatedAppBlockInput) {
    return this.request<MainRelatedAppBlock>(
      `/admin/api/related-app-blocks/${encodeURIComponent(blockId)}`,
      {
        method: "PUT",
        body: JSON.stringify(input),
      },
    );
  }

  deleteRelatedAppBlock(blockId: string) {
    return this.request<{ deleted: true; blockId: string }>(
      `/admin/api/related-app-blocks/${encodeURIComponent(blockId)}`,
      { method: "DELETE" },
    );
  }

  listCustomContentCollections(appId: string) {
    return this.request<MainCustomContentCollection[]>(
      `/admin/api/content/collections?appId=${encodeURIComponent(appId)}`,
    );
  }

  createCustomContentCollection(input: CreateMainCustomContentCollectionInput) {
    return this.request<MainCustomContentCollection>("/admin/api/content/collections", {
      method: "POST",
      body: JSON.stringify(input),
    });
  }

  updateCustomContentCollection(
    collectionKey: string,
    input: UpdateMainCustomContentCollectionInput,
  ) {
    return this.request<MainCustomContentCollection>(
      `/admin/api/content/collections/${encodeURIComponent(collectionKey)}`,
      {
        method: "PUT",
        body: JSON.stringify(input),
      },
    );
  }

  deleteCustomContentCollection(appId: string, collectionKey: string, deleteItems = false) {
    return this.request<{ deleted: true; collectionKey: string }>(
      `/admin/api/content/collections/${encodeURIComponent(collectionKey)}?appId=${encodeURIComponent(appId)}&deleteItems=${deleteItems ? "true" : "false"}`,
      { method: "DELETE" },
    );
  }

  listCustomContentItems(
    appId: string,
    collectionKey: string,
    options: Omit<MainCustomContentListOptions, "appId"> = {},
  ) {
    const search = this.queryString({
      appId,
      q: options.q,
      tags: options.tags?.join(","),
      limit: options.limit,
      skip: options.skip,
    });
    return this.request<MainCustomContentItem[]>(
      `/admin/api/content/collections/${encodeURIComponent(collectionKey)}/items${search}`,
    );
  }

  createCustomContentItem(
    collectionKey: string,
    input: CreateMainCustomContentItemInput,
  ) {
    return this.request<MainCustomContentItem>(
      `/admin/api/content/collections/${encodeURIComponent(collectionKey)}/items`,
      {
        method: "POST",
        body: JSON.stringify(input),
      },
    );
  }

  updateCustomContentItem(
    collectionKey: string,
    itemId: string,
    input: UpdateMainCustomContentItemInput,
  ) {
    return this.request<MainCustomContentItem>(
      `/admin/api/content/collections/${encodeURIComponent(collectionKey)}/items/${encodeURIComponent(itemId)}`,
      {
        method: "PUT",
        body: JSON.stringify(input),
      },
    );
  }

  deleteCustomContentItem(appId: string, collectionKey: string, itemId: string) {
    return this.request<{ deleted: true; itemId: string }>(
      `/admin/api/content/collections/${encodeURIComponent(collectionKey)}/items/${encodeURIComponent(itemId)}?appId=${encodeURIComponent(appId)}`,
      { method: "DELETE" },
    );
  }

  updateAppTBankSettings(appId: string, input: UpdateMainTBankSettingsInput) {
    return this.request<MainApp>(
      `/admin/api/apps/${encodeURIComponent(appId)}/tbank`,
      {
        method: "PUT",
        body: JSON.stringify(input),
      },
    );
  }

  revealAppTBankSettings(appId: string, password: string) {
    return this.request<MainTBankSettingsReveal>(
      `/admin/api/apps/${encodeURIComponent(appId)}/tbank/reveal`,
      {
        method: "POST",
        body: JSON.stringify({ password }),
      },
    );
  }

  listUsers(query?: string) {
    const search = query ? `?q=${encodeURIComponent(query)}` : "";
    return this.request<MainUser[]>(`/admin/api/users${search}`);
  }

  getUserProfile(userId: string) {
    return this.request<MainUserProfile>(
      `/admin/api/users/${encodeURIComponent(userId)}`,
    );
  }

  updateUser(userId: string, input: UpdateMainUserInput) {
    return this.request<MainUserProfile>(
      `/admin/api/users/${encodeURIComponent(userId)}`,
      {
        method: "PUT",
        body: JSON.stringify(input),
      },
    );
  }

  deleteUser(userId: string) {
    return this.request<{ deleted: true; _id: string; transactionsDeleted: number }>(
      `/admin/api/users/${encodeURIComponent(userId)}`,
      { method: "DELETE" },
    );
  }

  listSubscriptionPlans() {
    return this.request<MainSubscriptionPlan[]>("/admin/api/subscriptions");
  }

  createSubscriptionPlan(input: CreateMainSubscriptionPlanInput) {
    return this.request<MainSubscriptionPlan>("/admin/api/subscriptions", {
      method: "POST",
      body: JSON.stringify(input),
    });
  }

  updateSubscriptionPlan(planId: string, input: UpdateMainSubscriptionPlanInput) {
    return this.request<MainSubscriptionPlan>(
      `/admin/api/subscriptions/${encodeURIComponent(planId)}`,
      {
        method: "PUT",
        body: JSON.stringify(input),
      },
    );
  }

  deleteSubscriptionPlan(planId: string) {
    return this.request<{ deleted: true; _id: string }>(
      `/admin/api/subscriptions/${encodeURIComponent(planId)}`,
      { method: "DELETE" },
    );
  }

  listPromoCodes(appId?: string) {
    const search = appId ? `?appId=${encodeURIComponent(appId)}` : "";
    return this.request<MainPromoCode[]>(`/admin/api/promo-codes${search}`);
  }

  createPromoCode(input: CreateMainPromoCodeInput) {
    return this.request<MainPromoCode>("/admin/api/promo-codes", {
      method: "POST",
      body: JSON.stringify(input),
    });
  }

  updatePromoCode(promoCodeId: string, input: UpdateMainPromoCodeInput) {
    return this.request<MainPromoCode>(
      `/admin/api/promo-codes/${encodeURIComponent(promoCodeId)}`,
      {
        method: "PUT",
        body: JSON.stringify(input),
      },
    );
  }

  deletePromoCode(promoCodeId: string) {
    return this.request<{ deleted: true; _id: string }>(
      `/admin/api/promo-codes/${encodeURIComponent(promoCodeId)}`,
      { method: "DELETE" },
    );
  }

  listRequestPackages() {
    return this.request<MainRequestPackage[]>("/admin/api/billing/request-packages");
  }

  createRequestPackage(input: CreateMainRequestPackageInput) {
    return this.request<MainRequestPackage>("/admin/api/billing/request-packages", {
      method: "POST",
      body: JSON.stringify(input),
    });
  }

  updateRequestPackage(packageId: string, input: UpdateMainRequestPackageInput) {
    return this.request<MainRequestPackage>(
      `/admin/api/billing/request-packages/${encodeURIComponent(packageId)}`,
      {
        method: "PUT",
        body: JSON.stringify(input),
      },
    );
  }

  deleteRequestPackage(packageId: string) {
    return this.request<{ deleted: true }>(
      `/admin/api/billing/request-packages/${encodeURIComponent(packageId)}`,
      { method: "DELETE" },
    );
  }

  grantUserSubscription(userId: string, input: GrantMainSubscriptionInput) {
    return this.request<{ user: MainUserProfile; transaction?: MainTransaction }>(
      `/admin/api/users/${encodeURIComponent(userId)}/subscription`,
      {
        method: "PUT",
        body: JSON.stringify(input),
      },
    );
  }

  clearUserSubscription(userId: string, input: {
    adminName: string;
    subscriptionId: string;
    reason?: string;
  }) {
    return this.request<{ user: MainUserProfile; transaction?: MainTransaction }>(
      `/admin/api/users/${encodeURIComponent(userId)}/subscription`,
      {
        method: "DELETE",
        body: JSON.stringify(input),
      },
    );
  }

  getAppVersionSettings(appId: string) {
    return this.request<AppVersionSettings>(
      `/admin/api/app/version?appId=${encodeURIComponent(appId)}`,
    );
  }

  updateAppVersionSettings(appId: string, requiredVersion: string) {
    return this.request<AppVersionSettings>("/admin/api/app/version", {
      method: "PUT",
      body: JSON.stringify({ appId, requiredVersion }),
    });
  }

  listWishes(appId: string) {
    return this.request<Wish[]>(
      `/admin/api/wishes?appId=${encodeURIComponent(appId)}`,
    );
  }

  createWish(input: CreateWishInput) {
    return this.request<Wish>("/admin/api/wishes", {
      method: "POST",
      body: JSON.stringify(input),
    });
  }

  updateWish(wishId: string, input: UpdateWishInput) {
    return this.request<Wish>(
      `/admin/api/wishes/${encodeURIComponent(wishId)}`,
      {
        method: "PUT",
        body: JSON.stringify(input),
      },
    );
  }

  deleteWish(appId: string, wishId: string) {
    return this.request<{ deleted: true; _id: string }>(
      `/admin/api/wishes/${encodeURIComponent(wishId)}?appId=${encodeURIComponent(appId)}`,
      { method: "DELETE" },
    );
  }

  listWishRequests(appId: string) {
    return this.request<WishRequest[]>(
      `/admin/api/wish-requests?appId=${encodeURIComponent(appId)}`,
    );
  }

  deleteWishRequest(appId: string, requestId: string) {
    return this.request<{ deleted: true; _id: string }>(
      `/admin/api/wish-requests/${encodeURIComponent(requestId)}?appId=${encodeURIComponent(appId)}`,
      { method: "DELETE" },
    );
  }

  clearWishRequests(appId: string) {
    return this.request<{ deleted: number }>(
      `/admin/api/wish-requests?appId=${encodeURIComponent(appId)}`,
      { method: "DELETE" },
    );
  }

  async getAnalytics(): Promise<MainAnalytics> {
    const [apps, users] = await Promise.all([this.listApps(), this.listUsers()]);
    return {
      appsCount: apps.length,
      activeAppsCount: apps.filter((app) => app.isActive).length,
      usersCount: users.length,
      totalBalance: users.reduce((sum, user) => sum + Number(user.balance || 0), 0),
      totalRequestBalance: users.reduce(
        (sum, user) => sum + Number(user.requestBalance || 0),
        0,
      ),
    };
  }

  listPublicContentCollections(appId: string) {
    return this.request<MainCustomContentCollection[]>(
      `/api/v1/content/collections?appId=${encodeURIComponent(appId)}`,
    );
  }

  listPublicContentItems(collectionKey: string, options: MainCustomContentListOptions = {}) {
    const search = this.queryString({
      appId: options.appId,
      q: options.q,
      tags: options.tags?.join(","),
      limit: options.limit,
      skip: options.skip,
    });
    return this.request<MainCustomContentItem[]>(
      `/api/v1/content/${encodeURIComponent(collectionKey)}${search}`,
    );
  }

  getPublicContentItem(collectionKey: string, itemId: string, appId?: string) {
    const search = this.queryString({ appId });
    return this.request<MainCustomContentItem>(
      `/api/v1/content/${encodeURIComponent(collectionKey)}/${encodeURIComponent(itemId)}${search}`,
    );
  }

  private queryString(params: Record<string, unknown>) {
    const search = new URLSearchParams();
    for (const [key, value] of Object.entries(params)) {
      if (value === undefined || value === null || value === "") continue;
      search.set(key, String(value));
    }
    const value = search.toString();
    return value ? `?${value}` : "";
  }

  private async request<T>(path: string, init: RequestInit = {}): Promise<T> {
    const headers = new Headers(init.headers);
    headers.set("Accept", "application/json");
    if (!headers.has("Content-Type") && init.body) {
      headers.set("Content-Type", "application/json");
    }
    if (this.adminToken) {
      headers.set("X-Admin-Token", this.adminToken);
    }

    const response = await this.fetcher(`${this.baseUrl}${path}`, {
      ...init,
      headers,
      cache: "no-store",
    });
    const text = await response.text();
    const envelope = (text ? JSON.parse(text) : {}) as ApiEnvelope<T>;

    if (!response.ok || envelope.status === "error") {
      throw new MainSdkError(
        envelope.errorMessage ||
          envelope.error ||
          envelope.message ||
          response.statusText ||
          "Main API request failed",
        response.status,
      );
    }

    return envelope.data as T;
  }
}

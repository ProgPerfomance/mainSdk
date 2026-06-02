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

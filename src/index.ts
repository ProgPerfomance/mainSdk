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
  balance: number;
  requestBalance?: number;
  referralCode?: string | null;
  referralsCount?: number;
  createdAt: string;
  updatedAt: string;
};

export type MainAnalytics = {
  appsCount: number;
  activeAppsCount: number;
  usersCount: number;
  totalBalance: number;
  totalRequestBalance: number;
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

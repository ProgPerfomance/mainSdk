export class MainSdkError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.name = "MainSdkError";
    this.statusCode = statusCode;
  }
}

export class MainAdminSdk {
  constructor(config) {
    this.baseUrl = config.baseUrl.replace(/\/+$/, "");
    this.adminToken = config.adminToken;
    this.fetcher = config.fetcher ?? fetch;
  }

  listApps() {
    return this.request("/admin/api/apps");
  }

  createApp(input) {
    return this.request("/admin/api/apps", {
      method: "POST",
      body: JSON.stringify(input),
    });
  }

  updateApp(appId, input) {
    return this.request(`/admin/api/apps/${encodeURIComponent(appId)}`, {
      method: "PUT",
      body: JSON.stringify(input),
    });
  }

  listUsers(query) {
    const search = query ? `?q=${encodeURIComponent(query)}` : "";
    return this.request(`/admin/api/users${search}`);
  }

  async getAnalytics() {
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

  async request(path, init = {}) {
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
    const envelope = text ? JSON.parse(text) : {};

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

    return envelope.data;
  }
}

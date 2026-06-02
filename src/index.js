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

  getUserProfile(userId) {
    return this.request(`/admin/api/users/${encodeURIComponent(userId)}`);
  }

  updateUser(userId, input) {
    return this.request(`/admin/api/users/${encodeURIComponent(userId)}`, {
      method: "PUT",
      body: JSON.stringify(input),
    });
  }

  deleteUser(userId) {
    return this.request(`/admin/api/users/${encodeURIComponent(userId)}`, {
      method: "DELETE",
    });
  }

  listSubscriptionPlans() {
    return this.request("/admin/api/subscriptions");
  }

  createSubscriptionPlan(input) {
    return this.request("/admin/api/subscriptions", {
      method: "POST",
      body: JSON.stringify(input),
    });
  }

  updateSubscriptionPlan(planId, input) {
    return this.request(`/admin/api/subscriptions/${encodeURIComponent(planId)}`, {
      method: "PUT",
      body: JSON.stringify(input),
    });
  }

  deleteSubscriptionPlan(planId) {
    return this.request(`/admin/api/subscriptions/${encodeURIComponent(planId)}`, {
      method: "DELETE",
    });
  }

  listPromoCodes(appId) {
    const search = appId ? `?appId=${encodeURIComponent(appId)}` : "";
    return this.request(`/admin/api/promo-codes${search}`);
  }

  createPromoCode(input) {
    return this.request("/admin/api/promo-codes", {
      method: "POST",
      body: JSON.stringify(input),
    });
  }

  updatePromoCode(promoCodeId, input) {
    return this.request(`/admin/api/promo-codes/${encodeURIComponent(promoCodeId)}`, {
      method: "PUT",
      body: JSON.stringify(input),
    });
  }

  deletePromoCode(promoCodeId) {
    return this.request(`/admin/api/promo-codes/${encodeURIComponent(promoCodeId)}`, {
      method: "DELETE",
    });
  }

  grantUserSubscription(userId, input) {
    return this.request(`/admin/api/users/${encodeURIComponent(userId)}/subscription`, {
      method: "PUT",
      body: JSON.stringify(input),
    });
  }

  clearUserSubscription(userId, input) {
    return this.request(`/admin/api/users/${encodeURIComponent(userId)}/subscription`, {
      method: "DELETE",
      body: JSON.stringify(input),
    });
  }

  getAppVersionSettings(appId) {
    return this.request(
      `/admin/api/app/version?appId=${encodeURIComponent(appId)}`,
    );
  }

  updateAppVersionSettings(appId, requiredVersion) {
    return this.request("/admin/api/app/version", {
      method: "PUT",
      body: JSON.stringify({ appId, requiredVersion }),
    });
  }

  listWishes(appId) {
    return this.request(`/admin/api/wishes?appId=${encodeURIComponent(appId)}`);
  }

  createWish(input) {
    return this.request("/admin/api/wishes", {
      method: "POST",
      body: JSON.stringify(input),
    });
  }

  updateWish(wishId, input) {
    return this.request(`/admin/api/wishes/${encodeURIComponent(wishId)}`, {
      method: "PUT",
      body: JSON.stringify(input),
    });
  }

  deleteWish(appId, wishId) {
    return this.request(
      `/admin/api/wishes/${encodeURIComponent(wishId)}?appId=${encodeURIComponent(appId)}`,
      { method: "DELETE" },
    );
  }

  listWishRequests(appId) {
    return this.request(
      `/admin/api/wish-requests?appId=${encodeURIComponent(appId)}`,
    );
  }

  deleteWishRequest(appId, requestId) {
    return this.request(
      `/admin/api/wish-requests/${encodeURIComponent(requestId)}?appId=${encodeURIComponent(appId)}`,
      { method: "DELETE" },
    );
  }

  clearWishRequests(appId) {
    return this.request(
      `/admin/api/wish-requests?appId=${encodeURIComponent(appId)}`,
      { method: "DELETE" },
    );
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

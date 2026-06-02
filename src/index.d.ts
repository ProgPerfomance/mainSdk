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

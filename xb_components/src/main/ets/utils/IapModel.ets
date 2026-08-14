export interface PurchaseData {
  type: number;
  jwsPurchaseOrder?: string;
  jwsSubscriptionStatus?: string;
}

export interface PurchaseOrderPayload {
  productId: string;
  productType: number;
  purchaseOrderId: string;
  purchaseToken: string;
  finishStatus?: FinishStatus;
  purchaseTime: number
}

export enum FinishStatus {
  FINISHED = '1',
  UNFINISHED = '2'
}

export interface SubGroupStatusPayload {
  environment: string;
  applicationId: string;
  packageName: string;
  subGroupId: string;
  lastSubscriptionStatus?: SubscriptionStatus;
  historySubscriptionStatusList?: SubscriptionStatus[];
}

export interface SubscriptionStatus {
  subGroupGenerationId: string;
  subscriptionId: string;
  purchaseToken: string;
  status: string;
  expiresTime: number;
  lastPurchaseOrder?: PurchaseOrderPayload;
  renewalInfo?: SubRenewalInfo;
}

interface SubRenewalInfo {
  productId: string;
}

export enum SubStatus {
  ACTIVE = '1',
  EXPIRED = '2',
  CHARGE_ATTEMPT = '3',
  REVOKED = '5'
}
class ApiEndpoints {
  // Base URLs
  // Production Hostinger API URL
  static const String defaultProdBaseUrl = "https://wellsee.co.in/wellsloan/public/api";
  
  // Local Android Emulator: 10.0.2.2:8000/api
  // Local iOS Simulator: 127.0.0.1:8000/api
  static const String localAndroidBaseUrl = "http://10.0.2.2:8000/api";
  static const String localIosBaseUrl = "http://127.0.0.1:8000/api";

  // Active Base URL (configurable at runtime in settings)
  static String activeBaseUrl = defaultProdBaseUrl;

  // Auth Routes
  static const String signup = "/auth/signup";
  static const String login = "/auth/login";
  static const String logout = "/logout";
  static const String me = "/me";

  // Dashboard & Loans
  static const String dashboardSummary = "/dashboard/summary";
  static const String loans = "/loans";
  static const String applications = "/applications";
  
  // Payments & EMIs
  static const String payments = "/payments";
  static String payPayment(String id) => "/payments/$id/pay";

  // KYC Verification
  static const String kycUpload = "/kyc/upload";
  static const String kycStatus = "/kyc/status";

  // Eligibility & AI
  static const String eligibilityCheck = "/eligibility/check";
  static const String aiAdvisor = "/ai/advisor";
  static const String aiKycScan = "/ai/kyc-scan";
}

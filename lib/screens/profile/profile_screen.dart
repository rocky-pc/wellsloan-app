import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/status_badge.dart';
import '../auth/login_screen.dart';
import '../kyc/kyc_hub_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sign Out?"),
        content: const Text("Are you sure you want to securely log out of Wellsloan App?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rose,
              foregroundColor: Colors.white,
            ),
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  void _showApiSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Backend API Environment",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text("Production Hostinger API"),
              subtitle: Text(ApiEndpoints.defaultProdBaseUrl),
              leading: const Icon(Icons.cloud_done_rounded, color: AppColors.emerald),
              onTap: () {
                ApiEndpoints.activeBaseUrl = ApiEndpoints.defaultProdBaseUrl;
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Switched to Production Hostinger API")),
                );
              },
            ),
            ListTile(
              title: const Text("Local Android Emulator (10.0.2.2:8000)"),
              subtitle: Text(ApiEndpoints.localAndroidBaseUrl),
              leading: const Icon(Icons.developer_mode_rounded, color: AppColors.primary),
              onTap: () {
                ApiEndpoints.activeBaseUrl = ApiEndpoints.localAndroidBaseUrl;
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Switched to Local Android Emulator API")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          "My Profile & Settings",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.avatarInitials ?? "WL",
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? "Borrower",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          user?.email ?? "",
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Member since ${DateHelper.formatFriendly(user?.memberSince)}",
                          style: const TextStyle(fontSize: 11, color: AppColors.textSubtle),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: user?.kycStatus ?? 'not_started'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings Group 1: Verification & Security
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.emerald,
                    title: "KYC Verification",
                    subtitle: user?.isKycVerified == true ? "Verified (Full Access)" : "Pending Review / Action Needed",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const KycHubScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 20),
                    ),
                    title: const Text(
                      "Biometric App Lock",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    subtitle: const Text(
                      "Unlock with Face ID / Fingerprint",
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    value: auth.biometricEnabled,
                    onChanged: (val) => auth.toggleBiometric(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings Group 2: Preferences & Admin
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.account_balance_outlined,
                    iconColor: AppColors.sky,
                    title: "Bank Account & Disbursal Mandate",
                    subtitle: "HDFC Bank (•••• 4921) • eNACH Active",
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    icon: Icons.notifications_none_rounded,
                    iconColor: AppColors.amberDark,
                    title: "EMI Reminders & Notifications",
                    subtitle: "WhatsApp & SMS notifications active",
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    icon: Icons.api_rounded,
                    iconColor: AppColors.primary,
                    title: "API Endpoint Switcher",
                    subtitle: "Configured: ${ApiEndpoints.activeBaseUrl}",
                    onTap: () => _showApiSwitcher(context),
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    icon: Icons.support_agent_rounded,
                    iconColor: AppColors.emerald,
                    title: "24/7 Wellsloan Support",
                    subtitle: "support@wellsee.co.in",
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.rose.withOpacity(0.3)),
              ),
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.roseLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout_rounded, color: AppColors.rose, size: 20),
                ),
                title: const Text(
                  "Sign Out Securely",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.roseDark,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.rose, size: 20),
                onTap: () => _showLogoutDialog(context),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Wellsloan Mobile App • Version 1.0.0 (Build 2026)\nLicensed NBFC Digital Lending Partner",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textSubtle, height: 1.5),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}

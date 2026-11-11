import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kyc_provider.dart';
import '../../widgets/common/error_banner.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/wells_button.dart';
import '../../widgets/common/wells_text_field.dart';
import 'kyc_scan_screen.dart';

class KycHubScreen extends StatefulWidget {
  const KycHubScreen({super.key});

  @override
  State<KycHubScreen> createState() => _KycHubScreenState();
}

class _KycHubScreenState extends State<KycHubScreen> {
  String _selectedDocType = "aadhaar";
  final TextEditingController _docNumberController = TextEditingController();
  File? _selectedFile;

  final List<Map<String, String>> _docTypes = [
    {'value': 'aadhaar', 'label': 'Aadhaar Card (12-digits UIDAI)', 'hint': '5842 9104 3829'},
    {'value': 'pan', 'label': 'PAN Card (10-characters)', 'hint': 'ABCDE1234F'},
    {'value': 'passport', 'label': 'Passport', 'hint': 'N8392015'},
    {'value': 'driving_license', 'label': 'Driving License', 'hint': 'DL-0420180019284'},
    {'value': 'voter_id', 'label': 'Voter ID (EPIC)', 'hint': 'WLS9284716'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KycProvider>().fetchKycStatus();
    });
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _selectedFile = File(picked.path));
    }
  }

  Future<void> _pickFromFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select or scan an ID document.")),
      );
      return;
    }

    final kycProvider = context.read<KycProvider>();
    final success = await kycProvider.uploadDocument(
      file: _selectedFile!,
      documentType: _selectedDocType,
      documentNumber: _docNumberController.text.trim(),
    );

    if (success && mounted) {
      context.read<AuthProvider>().refreshUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document uploaded successfully! Verification in progress.")),
      );
    }
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kycProvider = context.watch<KycProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final isVerified = user?.isKycVerified ?? false;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          "KYC Verification Center",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (kycProvider.errorMessage != null) ...[
              ErrorBanner(message: kycProvider.errorMessage!),
              const SizedBox(height: 16),
            ],

            // Current Verification Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isVerified ? AppColors.emeraldLight : AppColors.amberLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isVerified ? Icons.verified_rounded : Icons.shield_outlined,
                      color: isVerified ? AppColors.emeraldDark : AppColors.amberDark,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVerified ? "Account Verified ✅" : "Verification Incomplete",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isVerified
                              ? "You are eligible for highest sanction limits and instant bank disbursals."
                              : "Submit your government ID to unlock paperless credit lines.",
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: user?.kycStatus ?? 'not_started'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!isVerified) ...[
              // AI Smart Scanner CTA Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.aiCopilotGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "AI Instant Document Scan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Gemini Vision auto-detects name, ID number & verifies security markings.",
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final scanned = await Navigator.of(context).push<Map<String, dynamic>>(
                          MaterialPageRoute(
                            builder: (_) => KycScanScreen(documentType: _selectedDocType),
                          ),
                        );

                        if (scanned != null && mounted) {
                          if (scanned['documentNumber'] != null) {
                            _docNumberController.text = scanned['documentNumber'];
                          }
                          if (scanned['filePath'] != null) {
                            setState(() => _selectedFile = File(scanned['filePath']));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textDark,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Scan", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Document Selection
              const Text(
                "Select Government ID Type",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDocType,
                    isExpanded: true,
                    items: _docTypes.map((t) {
                      return DropdownMenuItem<String>(
                        value: t['value'],
                        child: Text(
                          t['label']!,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDocType = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              WellsTextField(
                label: "Document Identification Number",
                hint: _docTypes.firstWhere((t) => t['value'] == _selectedDocType)['hint'],
                controller: _docNumberController,
                prefixIcon: const Icon(Icons.badge_outlined, size: 20),
              ),
              const SizedBox(height: 20),

              // File Selection Area
              const Text(
                "Upload Document Photo / PDF",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 10),

              if (_selectedFile != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedFile!.path.split('/').last,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emeraldDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.emeraldDark),
                        onPressed: () => setState(() => _selectedFile = null),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderLight, width: 1.5),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 28),
                              SizedBox(height: 8),
                              Text(
                                "Choose Photo",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickFromFiles,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderLight, width: 1.5),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.attach_file_rounded, color: AppColors.primary, size: 28),
                              SizedBox(height: 8),
                              Text(
                                "Upload PDF / Doc",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              WellsButton(
                text: "Submit for Official Verification",
                isLoading: kycProvider.isUploading,
                onPressed: _handleUpload,
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }
}

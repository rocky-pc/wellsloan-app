import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/kyc_provider.dart';
import '../../widgets/common/wells_button.dart';

class KycScanScreen extends StatefulWidget {
  final String documentType;

  const KycScanScreen({super.key, required this.documentType});

  @override
  State<KycScanScreen> createState() => _KycScanScreenState();
}

class _KycScanScreenState extends State<KycScanScreen> with SingleTickerProviderStateMixin {
  File? _capturedImage;
  Map<String, dynamic>? _scanResult;
  bool _isAnalyzing = false;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (picked != null) {
      _processImage(File(picked.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked != null) {
      _processImage(File(picked.path));
    }
  }

  Future<void> _processImage(File file) async {
    setState(() {
      _capturedImage = file;
      _isAnalyzing = true;
      _scanResult = null;
    });

    final kycProvider = context.read<KycProvider>();
    final result = await kycProvider.scanDocumentAi(file, widget.documentType);

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _scanResult = result;
      });
    }
  }

  void _confirmAndReturn() {
    if (_scanResult != null) {
      Navigator.of(context).pop({
        'documentType': _scanResult!['documentType'] ?? widget.documentType,
        'documentNumber': _scanResult!['documentNumber'],
        'fullName': _scanResult!['fullName'],
        'filePath': _capturedImage?.path,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "AI Document Scanner",
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text(
                _capturedImage == null
                    ? "Align your ${widget.documentType.toUpperCase()} within the frame and tap capture."
                    : "Gemini Vision is inspecting authenticity & extracting identity fields.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),

            // Viewfinder / Preview Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Image or Camera Viewfinder Placeholder
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF151D2F),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      child: _capturedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.file(_capturedImage!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.document_scanner_outlined, size: 72, color: Colors.white.withOpacity(0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  "Position Document Here",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),

                    // Laser Radar Line when analyzing
                    if (_isAnalyzing)
                      AnimatedBuilder(
                        animation: _radarController,
                        builder: (ctx, child) {
                          return Positioned(
                            top: 40 + (_radarController.value * 280),
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.emerald,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.emerald.withOpacity(0.8),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    // Corner frame brackets
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CustomPaint(
                          painter: _ScannerFramePainter(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Results & Action Controls
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF101726),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_scanResult != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A233A),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.emerald.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    "Gemini OCR Verified",
                                    style: TextStyle(
                                      color: AppColors.emerald,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Confidence: ${((_scanResult!['confidenceScore'] ?? 0.98) * 100).toInt()}%",
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white12, height: 16),
                          Text(
                            "ID Number: ${_scanResult!['documentNumber'] ?? 'Detected'}",
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          if (_scanResult!['fullName'] != null)
                            Text(
                              "Holder: ${_scanResult!['fullName']}",
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    WellsButton(
                      text: "Use Extracted Details",
                      backgroundColor: AppColors.emerald,
                      onPressed: _confirmAndReturn,
                    ),
                    const SizedBox(height: 10),
                  ],

                  if (_scanResult == null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 28),
                        ),
                        // Shutter button
                        GestureDetector(
                          onTap: _isAnalyzing ? null : _captureFromCamera,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              color: AppColors.primary,
                            ),
                            child: _isAnalyzing
                                ? const Center(
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                  )
                                : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            _capturedImage = null;
                            _scanResult = null;
                          }),
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 28),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

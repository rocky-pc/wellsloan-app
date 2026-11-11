import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/kyc_document_model.dart';
import '../data/repositories/kyc_repository.dart';

class KycProvider with ChangeNotifier {
  final KycRepository _repo = KycRepository();

  String _kycStatus = 'not_started';
  KycDocumentModel? _latestDocument;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isScanning = false;
  String? _errorMessage;
  Map<String, dynamic>? _aiScanResult;

  String get kycStatus => _kycStatus;
  KycDocumentModel? get latestDocument => _latestDocument;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get isScanning => _isScanning;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get aiScanResult => _aiScanResult;

  bool get isVerified => _kycStatus == 'verified';
  bool get isPending => _kycStatus == 'pending';
  bool get isActionRequired => _kycStatus == 'not_started' || _kycStatus == 'rejected';

  Future<void> fetchKycStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repo.getKycStatus();
      _kycStatus = res['kycStatus'] ?? 'not_started';
      _latestDocument = res['latestDocument'];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadDocument({
    required File file,
    required String documentType,
    String? documentNumber,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final doc = await _repo.uploadDocument(
        file: file,
        documentType: documentType,
        documentNumber: documentNumber,
      );
      _latestDocument = doc;
      _kycStatus = doc.status;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> scanDocumentAi(File file, String documentType) async {
    _isScanning = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      final mimeType = file.path.endsWith('.png') ? 'image/png' : 'image/jpeg';

      final extracted = await _repo.scanDocumentAi(
        imageBase64: base64String,
        documentType: documentType,
        mimeType: mimeType,
      );

      _aiScanResult = extracted;
      return extracted;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  void clearAiScan() {
    _aiScanResult = null;
    notifyListeners();
  }
}

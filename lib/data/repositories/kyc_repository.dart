import 'dart:io';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/kyc_document_model.dart';

class KycRepository {
  final ApiClient _client;

  KycRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<Map<String, dynamic>> getKycStatus() async {
    final response = await _client.get(ApiEndpoints.kycStatus);
    final data = response.data;
    
    KycDocumentModel? latestDoc;
    if (data['latestDocument'] != null) {
      latestDoc = KycDocumentModel.fromJson(data['latestDocument']);
    }

    return {
      'kycStatus': data['kycStatus'] ?? 'not_started',
      'kycDocumentUrl': data['kycDocumentUrl'],
      'latestDocument': latestDoc,
    };
  }

  Future<KycDocumentModel> uploadDocument({
    required File file,
    required String documentType,
    String? documentNumber,
  }) async {
    final response = await _client.uploadFile(
      ApiEndpoints.kycUpload,
      file: file,
      fileKey: 'file',
      extraFields: {
        'document_type': documentType,
        if (documentNumber != null && documentNumber.isNotEmpty)
          'document_number': documentNumber,
      },
    );

    return KycDocumentModel.fromJson(response.data['document']);
  }

  Future<Map<String, dynamic>> scanDocumentAi({
    required String imageBase64,
    String documentType = 'aadhaar',
    String mimeType = 'image/jpeg',
  }) async {
    final response = await _client.post(
      ApiEndpoints.aiKycScan,
      data: {
        'imageBase64': imageBase64,
        'documentType': documentType,
        'mimeType': mimeType,
      },
    );

    return response.data['extracted'] ?? {};
  }
}

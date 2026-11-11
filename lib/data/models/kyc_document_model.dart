class KycDocumentModel {
  final int? id;
  final String documentType; // aadhaar, pan, passport, driving_license, voter_id
  final String? documentNumber;
  final String status; // pending, verified, rejected
  final String? url;
  final String? adminNote;
  final String? submittedAt;

  KycDocumentModel({
    this.id,
    required this.documentType,
    this.documentNumber,
    required this.status,
    this.url,
    this.adminNote,
    this.submittedAt,
  });

  bool get isVerified => status == 'verified';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  String get friendlyName {
    switch (documentType) {
      case 'aadhaar':
        return 'Aadhaar Card';
      case 'pan':
        return 'PAN Card';
      case 'passport':
        return 'Passport';
      case 'driving_license':
        return 'Driving License';
      case 'voter_id':
        return 'Voter ID';
      default:
        return 'ID Document';
    }
  }

  factory KycDocumentModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentModel(
      id: json['id'],
      documentType: json['documentType'] ?? json['document_type'] ?? 'aadhaar',
      documentNumber: json['documentNumber'] ?? json['document_number'],
      status: json['status'] ?? 'pending',
      url: json['url'] ?? json['file_path'],
      adminNote: json['adminNote'] ?? json['admin_note'],
      submittedAt: json['submittedAt'] ?? json['submitted_at'] ?? json['created_at'],
    );
  }
}

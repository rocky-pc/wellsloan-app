class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String kycStatus; // not_started, pending, verified, rejected
  final String? kycDocumentUrl;
  final String avatarInitials;
  final String memberSince;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.kycStatus,
    this.kycDocumentUrl,
    required this.avatarInitials,
    required this.memberSince,
  });

  bool get isKycVerified => kycStatus == 'verified';
  bool get isKycPending => kycStatus == 'pending';
  bool get isKycNotStarted => kycStatus == 'not_started';
  bool get isKycRejected => kycStatus == 'rejected';

  String get firstName => name.split(' ').first;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      kycStatus: json['kycStatus'] ?? json['kyc_status'] ?? 'not_started',
      kycDocumentUrl: json['kycDocumentUrl'] ?? json['kyc_document_url'],
      avatarInitials: json['avatarInitials'] ?? json['avatar_initials'] ?? 'W',
      memberSince: json['memberSince'] ?? json['member_since'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'kycStatus': kycStatus,
      'kycDocumentUrl': kycDocumentUrl,
      'avatarInitials': avatarInitials,
      'memberSince': memberSince,
    };
  }
}

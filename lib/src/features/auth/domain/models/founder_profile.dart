import 'package:cloud_firestore/cloud_firestore.dart';

class FounderProfile {
  const FounderProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.businessName,
    required this.industry,
    required this.businessStage,
    required this.needs,
    this.bio,
    this.website,
    this.city,
    this.isAccredited = false,
    this.isAdmin = false,
    this.biometricEnabled = false,
    this.fcmToken,
    this.profilePhotoUrl,
    this.createdAt,
    this.updatedAt,
    this.lastSeenAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final String businessName;
  final String industry;
  final String businessStage;
  final List<String> needs;
  final String? bio;
  final String? website;
  final String? city;
  final bool isAccredited;
  final bool isAdmin;
  final bool biometricEnabled;
  final String? fcmToken;
  final String? profilePhotoUrl;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? lastSeenAt;

  factory FounderProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return FounderProfile(
      uid: data['uid'] as String? ?? doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      businessName: data['businessName'] as String? ?? '',
      industry: data['industry'] as String? ?? '',
      businessStage: data['businessStage'] as String? ?? '',
      needs: List<String>.from(data['needs'] as List? ?? const []),
      bio: data['bio'] as String?,
      website: data['website'] as String?,
      city: data['city'] as String?,
      isAccredited: data['isAccredited'] as bool? ?? false,
      isAdmin: data['isAdmin'] as bool? ?? false,
      biometricEnabled: data['biometricEnabled'] as bool? ?? false,
      fcmToken: data['fcmToken'] as String?,
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
      lastSeenAt: data['lastSeenAt'] as Timestamp?,
    );
  }

  Map<String, Object?> toCreateFirestore() {
    return {
      'uid': uid,
      'email': email.toLowerCase().trim(),
      'displayName': displayName.trim(),
      'businessName': businessName.trim(),
      'industry': industry,
      'businessStage': businessStage,
      'needs': needs,
      'bio': _blankToNull(bio),
      'website': _blankToNull(website),
      'city': _blankToNull(city),
      'isAccredited': false,
      'isAdmin': false,
      'biometricEnabled': false,
      'fcmToken': fcmToken,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, Object?> toUpdateFirestore() {
    return {
      'displayName': displayName.trim(),
      'businessName': businessName.trim(),
      'industry': industry.trim(),
      'businessStage': businessStage.trim(),
      'needs': needs
          .map((need) => need.trim())
          .where((need) => need.isNotEmpty)
          .toList(),
      'bio': _blankToNull(bio),
      'website': _blankToNull(website),
      'city': _blankToNull(city),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  FounderProfile copyWith({
    String? displayName,
    String? businessName,
    String? industry,
    String? businessStage,
    List<String>? needs,
    String? bio,
    String? website,
    String? city,
  }) {
    return FounderProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      businessName: businessName ?? this.businessName,
      industry: industry ?? this.industry,
      businessStage: businessStage ?? this.businessStage,
      needs: needs ?? this.needs,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      city: city ?? this.city,
      isAccredited: isAccredited,
      isAdmin: isAdmin,
      biometricEnabled: biometricEnabled,
      fcmToken: fcmToken,
      profilePhotoUrl: profilePhotoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSeenAt: lastSeenAt,
    );
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

import '../domain/models/founder_profile.dart';

class RegistrationDraft {
  RegistrationDraft({
    this.email = '',
    this.password = '',
    this.fullName = '',
    this.businessName = '',
    this.bio = '',
    this.website = '',
    this.city = '',
    this.industry = 'Technology',
    this.businessStage = 'Early Stage (0-1 yrs)',
    Set<String>? needs,
  }) : needs = needs ?? {'Funding & Grants', 'Mentorship', 'Tech Solutions'};

  String email;
  String password;
  String fullName;
  String businessName;
  String bio;
  String website;
  String city;
  String industry;
  String businessStage;
  Set<String> needs;

  FounderProfile toFounderProfile({required String uid}) {
    return FounderProfile(
      uid: uid,
      email: email,
      displayName: fullName,
      businessName: businessName,
      industry: industry,
      businessStage: businessStage,
      needs: needs.toList()..sort(),
      bio: bio,
      website: website,
      city: city,
    );
  }
}

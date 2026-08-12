import 'package:equatable/equatable.dart';

enum CrisisResourceType {
  nationalHotline,
  localHotline,
  emergencyService,
  crisisCenter,
  warmLine,
  textLine,
  onlineChat,
}

enum CrisisResourceAccess {
  phone,
  text,
  chat,
  inPerson,
}

class CrisisResource extends Equatable {
  final String id;
  final String name;
  final CrisisResourceType type;
  final String? phoneNumber;
  final String? textNumber;
  final String? website;
  final String? chatUrl;
  final String description;
  final bool isNational;
  final String? region;
  final String? address;
  final List<CrisisResourceAccess> accessMethods;
  final bool is24Hours;
  final List<String> languages;
  final bool isFree;
  final String? imageUrl;

  const CrisisResource({
    required this.id,
    required this.name,
    required this.type,
    this.phoneNumber,
    this.textNumber,
    this.website,
    this.chatUrl,
    required this.description,
    this.isNational = false,
    this.region,
    this.address,
    this.accessMethods = const [],
    this.is24Hours = false,
    this.languages = const ['English'],
    this.isFree = true,
    this.imageUrl,
  });

  static const CrisisResource nationalLifeline = CrisisResource(
    id: '988_lifeline',
    name: '988 Suicide & Crisis Lifeline',
    type: CrisisResourceType.nationalHotline,
    phoneNumber: '988',
    textNumber: '988',
    website: 'https://988lifeline.org',
    chatUrl: 'https://988lifeline.org/chat',
    description: 'Free, confidential crisis support 24/7 for anyone in emotional distress or suicidal crisis.',
    isNational: true,
    is24Hours: true,
    languages: ['English', 'Spanish'],
    isFree: true,
  );

  static const CrisisResource crisisTextLine = CrisisResource(
    id: 'crisis_text_line',
    name: 'Crisis Text Line',
    type: CrisisResourceType.textLine,
    textNumber: '741741',
    website: 'https://www.crisistextline.org',
    description: 'Text HOME to 741741 to connect with a trained crisis counselor 24/7.',
    isNational: true,
    is24Hours: true,
    languages: ['English'],
    isFree: true,
  );

  static const CrisisResource samhsaHelpline = CrisisResource(
    id: 'samhsa_helpline',
    name: 'SAMHSA National Helpline',
    type: CrisisResourceType.nationalHotline,
    phoneNumber: '1-800-662-4357',
    website: 'https://www.samhsa.gov/find-help/national-helpline',
    description: 'Free, confidential, 24/7 treatment referral and information service for individuals and families facing mental health and/or substance use disorders.',
    isNational: true,
    is24Hours: true,
    languages: ['English', 'Spanish'],
    isFree: true,
  );

  static const List<CrisisResource> defaultResources = [
    nationalLifeline,
    crisisTextLine,
    samhsaHelpline,
  ];

  factory CrisisResource.fromMap(Map<String, dynamic> map) {
    return CrisisResource(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: CrisisResourceType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => CrisisResourceType.nationalHotline,
      ),
      phoneNumber: map['phoneNumber'],
      textNumber: map['textNumber'],
      website: map['website'],
      chatUrl: map['chatUrl'],
      description: map['description'] ?? '',
      isNational: map['isNational'] ?? false,
      region: map['region'],
      address: map['address'],
      accessMethods: (map['accessMethods'] as List<dynamic>?)
          ?.map((e) => CrisisResourceAccess.values.firstWhere(
                (a) => a.toString() == e,
                orElse: () => CrisisResourceAccess.phone,
              ))
          .toList() ?? [],
      is24Hours: map['is24Hours'] ?? false,
      languages: List<String>.from(map['languages'] ?? ['English']),
      isFree: map['isFree'] ?? true,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'phoneNumber': phoneNumber,
      'textNumber': textNumber,
      'website': website,
      'chatUrl': chatUrl,
      'description': description,
      'isNational': isNational,
      'region': region,
      'address': address,
      'accessMethods': accessMethods.map((e) => e.toString()).toList(),
      'is24Hours': is24Hours,
      'languages': languages,
      'isFree': isFree,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [
    id, name, type, phoneNumber, textNumber, website, chatUrl,
    description, isNational, region, address, accessMethods,
    is24Hours, languages, isFree, imageUrl
  ];
}
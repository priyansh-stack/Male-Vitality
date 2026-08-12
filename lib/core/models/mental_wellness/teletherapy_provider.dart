import 'package:equatable/equatable.dart';

enum TeletherapyProviderType {
  betterhelp,
  talkspace,
  amwell,
  doctorOnDemand,
  cerebral,
  localProvider,
}

class TeletherapyProvider extends Equatable {
  final String id;
  final String name;
  final TeletherapyProviderType type;
  final String description;
  final String logoUrl;
  final double? monthlyPrice;
  final String? pricingInfo;
  final List<String> specialties;
  final bool acceptsInsurance;
  final List<String> acceptedInsurances;
  final String deepLinkUrl;
  final String? promoCode;
  final String? promoDescription;
  final double? rating;

  const TeletherapyProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.logoUrl,
    this.monthlyPrice,
    this.pricingInfo,
    this.specialties = const [],
    this.acceptsInsurance = false,
    this.acceptedInsurances = const [],
    required this.deepLinkUrl,
    this.promoCode,
    this.promoDescription,
    this.rating,
  });

  static final List<TeletherapyProvider> defaultProviders = [
    TeletherapyProvider(
      id: 'betterhelp',
      name: 'BetterHelp',
      type: TeletherapyProviderType.betterhelp,
      description: 'Online therapy with licensed therapists via video, chat, or phone.',
      logoUrl: 'https://example.com/betterhelp.png',
      monthlyPrice: 260,
      pricingInfo: 'Starting at 260/month',
      specialties: const ['Anxiety', 'Depression', 'Stress', 'Relationship Issues'],
      acceptsInsurance: false,
      deepLinkUrl: 'https://betterhelp.com',
      promoCode: 'HEALTH30',
      promoDescription: 'Get 30% off your first month',
      rating: 4.5,
    ),
    const TeletherapyProvider(
      id: 'talkspace',
      name: 'Talkspace',
      type: TeletherapyProviderType.talkspace,
      description: 'Message your therapist anytime, plus live video sessions.',
      logoUrl: 'https://example.com/talkspace.png',
      monthlyPrice: 276,
      pricingInfo: 'Starting at 276/month',
      specialties: ['Anxiety', 'Depression', 'PTSD', 'LGBTQ+'],
      acceptsInsurance: true,
      acceptedInsurances: ['Cigna', 'Optum', 'Aetna'],
      deepLinkUrl: 'https://talkspace.com',
      promoCode: 'WELLNESS20',
      promoDescription: '20% off your first month',
      rating: 4.3,
    ),
    const TeletherapyProvider(
      id: 'amwell',
      name: 'Amwell',
      type: TeletherapyProviderType.amwell,
      description: 'Video visits with licensed therapists and psychiatrists.',
      logoUrl: 'https://example.com/amwell.png',
      pricingInfo: '79-129 per session',
      specialties: ['Anxiety', 'Depression', 'Psychiatry', 'Child/Adolescent'],
      acceptsInsurance: true,
      acceptedInsurances: ['Medicare', 'Blue Cross', 'Cigna'],
      deepLinkUrl: 'https://amwell.com',
      rating: 4.2,
    ),
  ];

  factory TeletherapyProvider.fromMap(Map<String, dynamic> map) {
    return TeletherapyProvider(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: TeletherapyProviderType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => TeletherapyProviderType.localProvider,
      ),
      description: map['description'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      monthlyPrice: (map['monthlyPrice'] as num?)?.toDouble(),
      pricingInfo: map['pricingInfo'],
      specialties: List<String>.from(map['specialties'] ?? []),
      acceptsInsurance: map['acceptsInsurance'] ?? false,
      acceptedInsurances: List<String>.from(map['acceptedInsurances'] ?? []),
      deepLinkUrl: map['deepLinkUrl'] ?? '',
      promoCode: map['promoCode'],
      promoDescription: map['promoDescription'],
      rating: (map['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'description': description,
      'logoUrl': logoUrl,
      'monthlyPrice': monthlyPrice,
      'pricingInfo': pricingInfo,
      'specialties': specialties,
      'acceptsInsurance': acceptsInsurance,
      'acceptedInsurances': acceptedInsurances,
      'deepLinkUrl': deepLinkUrl,
      'promoCode': promoCode,
      'promoDescription': promoDescription,
      'rating': rating,
    };
  }

  @override
  List<Object?> get props => [
    id, name, type, description, logoUrl, monthlyPrice, pricingInfo,
    specialties, acceptsInsurance, acceptedInsurances, deepLinkUrl,
    promoCode, promoDescription, rating
  ];
}
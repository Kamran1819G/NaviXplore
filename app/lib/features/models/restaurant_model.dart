import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id; // Document ID from Firestore
  final String name;
  final String imageUrl;
  final double rating;
  final double distance;
  final String description;

  // Monetization-specific fields
  final bool isOnboarded;
  final double memberDiscount;
  final int totalMembershipDeals;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;
  final String address;

  // Business details
  final String cuisineType;
  final double averageMealPrice;
  final List<String> membershipBenefits;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.rating = 0.0,
    this.distance = 0.0,
    this.description = '',
    this.isOnboarded = false,
    this.memberDiscount = 0.0,
    this.totalMembershipDeals = 0,
    this.contactPerson = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.address = '',
    this.cuisineType = '',
    this.averageMealPrice = 0.0,
    this.membershipBenefits = const [],
  });

  // Convert RestaurantModel to a Map suitable for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'distance': distance,
      'description': description,
      'isOnboarded': isOnboarded,
      'memberDiscount': memberDiscount,
      'totalMembershipDeals': totalMembershipDeals,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'address': address,
      'cuisineType': cuisineType,
      'averageMealPrice': averageMealPrice,
      'membershipBenefits': membershipBenefits,
    };
  }

  // Create RestaurantModel from a DocumentSnapshot from Firestore
  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    return RestaurantModel(
      id: doc.id,
      name: data?['name'] ?? '',
      imageUrl: data?['imageUrl'] ?? '',
      rating: data?['rating']?.toDouble() ?? 0.0,
      distance: data?['distance']?.toDouble() ?? 0.0,
      description: data?['description'] ?? '',
      isOnboarded: data?['isOnboarded'] ?? false,
      memberDiscount: data?['memberDiscount']?.toDouble() ?? 0.0,
      totalMembershipDeals: data?['totalMembershipDeals'] ?? 0,
      contactPerson: data?['contactPerson'] ?? '',
      contactEmail: data?['contactEmail'] ?? '',
      contactPhone: data?['contactPhone'] ?? '',
      address: data?['address'] ?? '',
      cuisineType: data?['cuisineType'] ?? '',
      averageMealPrice: data?['averageMealPrice']?.toDouble() ?? 0.0,
      membershipBenefits: List<String>.from(data?['membershipBenefits'] ?? []),
    );
  }

}
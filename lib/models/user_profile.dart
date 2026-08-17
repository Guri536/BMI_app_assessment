import '../core/bmi_utils.dart';

class UserProfile {
  final String id;
  final String ownerUid;
  final String name;
  final String gender;
  final double heightCm;
  final double weightKg;
  final WeightUnit preferredWeightUnit;
  final HeightUnit preferredHeightUnit;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.preferredWeightUnit,
    required this.preferredHeightUnit,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? name,
    String? gender,
    double? heightCm,
    double? weightKg,
    WeightUnit? preferredWeightUnit,
    HeightUnit? preferredHeightUnit,
  }) {
    return UserProfile(
      id: id,
      ownerUid: ownerUid,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      preferredWeightUnit: preferredWeightUnit ?? this.preferredWeightUnit,
      preferredHeightUnit: preferredHeightUnit ?? this.preferredHeightUnit,
      createdAt: createdAt,
    );
  }
}

enum WeightUnit { kg, lbs }
enum HeightUnit { cm, inches }

extension WeightUnitLabel on WeightUnit {
  String get label => switch (this) {
        WeightUnit.kg => 'KGS',
        WeightUnit.lbs => 'LBS',
      };
}

extension HeightUnitLabel on HeightUnit {
  String get label => switch (this) {
        HeightUnit.cm => 'CM',
        HeightUnit.inches => 'Inches',
      };
}

class UnitConverter {
  UnitConverter._();
  static const double kgPerLb = 0.45359237;
  static const double cmPerInch = 2.54;

  static double lbsToKg(double lbs) => lbs * kgPerLb;
  static double kgToLbs(double kg) => kg / kgPerLb;
  static double inchesToCm(double inches) => inches * cmPerInch;
  static double cmToInches(double cm) => cm / cmPerInch;

  static double toKg(double value, WeightUnit unit) => switch (unit) {
        WeightUnit.kg => value,
        WeightUnit.lbs => lbsToKg(value),
      };

  static double toCm(double value, HeightUnit unit) => switch (unit) {
        HeightUnit.cm => value,
        HeightUnit.inches => inchesToCm(value),
      };
}

enum BmiCategory { underweight, normal, overweight, obese }

extension BmiCategoryLabel on BmiCategory {
  String get label => switch (this) {
        BmiCategory.underweight => 'Underweight',
        BmiCategory.normal => 'Normal weight',
        BmiCategory.overweight => 'Overweight',
        BmiCategory.obese => 'Obese',
      };
}

class BmiCalculator {
  BmiCalculator._();

  static double calculate({required double weightKg, required double heightCm}) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static BmiCategory categoryFor(double bmi) => switch (bmi) {
        <= 0 => BmiCategory.normal,
        < 18.5 => BmiCategory.underweight,
        < 25 => BmiCategory.normal,
        < 30 => BmiCategory.overweight,
        _ => BmiCategory.obese,
      };

  static String formatted(double bmi) => bmi.toStringAsFixed(1);
}

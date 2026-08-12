import '../../domain/entities/inbody_scan_entity.dart';

class InBodyScanModel extends InBodyScanEntity {
  const InBodyScanModel({
    required super.date,
    required super.weight,
    required super.weightChange,
    required super.bodyFat,
    required super.bodyFatChange,
    required super.muscleMass,
    required super.muscleMassChange,
    required super.bmi,
    required super.bmiStatus,
    required super.totalWeightLost,
    required super.totalMuscleGain,
    required super.totalBodyFatChange,
  });

  factory InBodyScanModel.fromJson(Map<String, dynamic> json) {
    return InBodyScanModel(
      date: (json['date'] ?? '').toString(),
      weight: (json['weight'] ?? '0').toString(),
      weightChange: (json['weight_change'] ?? json['weightChange'] ?? '0').toString(),
      bodyFat: (json['body_fat_pct'] ?? json['bodyFat'] ?? '0').toString(),
      bodyFatChange: (json['body_fat_change'] ?? json['bodyFatChange'] ?? '0').toString(),
      muscleMass: (json['muscle_mass'] ?? json['muscleMass'] ?? '0').toString(),
      muscleMassChange: (json['muscle_mass_change'] ?? json['muscleMassChange'] ?? '0').toString(),
      bmi: (json['bmi'] ?? '0').toString(),
      bmiStatus: (json['bmi_status'] ?? json['bmiStatus'] ?? 'Normal').toString(),
      totalWeightLost: (json['total_weight_lost'] ?? json['totalWeightLost'] ?? '0').toString(),
      totalMuscleGain: (json['total_muscle_gain'] ?? json['totalMuscleGain'] ?? '0').toString(),
      totalBodyFatChange: (json['total_body_fat_change'] ?? json['totalBodyFatChange'] ?? '0').toString(),
    );
  }
}

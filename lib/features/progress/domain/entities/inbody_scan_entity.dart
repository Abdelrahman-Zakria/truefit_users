import 'package:equatable/equatable.dart';

class InBodyScanEntity extends Equatable {
  final String date;
  final String weight;
  final String weightChange;
  final String bodyFat;
  final String bodyFatChange;
  final String muscleMass;
  final String muscleMassChange;
  final String bmi;
  final String bmiStatus;
  
  // Overall stats
  final String totalWeightLost;
  final String totalMuscleGain;
  final String totalBodyFatChange;

  const InBodyScanEntity({
    required this.date,
    required this.weight,
    required this.weightChange,
    required this.bodyFat,
    required this.bodyFatChange,
    required this.muscleMass,
    required this.muscleMassChange,
    required this.bmi,
    required this.bmiStatus,
    required this.totalWeightLost,
    required this.totalMuscleGain,
    required this.totalBodyFatChange,
  });

  @override
  List<Object?> get props => [
    date, weight, weightChange, bodyFat, bodyFatChange, 
    muscleMass, muscleMassChange, bmi, bmiStatus,
    totalWeightLost, totalMuscleGain, totalBodyFatChange
  ];
}

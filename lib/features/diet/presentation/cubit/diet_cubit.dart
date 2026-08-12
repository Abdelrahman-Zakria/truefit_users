import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_diet_plan_usecase.dart';
import '../../domain/usecases/update_water_intake_usecase.dart';
import 'diet_state.dart';

class DietCubit extends Cubit<DietState> {
  final GetDietPlanUseCase getDietPlanUseCase;
  final UpdateWaterIntakeUseCase updateWaterIntakeUseCase;
  StreamSubscription? _dietSubscription;

  DietCubit({
    required this.getDietPlanUseCase,
    required this.updateWaterIntakeUseCase,
  }) : super(DietInitial());

  Future<void> loadDietPlan(int persId) async {
    emit(DietLoading());
    await _dietSubscription?.cancel();
    _dietSubscription = getDietPlanUseCase.call(persId).listen(
      (dietPlan) => emit(DietLoaded(dietPlan)),
      onError: (e) => emit(DietError(e.toString())),
    );
  }

  Future<void> updateWater(int persId, double amount) async {
    try {
      await updateWaterIntakeUseCase(UpdateWaterIntakeParams(persId: persId, amount: amount));
    } catch (e) {
      emit(DietError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _dietSubscription?.cancel();
    return super.close();
  }

  void reset() {
    emit(DietInitial());
    _dietSubscription?.cancel();
  }
}

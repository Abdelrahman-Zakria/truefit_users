import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;

  HomeCubit({required this.getHomeDataUseCase}) : super(HomeInitial());

  Future<void> loadHomeData({int? persId}) async {
    emit(HomeLoading());
    try {
      final homeData = await getHomeDataUseCase(HomeDataParams(persId: persId));
      emit(HomeLoaded(
        promotions: homeData.promotions,
        outdoorSessions: homeData.outdoorSessions,
        offers: homeData.offers,
        packages: homeData.packages,
        activityStats: homeData.activityStats,
        upcomingSessions: homeData.upcomingSessions,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void reset() {
    emit(HomeInitial());
  }
}

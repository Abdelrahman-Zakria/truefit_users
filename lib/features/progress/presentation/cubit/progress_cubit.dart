import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_progress_usecase.dart';
import '../../domain/usecases/book_inbody_scan_usecase.dart';
import 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final GetProgressUseCase getProgressUseCase;
  final BookInBodyScanUseCase bookInBodyScanUseCase;
  StreamSubscription? _progressSubscription;

  ProgressCubit({
    required this.getProgressUseCase,
    required this.bookInBodyScanUseCase,
  }) : super(ProgressInitial());

  Future<void> loadProgressData(int persId) async {
    emit(ProgressLoading());
    await _progressSubscription?.cancel();
    _progressSubscription = getProgressUseCase(persId).listen(
      (scans) {
        if (scans.isEmpty) {
          emit(const ProgressError("No progress data found"));
        } else {
          emit(ProgressLoaded(scans.last, scans));
        }
      },
      onError: (e) => emit(ProgressError(e.toString())),
    );
  }

  Future<void> bookScan({
    required int persId,
    required String memberName,
    required String date,
    required String time,
  }) async {
    try {
      await bookInBodyScanUseCase(BookInBodyScanParams(
        persId: persId,
        memberName: memberName,
        date: date,
        time: time,
      ));
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }

  void reset() {
    emit(ProgressInitial());
    _progressSubscription?.cancel();
  }
}

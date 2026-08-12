import '../repositories/progress_repository.dart';

class BookInBodyScanParams {
  final int persId;
  final String memberName;
  final String date;
  final String time;

  BookInBodyScanParams({
    required this.persId,
    required this.memberName,
    required this.date,
    required this.time,
  });
}

class BookInBodyScanUseCase {
  final ProgressRepository repository;

  BookInBodyScanUseCase(this.repository);

  Future<void> call(BookInBodyScanParams params) {
    return repository.bookInBodyScan(
      persId: params.persId,
      memberName: params.memberName,
      date: params.date,
      time: params.time,
    );
  }
}

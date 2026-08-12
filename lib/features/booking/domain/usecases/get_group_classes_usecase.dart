import '../../../../core/usecases/usecase.dart';
import '../entities/group_class_entity.dart';
import '../repositories/booking_repository.dart';

class GetGroupClassesUseCase implements UseCase<List<GroupClassEntity>, void> {
  final BookingRepository repository;

  GetGroupClassesUseCase(this.repository);

  @override
  Future<List<GroupClassEntity>> call(void params) {
    return repository.getGroupClasses();
  }
}

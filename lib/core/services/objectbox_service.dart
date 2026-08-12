import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart'; // This will be generated
import '../../features/auth/data/models/user_box_entity.dart';

class ObjectBoxService {
  late final Store store;
  late final Box<UserBoxEntity> userBox;

  ObjectBoxService._create(this.store) {
    userBox = Box<UserBoxEntity>(store);
  }

  static Future<ObjectBoxService> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "truefit-db"));
    return ObjectBoxService._create(store);
  }

  void saveUser(UserBoxEntity user) {
    userBox.removeAll(); // Keep only one logged in user
    userBox.put(user);
  }

  UserBoxEntity? getUser() {
    final users = userBox.getAll();
    return users.isNotEmpty ? users.first : null;
  }

  void clearUser() {
    userBox.removeAll();
  }
}

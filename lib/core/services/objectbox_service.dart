import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart'; // This will be generated
import '../../features/auth/data/models/user_box_entity.dart';
import '../../features/notifications/data/models/notification_box_entity.dart';

class ObjectBoxService {
  late final Store store;
  late final Box<UserBoxEntity> userBox;
  late final Box<NotificationBoxEntity> notificationBox;

  ObjectBoxService._create(this.store) {
    userBox = Box<UserBoxEntity>(store);
    notificationBox = Box<NotificationBoxEntity>(store);
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

  // Notifications
  void saveNotification(NotificationBoxEntity notification) {
    notificationBox.put(notification);
  }

  List<NotificationBoxEntity> getNotifications() {
    final query = notificationBox.query().order(NotificationBoxEntity_.timestamp, flags: Order.descending).build();
    return query.find();
  }

  void markNotificationRead(int id) {
    final n = notificationBox.get(id);
    if (n != null) {
      n.isRead = true;
      notificationBox.put(n);
    }
  }

  void markAllNotificationsRead() {
    final unread = notificationBox.query(NotificationBoxEntity_.isRead.equals(false)).build().find();
    for (var n in unread) {
      n.isRead = true;
    }
    notificationBox.putMany(unread);
  }
}

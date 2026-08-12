import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ConversationModel>> watchConversations(int persId);
  Stream<List<MessageModel>> watchMessages(String conversationId);
  Future<void> sendMessage(int persId, String conversationId, String text, String senderName);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ConversationModel>> watchConversations(int persId) {
    return _firestore
        .collection('Gym_Conversations')
        .where('participants', arrayContains: persId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _firestore
        .collection('Gym_Conversations')
        .doc(conversationId)
        .collection('Messages')
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> sendMessage(int persId, String conversationId, String text, String senderName) async {
    final msgData = {
      'text': text,
      'sender_id': persId,
      'sender_name': senderName,
      'created_at': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('Gym_Conversations')
        .doc(conversationId)
        .collection('Messages')
        .add(msgData);

    await _firestore.collection('Gym_Conversations').doc(conversationId).update({
      'last_message': text,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}

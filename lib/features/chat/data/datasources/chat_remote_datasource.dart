import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ConversationModel>> watchConversations(int persId);
  Stream<List<MessageModel>> watchMessages(String conversationId, int persId);
  Future<void> sendMessage(int persId, String conversationId, String text, String senderName);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ConversationModel>> watchConversations(int persId) {
    // 1. Existing conversations where the user is a participant
    final convStream = _firestore
        .collection('Gym_Conversations')
        .where('participants', arrayContains: persId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());

    // 2. PT Wallets to find coaches the user has active subscriptions with
    final walletStream = _firestore
        .collection('User_PT_Wallet')
        .where('pers_ID', isEqualTo: persId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => (doc.data()['sessions_left'] ?? 0) > 0)
            .map((doc) => doc.data()['coach_id'] as String)
            .toSet());

    // 3. Coaches info stream
    final coachesStream = _firestore.collection('Gym_Coaches').snapshots().map((snapshot) => snapshot.docs);

    return Rx.combineLatest3<List<ConversationModel>, Set<String>, List<QueryDocumentSnapshot<Map<String, dynamic>>>, List<ConversationModel>>(
      convStream,
      walletStream,
      coachesStream,
      (existingConvs, subscribedCoachIds, coachesDocs) {
        final List<ConversationModel> result = List.from(existingConvs);
        
        for (final coachId in subscribedCoachIds) {
          // Check if a conversation already exists with this coach
          // Assuming participants array [persId, coachId]
          final hasConv = existingConvs.any((c) => c.id == '${persId}_$coachId' || c.id == '${coachId}_$persId');

          if (!hasConv) {
            // Find coach details
            final coachDoc = coachesDocs.firstWhere((doc) => doc.id == coachId);
            final coachData = coachDoc.data();
            
            // Localized specialty
            String role = "Coach";
            if (coachData['specialty'] is Map) {
              role = coachData['specialty']['en'] ?? "Coach";
            }

            result.add(ConversationModel(
              id: '${persId}_$coachId',
              name: coachData['name'] ?? 'Coach',
              role: role,
              isOnline: false,
              lastMessage: "Start a conversation",
              image: coachData['image'],
              unreadCount: 0,
            ));
          }
        }
        return result;
      },
    );
  }

  @override
  Stream<List<MessageModel>> watchMessages(String conversationId, int persId) {
    return _firestore
        .collection('Gym_Conversations')
        .doc(conversationId)
        .collection('Messages')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data(), doc.id, persId))
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

    final convRef = _firestore.collection('Gym_Conversations').doc(conversationId);
    final convDoc = await convRef.get();

    if (!convDoc.exists) {
      // Create conversation document if it's the first message (for synthetic conversations)
      // Extract coachId from conversationId (format: persId_coachId)
      final parts = conversationId.split('_');
      String coachId = parts.length > 1 ? parts[1] : '';
      
      // If the ID is coachId_persId, parts[0] might be coachId
      if (coachId == persId.toString()) coachId = parts[0];

      await convRef.set({
        'participants': [persId, coachId],
        'last_message': text,
        'updated_at': FieldValue.serverTimestamp(),
        'pers_id': persId,
        'coach_id': coachId,
      });
    } else {
      await convRef.update({
        'last_message': text,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    await convRef.collection('Messages').add(msgData);
  }
}

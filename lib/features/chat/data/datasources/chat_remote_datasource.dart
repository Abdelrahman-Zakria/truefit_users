import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/services/fcm_v1_service.dart';
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
    final convStream = _firestore
        .collection('Gym_Conversations')
        .where('participants', arrayContains: persId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());

    final walletStream = _firestore
        .collection('User_PT_Wallet')
        .where('pers_ID', isEqualTo: persId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => (doc.data()['sessions_left'] ?? 0) > 0)
            .map((doc) => doc.data()['coach_id'] as String)
            .toSet());

    final coachesStream = _firestore.collection('Gym_Coaches').snapshots().map((snapshot) => snapshot.docs);

    return Rx.combineLatest3<List<ConversationModel>, Set<String>, List<QueryDocumentSnapshot<Map<String, dynamic>>>, List<ConversationModel>>(
      convStream,
      walletStream,
      coachesStream,
      (existingConvs, subscribedCoachIds, coachesDocs) {
        final List<ConversationModel> result = List.from(existingConvs);
        
        for (final coachId in subscribedCoachIds) {
          final hasConv = existingConvs.any((c) => c.id == '${persId}_$coachId' || c.id == '${coachId}_$persId');

          if (!hasConv) {
            final coachDoc = coachesDocs.firstWhere((doc) => doc.id == coachId);
            final coachData = coachDoc.data();
            
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

    String coachId = '';

    if (!convDoc.exists) {
      final parts = conversationId.split('_');
      coachId = parts.length > 1 ? parts[1] : '';
      if (coachId == persId.toString()) coachId = parts[0];

      await convRef.set({
        'participants': [persId, coachId],
        'last_message': text,
        'updated_at': FieldValue.serverTimestamp(),
        'pers_id': persId,
        'coach_id': coachId,
      });
    } else {
      final data = convDoc.data();
      coachId = data?['coach_id']?.toString() ?? '';
      if (coachId.isEmpty) {
        final List participants = data?['participants'] ?? [];
        for (var p in participants) {
          if (p.toString() != persId.toString()) {
            coachId = p.toString();
            break;
          }
        }
      }

      await convRef.update({
        'last_message': text,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    await convRef.collection('Messages').add(msgData);

    // Send direct Push Notification to the target Coach
    if (coachId.isNotEmpty) {
      _sendPushToCoach(
        coachId: coachId,
        senderName: senderName,
        text: text,
        conversationId: conversationId,
        persId: persId,
      );
    }
  }

  Future<void> _sendPushToCoach({
    required String coachId,
    required String senderName,
    required String text,
    required String conversationId,
    required int persId,
  }) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> coachDoc =
          await _firestore.collection('Gym_Coaches').doc(coachId).get();

      if (!coachDoc.exists) {
        final q = await _firestore
            .collection('Gym_Coaches')
            .where('uid', isEqualTo: coachId)
            .limit(1)
            .get();
        if (q.docs.isNotEmpty) {
          coachDoc = q.docs.first;
        }
      }

      if (coachDoc.exists) {
        final coachData = coachDoc.data();
        final fcmToken = coachData?['fcmToken'] ?? coachData?['fcm_token'];

        // Write notification document to Coach_Notifications collection
        await _firestore.collection('Coach_Notifications').add({
          'coach_id': coachId,
          'coach_uid': coachData?['uid'] ?? coachId,
          'title': senderName,
          'body': text,
          'type': 'chat',
          'conversation_id': conversationId,
          'sender_id': persId,
          'sender_name': senderName,
          'fcm_token': fcmToken,
          'created_at': FieldValue.serverTimestamp(),
        });

        // Send direct FCM HTTP v1 notification if token exists
        if (fcmToken != null && fcmToken.toString().isNotEmpty) {
          await FcmV1Service.sendNotification(
            targetToken: fcmToken.toString(),
            title: senderName,
            body: text,
            data: {
              'type': 'chat',
              'conversation_id': conversationId,
              'sender_id': persId.toString(),
              'sender_name': senderName,
            },
          );
        }
      }
    } catch (e) {
      print('Failed to send push notification to coach $coachId: $e');
    }
  }
}

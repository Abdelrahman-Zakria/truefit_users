import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class Coach {
  final String id;
  final String name;
  final String role;
  final bool online;
  final Color color;

  const Coach({
    required this.id,
    required this.name,
    required this.role,
    required this.online,
    required this.color,
  });
}

class ChatPreview {
  final String preview;
  final String time;
  final int unread;

  const ChatPreview({
    required this.preview,
    required this.time,
    required this.unread,
  });
}

class Message {
  final int id;
  final String sender; // 'user' or 'coach'
  final String text;
  final String time;
  final bool voice;
  final String? duration;

  const Message({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
    this.voice = false,
    this.duration,
  });
}

const Map<String, Coach> COACHES = {
  "1": Coach(id: "1", name: "Coach Sarah Mitchell", role: "Strength & Conditioning", online: true, color: AppTheme.primaryRed),
  "2": Coach(id: "2", name: "Coach Marcus Chen", role: "HIIT & Boxing", online: true, color: Colors.purple),
  "3": Coach(id: "3", name: "Coach Emily Rodriguez", role: "Yoga & Flexibility", online: false, color: Colors.blue),
  "4": Coach(id: "4", name: "Nutrition Team", role: "Diet & Meal Planning", online: true, color: Colors.green),
};

const Map<String, ChatPreview> PREVIEWS = {
  "1": ChatPreview(preview: "Your current meal plan is working well. Let's stick with it…", time: "9:42 AM", unread: 0),
  "2": ChatPreview(preview: "Perfect. See you at 7AM sharp. 🔥", time: "Yesterday", unread: 1),
  "3": ChatPreview(preview: "Don't forget to stretch after every session.", time: "Mon", unread: 0),
  "4": ChatPreview(preview: "Aim for an extra 30g of protein daily. Greek yogurt…", time: "10:07 AM", unread: 2),
};

final Map<String, List<Message>> INITIAL_MESSAGES = {
  "1": [
    const Message(id: 1, sender: "coach", text: "Hey Alex! How did your morning workout go?", time: "9:30 AM"),
    const Message(id: 2, sender: "user", text: "It was great! Completed all the sets you recommended.", time: "9:32 AM"),
    const Message(id: 3, sender: "coach", text: "Excellent! How are you feeling about the weight progression?", time: "9:33 AM"),
    const Message(id: 4, sender: "user", text: "Feeling good, though the last set was challenging.", time: "9:35 AM"),
    const Message(id: 5, sender: "coach", text: "That's perfect! That means you're at the right intensity. Keep it up and we'll increase the weight next week. 💪", time: "9:36 AM"),
    const Message(id: 6, sender: "user", text: "Sounds good! Should I adjust my diet plan?", time: "9:40 AM"),
    const Message(id: 7, sender: "coach", text: "Your current meal plan is working well. Let's stick with it for another 2 weeks, then reassess based on your next InBody scan.", time: "9:42 AM"),
  ],
  "2": [
    const Message(id: 1, sender: "coach", text: "Ready for tomorrow's HIIT session? We're going full intensity!", time: "Yesterday"),
    const Message(id: 2, sender: "user", text: "Absolutely! I've been resting well.", time: "Yesterday"),
    const Message(id: 3, sender: "coach", text: "Perfect. See you at 7AM sharp. 🔥", time: "Yesterday"),
  ],
  "3": [
    const Message(id: 1, sender: "coach", text: "Don't forget to stretch after every session. Flexibility is key.", time: "Mon"),
    const Message(id: 2, sender: "user", text: "Will do, coach!", time: "Mon"),
  ],
  "4": [
    const Message(id: 1, sender: "coach", text: "Your weekly macros review is ready. Protein is slightly below target.", time: "10:00 AM"),
    const Message(id: 2, sender: "user", text: "How much should I increase it?", time: "10:05 AM"),
    const Message(id: 3, sender: "coach", text: "Aim for an extra 30g of protein daily. Greek yogurt or a shake post-workout should do it.", time: "10:07 AM"),
  ],
};

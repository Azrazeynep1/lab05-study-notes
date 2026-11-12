
import 'package:firebase_messaging/firebase_messaging.dart';

/// Part 6: push notifications with Firebase Cloud Messaging (FCM).
class MessagingService {
  MessagingService(this._messaging);

  final FirebaseMessaging _messaging;

  static const topic = 'comp205';

  Future<String?> init() async {
    final settings = await _messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }

    final token = await _messaging.getToken();

    await _messaging.subscribeToTopic(topic);

    return token;
  }

  void listenInForeground(void Function(String title, String body) show) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'New message';
      final body = message.notification?.body ?? '';

      show(title, body);
    });
  }
}

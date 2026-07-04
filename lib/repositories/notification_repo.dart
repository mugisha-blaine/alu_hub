import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification.dart';

class NotificationRepository {
  final FirebaseFirestore firestore;

  NotificationRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get notificationsCollection {
    return firestore.collection('notifications');
  }

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return notificationsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .map(NotificationModel.fromFirestore)
              .toList();

          notifications.sort((first, second) {
            final firstDate = first.createdAt ?? DateTime(2000);

            final secondDate = second.createdAt ?? DateTime(2000);

            return secondDate.compareTo(firstDate);
          });

          return notifications;
        });
  }

  void markAsRead(String notificationId) {
    notificationsCollection
        .doc(notificationId)
        .update({'isRead': true, 'updatedAt': FieldValue.serverTimestamp()})
        .catchError((error) {
          print('Unable to mark notification as read: $error');
        });
  }

  void markAllAsRead(String userId) {
    notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get()
        .then((snapshot) {
          if (snapshot.docs.isEmpty) {
            print('There are no unread notifications.');
          } else {
            final batch = firestore.batch();

            for (final document in snapshot.docs) {
              batch.update(document.reference, {
                'isRead': true,
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }

            batch
                .commit()
                .then((_) {
                  print('All notifications marked as read.');
                })
                .catchError((error) {
                  print('Unable to mark notifications as read: $error');
                });
          }
        })
        .catchError((error) {
          print('Unable to load notifications: $error');
        });
  }

  void deleteNotification(String notificationId) {
    notificationsCollection.doc(notificationId).delete().catchError((error) {
      print('Unable to delete notification: $error');
    });
  }
}

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:license_alert/models/user_data.dart';

class NotificationService {
  // Initialize and request permission
  static Future<void> initializeNotifications() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  // Manual Notification for PUC
  static Future<void> sendPUCNotification({
    required String expiryDate,
    required String certificateNumber,
  }) async {
    await initializeNotifications();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1000,
        channelKey: 'puc_expiry_channel',
        title: '⚠️ PUC Expiring Soon!',
        body: 'Your PUC certificate ($certificateNumber) is expiring on $expiryDate. Renew it ASAP!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  // Manual Notification for License
  static Future<void> sendLicenseNotification({
    required String expiryDate,
    required String dlNo,
  }) async {
    await initializeNotifications();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2000,
        channelKey: 'license_expiry_channel',
        title: '⚠️ License Expiring Soon!',
        body: 'Your Driving License ($dlNo) is expiring on $expiryDate. Renew it ASAP!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  // Scheduled Notifications for PUC
  static Future<void> schedulePUCNotifications({
    required String expiryDate,
    required String certificateNumber,
  }) async {
    await initializeNotifications();
    DateTime expiry = DateTime.parse(expiryDate);
    List<int> daysBefore = [3, 2, 0];

    for (int days in daysBefore) {
      DateTime scheduledDate = expiry.subtract(Duration(days: days));
      scheduledDate = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day, 9, 0, 0);

      if (scheduledDate.isBefore(DateTime.now())) continue;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1001 + days,
          channelKey: 'puc_expiry_channel',
          title: '⚠️ PUC Expiring Soon!',
          body: 'Your PUC certificate ($certificateNumber) is expiring on $expiryDate. Renew it ASAP!',
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          year: scheduledDate.year,
          month: scheduledDate.month,
          day: scheduledDate.day,
          hour: scheduledDate.hour,
          minute: scheduledDate.minute,
          second: 0,
          preciseAlarm: true,
          allowWhileIdle: true,
          repeats: false,
        ),
      );
    }
  }

  // Scheduled Notifications for License
  static Future<void> scheduleLicenseNotifications({
    required String expiryDate,
    required String dlNo,
  }) async {
    await initializeNotifications();
    DateTime expiry = DateTime.parse(expiryDate);
    List<int> daysBefore = [3, 2, 0];

    for (int days in daysBefore) {
      DateTime scheduledDate = expiry.subtract(Duration(days: days));
      scheduledDate = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day, 9, 0, 0);

      if (scheduledDate.isBefore(DateTime.now())) continue;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 2001 + days,
          channelKey: 'license_expiry_channel',
          title: '⚠️ License Expiring Soon!',
          body: 'Your Driving License ($dlNo) is expiring on $expiryDate. Renew it ASAP!',
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          year: scheduledDate.year,
          month: scheduledDate.month,
          day: scheduledDate.day,
          hour: scheduledDate.hour,
          minute: scheduledDate.minute,
          second: 0,
          preciseAlarm: true,
          allowWhileIdle: true,
          repeats: false,
        ),
      );
    }
  }

  // General function to schedule both notifications
  static Future<void> scheduleNotifications(UserLicenseData userData) async {
    await initializeNotifications();
    if (userData.pUC != null) {
      sendPUCNotification(
        expiryDate: userData.pUC!.dateOfExpiry.toString(),
        certificateNumber: userData.pUC!.certificateNumber.toString(),
      );
      schedulePUCNotifications(
        expiryDate: userData.pUC!.dateOfExpiry.toString(),
        certificateNumber: userData.pUC!.certificateNumber.toString(),
      );
    }
    if (userData.licenseDetails != null) {
      sendLicenseNotification(
        expiryDate: userData.licenseDetails!.dOE.toString(),
        dlNo: userData.licenseDetails!.dLNO.toString(),
      );
      scheduleLicenseNotifications(
        expiryDate: userData.licenseDetails!.dOE.toString(),
        dlNo: userData.licenseDetails!.dLNO.toString(),
      );
    }
  }
}

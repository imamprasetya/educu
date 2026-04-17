import 'package:educu_project/config/config.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void setupOneSignal() {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize(AppConfig.appIdOneSignal);
  // if (UserDataService.idUser != null) {
  //   setOneSignalExternalId(UserDataService.idUser.toString());
  // }

  // Meminta izin notifikasi (untuk iOS)
  OneSignal.Notifications.requestPermission(true);

  // Tangani notifikasi saat diklik
  OneSignal.Notifications.addClickListener((event) {
    Map<String, dynamic> additionalData =
        event.notification.additionalData ?? {};

    // if (additionalData.containsKey('type')) {
    //   String type = additionalData['type'];
    //   String? idString = additionalData['id'];
    //   int? id = idString != null ? int.tryParse(idString) : null;

    //   if (id != null) {
    //     navigateToScreen(type, id);
    //   }
    // }
  });
}

//push notifikasi dari server

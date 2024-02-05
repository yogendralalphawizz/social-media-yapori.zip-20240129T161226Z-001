import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foap/screens/add_on/controller/reel/create_reel_controller.dart';
import 'package:foap/screens/add_on/controller/reel/reels_controller.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/login_sign_up/splash_screen.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/util/constant_util.dart';
import 'package:foap/util/shared_prefs.dart';
import 'package:get/get.dart';
import 'package:giphy_get/l10n.dart';
import 'package:camera/camera.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';
import 'apiHandler/api_controller.dart';
import 'components/post_card_controller.dart';
import 'controllers/add_post_controller.dart';
import 'controllers/agora_call_controller.dart';
import 'controllers/agora_live_controller.dart';
import 'controllers/chat_and_call/chat_detail_controller.dart';
import 'controllers/chat_and_call/chat_history_controller.dart';
import 'controllers/chat_and_call/chat_room_detail_controller.dart';
import 'controllers/chat_and_call/select_user_group_chat_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/live_tv_streaming_controller.dart';
import 'controllers/login_controller.dart';
import 'controllers/post_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/subscription_packages_controller.dart';
import 'helper/languages.dart';
import 'manager/db_manager.dart';
import 'manager/notification_manager.dart';
import 'manager/player_manager.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

late List<CameraDescription> cameras;

// String? version;
// List<String> testDeviceIds = ['C680A0F65D21EEEABED160DCE9F066A2'];
locationPermission() async {
  await Permission.location.isDenied.then((value) {
    if (value) {
      Permission.location.request();
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  Wakelock.enable();
  await Firebase.initializeApp();
  // await EasyLocalization.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true,
      // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );
  // await CustomGalleryPermissions.requestPermissionExtend();
  // PackageInfo packageInfo = await PackageInfo.fromPlatform();
  // version = packageInfo.version;
  // MobileAds.instance.initialize();

  // thing to add
  // RequestConfiguration configuration =
  // RequestConfiguration(testDeviceIds: testDeviceIds);
  // MobileAds.instance.updateRequestConfiguration(configuration);
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  locationPermission();
  final firebaseMessaging = FCM();
  await firebaseMessaging.setNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String? token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
  print('this is token $token');
  if (token != null) {
    SharedPrefs().setVoipToken(token);
  }

  AutoOrientation.portraitAutoMode();

  isDarkMode = await SharedPrefs().isDarkMode();
  Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);

  Get.put(DashboardController());
  Get.put(UserProfileManager());
  Get.put(PlayerManager());
  Get.put(SettingsController());
  Get.put(SubscriptionPackageController());
  Get.put(AgoraCallController());
  Get.put(AgoraLiveController());
  Get.put(LoginController());
  Get.put(HomeController());
  Get.put(PostController());
  Get.put(PostCardController());
  Get.put(AddPostController());
  Get.put(ChatDetailController());
  Get.put(ProfileController());
  Get.put(ChatHistoryController());
  Get.put(ChatRoomDetailController());
  Get.put(TvStreamingController());
  Get.put(ReelsController());
  Get.put(CreateReelController());
  Get.put(SelectUserForGroupChatController());

  setupServiceLocator();
  final UserProfileManager userProfileManager = Get.find();

  await userProfileManager.refreshProfile();

  final SettingsController settingsController = Get.find();
  await settingsController.getSettings();

  NotificationManager().initialize();

  await getIt<DBManager>().createDatabase();

  if (userProfileManager.isLogin == true) {
    ApiController().updateTokens();
  }

  AwesomeNotifications().initialize(
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelGroupKey: 'Calls',
          channelKey: 'calls',
          soundSource: 'resource://raw/notisound',
          channelName: 'Calls',
          channelDescription: 'Notification channel for calls',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          locked: true,
          // soundSource:  'resource://raw/notification_tone.mpeg',
          enableVibration: true,
          playSound: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'calls', channelGroupName: 'Calls'),
      ],
      debug: true);

  runApp(Phoenix(child: const SocialifiedApp()));
}

class SocialifiedApp extends StatefulWidget {
  const SocialifiedApp({Key? key}) : super(key: key);

  @override
  State<SocialifiedApp> createState() => _SocialifiedAppState();
}

class _SocialifiedAppState extends State<SocialifiedApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
        child: FutureBuilder<String>(
            future: SharedPrefs().getLanguage(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return GetMaterialApp(
                  translations: Languages(),
                  locale: Locale(snapshot.data!),
                  fallbackLocale: const Locale('en', 'US'),
                  debugShowCheckedModeBanner: false,
                  // navigatorKey: navigationKey,
                  home: const SplashScreen(),
                  builder: EasyLoading.init(),
                  // theme: AppTheme.lightTheme,
                  // darkTheme: AppTheme.darkTheme,
                  themeMode: ThemeMode.light,
                  // localizationsDelegates: context.localizationDelegates,
                  localizationsDelegates: [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    // GlobalCupertinoLocalizations.delegate,
                    // Add this line
                    GiphyGetUILocalizations.delegate,
                  ],
                  supportedLocales: const <Locale>[
                    Locale('hi', 'IN'),
                    Locale('en', 'US'),
                    Locale('ar', 'SA'),
                    Locale('tr', 'TR'),
                    Locale('ru', 'RU'),
                    Locale('es', 'ES'),
                    Locale('fr', 'FR'),
                    Locale('pt', 'PT'),
                    Locale('th', 'TH'),
                    Locale('de', 'DE'),
                    Locale('ja', 'JR'),
                    Locale('bn', 'IN'),
                    Locale('it', 'IT'),
                    Locale('ko', 'KR'),
                    Locale('id', 'ID')
                  ],
                );
              } else {
                return Container();
              }
            }));
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  print('Notification Message: ${message.data}');
  NotificationManager().parseNotificationMessage(message);
}
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   // await Firebase.initializeApp();
//
//   NotificationManager().parseNotificationMessage(message);
// }

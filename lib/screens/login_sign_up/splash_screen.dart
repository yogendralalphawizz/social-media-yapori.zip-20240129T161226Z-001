import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/manager/notification_manager.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';

import '../dashboard/loading.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late bool haveBiometricLogin = false;
  var localAuth = LocalAuthentication();
  final SettingsController settingsController = Get.find();
  RxInt bioMetricType = 0.obs;
  List<String> bgImages = [
    'assets/tutorial1.jpg',
    'assets/tutorial2.jpg',
    'assets/tutorial3.jpg',
    'assets/tutorial4.jpg'
  ];

  String countryName = '', cityName = '';
  Future getCurrentCountry() async {
    await Permission.location.isDenied.then((value) {
      if (value) {
        Permission.location.request();
      }
    });
    // try {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      countryName = placemarks[0].country!;
      cityName = placemarks[0].locality!;

      // return countryName;
      print('this is my current country $countryName');
    } else {
      return 'Country not found';
    }
    // } catch (e) {
    //   return 'Error: $e';
    // }
  }

  @override
  void initState() {
    super.initState();
    getCurrentCountry();
    // settingsController.setDarkMode(true);
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAll(() => const LoadingScreen());
    });
    // NotificationService.initialize();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationManager().parseNotificationMessage(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         backgroundColor: AppColorConstants.backgroundColor,
         // themeColor.lighten().withOpacity(0.2),
        body:   Center(
          child:  Image.asset(
            'assets/applogo.png',
            height: MediaQuery.of(context).size.width/1.2,
            width: MediaQuery.of(context).size.width/1.2,
          ),
        ),

        // Stack(
        //   children: [
        //     CarouselSlider(
        //       items: [
        //         for (String image in bgImages)
        //           Image.asset(
        //             image,
        //             fit: BoxFit.cover,
        //             height: double.infinity,
        //             width: double.infinity,
        //           )
        //       ],
        //       options: CarouselOptions(
        //         autoPlayInterval: const Duration(seconds: 1),
        //         autoPlay: true,
        //         enlargeCenterPage: false,
        //         enableInfiniteScroll: true,
        //         height: double.infinity,
        //         viewportFraction: 1,
        //         onPageChanged: (index, reason) {},
        //       ),
        //     ),
        //     Container(
        //       height: double.infinity,
        //       width: double.infinity,
        //       decoration: BoxDecoration(
        //         gradient: LinearGradient(
        //           begin: Alignment.topRight,
        //           end: Alignment.bottomLeft,
        //           stops: const [
        //             0.1,
        //             0.3,
        //             0.6,
        //             0.9,
        //           ],
        //           colors: [
        //             AppColorConstants.backgroundColor.withOpacity(0.9),
        //             AppColorConstants.backgroundColor
        //                 .lighten()
        //                 .withOpacity(0.9),
        //             AppColorConstants.backgroundColor
        //                 .lighten()
        //                 .withOpacity(0.5),
        //             AppColorConstants.themeColor.withOpacity(0.5),
        //           ],
        //         ),
        //       ),
        //     ),
        //     Center(
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         children: [
        //           Image.asset(
        //             'assets/spash_logo.png',
        //             height: 150,
        //             width: 150,
        //           ),
        //           const SizedBox(
        //             height: 10,
        //           ),
        //           BodyLargeText(
        //             AppConfigConstants.appName,
        //               weight: TextWeight.medium
        //           ),
        //           Heading6Text(
        //             AppConfigConstants.appTagline.tr,
        //           ),
        //         ],
        //       ).bp(200),
        //     ),
        //   ],
        // )
    );
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foap/controllers/profile_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/ui/reel/create_reel_video.dart';
import 'package:foap/screens/add_on/ui/reel/scene_screen.dart';
import 'package:foap/screens/club/clubs_listing.dart';
import 'package:foap/screens/dashboard/clips_screen.dart';
import 'package:foap/screens/live/checking_feasibility.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../components/force_update_view.dart';
import '../chat/chat_history.dart';
import '../home_feed/home_feed_screen.dart';
import '../settings_menu/settings_controller.dart';

class DashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxInt unreadMsgCount = 0.obs;
  RxBool isLoading = false.obs;

  // getSettings() {
  //  isLoading.value = true;
  //   ApiController().getSettings().then((response) {
  //     isLoading.value = false;
  //
  //     setting.value = response.settings;
  //
  //     if (setting.value?.latestVersion! != AppConfigConstants.currentVersion) {
  //       forceUpdate.value = true;
  //     }
  //   });
  // }

  indexChanged(int index) {
    currentIndex.value = index;
  }

  updateUnreadMessageCount(int count) {
    unreadMsgCount.value = count;
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<DashboardScreen> {
  final DashboardController _dashboardController = Get.find();
  final SettingsController _settingsController = Get.find();
  final ProfileController profileController = Get.find();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  List<Widget> items = [];
  final picker = ImagePicker();
  bool hasPermission = false;


  String? countryName, cityName;

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
      countryName = placemarks[0].country;
      cityName = placemarks[0].locality;
      updateLocation(context);

      // return countryName;
    } else {
      return 'Country not found';
    }
    // } catch (e) {
    //   return 'Error: $e';
    // }
  }
  updateLocation(BuildContext context) {
    profileController.updateLocation(
        country: countryName.toString() ?? '', city: cityName.toString() ?? '', context: context,isSignup: false);
  }

  @override
  void initState() {
    items = [
      const HomeFeedScreen(),
      const SceneScreen(),
      const ClipsScreen(),
      // const MyProfile(
      //   showBack: false,
      // ),
      const ClubsListing(),
      const ChatHistory(),
      const CheckingLiveFeasibility()
      // const Settings()
    ];



    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settingsController.getSettings();
    });
    // getCurrentCountry();
  }

  DateTime timeBackPressed = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
        onWillPop: () async {
      final difference = DateTime.now().difference(timeBackPressed);
      final isExit = difference >= Duration(seconds: 2);
      timeBackPressed = DateTime.now();

      if (isExit) {
        Fluttertoast.showToast(msg: 'Exit App');

        return false;
      } else {
        Fluttertoast.cancel();
        return true;
      }
    },

     child:  Obx(() => _dashboardController.isLoading.value == true
        ? SizedBox(
            height: Get.height,
            width: Get.width,
            child: const Center(child: CircularProgressIndicator()),
          )
    ///THIS WAS TRUE _settingsController.forceUpdate.value == true
        : _settingsController.forceUpdate.value == false
            ? ForceUpdateView()
            : _settingsController.appearanceChanged?.value == null
                ? Container()
                : Scaffold(
                    backgroundColor: AppColorConstants.backgroundColor,
                    body: items[_dashboardController.currentIndex.value],
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerDocked,
                    // floatingActionButton: Container(
                    //   height: 50,
                    //   width: 50,
                    //   color: AppColorConstants.themeColor,
                    //   child: const ThemeIconWidget(
                    //     ThemeIcon.videoCamera,
                    //     size: 28,
                    //     color: Colors.white,
                    //   ),
                    // ).round(20).tP16.ripple(() => {onTabTapped(2)}),
                    bottomNavigationBar: SizedBox(
                      height: MediaQuery.of(context).viewPadding.bottom > 0
                          ? 100
                          : 80.0,
                      width: MediaQuery.of(context).size.width,
                      child: BottomNavigationBar(
                        backgroundColor: AppColorConstants.backgroundColor,
                        type: BottomNavigationBarType.fixed,
                        currentIndex: _dashboardController.currentIndex.value,
                        selectedFontSize: 12,
                        unselectedFontSize: 12,
                        unselectedItemColor: Colors.grey,
                        selectedItemColor: AppColorConstants.themeColor,
                        onTap: (index) => {onTabTapped(index)},
                        items: [
                          BottomNavigationBarItem(
                              icon: Image.asset(
                                      _dashboardController.currentIndex.value ==
                                              0
                                          ? 'assets/home_selected.png'
                                          : 'assets/home.png',
                                      height: 20,
                                      width: 20,
                                      color: _dashboardController
                                                  .currentIndex.value ==
                                              0
                                          ? AppColorConstants.themeColor
                                          : AppColorConstants.iconColor)
                                  .bP8,
                              label: LocalizationString.home),
                          BottomNavigationBarItem(
                            icon: Obx(() => Stack(
                                  children: [
                                    Image.asset(
                                            _dashboardController
                                                        .currentIndex.value ==
                                                    1
                                                ? 'assets/scene_selected.png'
                                                : 'assets/scene.png',
                                            height: 20,
                                            width: 20,
                                            color: _dashboardController
                                                        .currentIndex.value ==
                                                    1
                                                ? AppColorConstants.themeColor
                                                : AppColorConstants.iconColor)
                                        .bP8,
                                    if (_dashboardController
                                            .unreadMsgCount.value >
                                        0)
                                      Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            height: 12,
                                            width: 12,
                                            color: AppColorConstants.themeColor,
                                          ).circular)
                                  ],
                                )),
                            label: LocalizationString.scene,
                          ),
                          BottomNavigationBarItem(
                              icon: Image.asset(
                                  _dashboardController.currentIndex.value ==
                                      2
                                      ? 'assets/clip_selected.png'
                                      : 'assets/clips.png',
                                  height: 20,
                                  width: 20,
                                  color: _dashboardController
                                      .currentIndex.value ==
                                      2
                                      ? AppColorConstants.themeColor
                                      : AppColorConstants.iconColor)
                                  .bP8,
                              label: LocalizationString.clips),
                          BottomNavigationBarItem(
                            icon: Obx(() => Stack(
                              children: [
                                Image.asset(
                                    _dashboardController
                                        .currentIndex.value ==
                                        3
                                        ? 'assets/clubs.png'
                                        : 'assets/clubs.png',
                                    height: 20,
                                    width: 20,
                                    color: _dashboardController
                                        .currentIndex.value ==
                                        3
                                        ? AppColorConstants.themeColor
                                        : AppColorConstants.iconColor)
                                    .bP8,
                                if (_dashboardController
                                    .unreadMsgCount.value >
                                    0)
                                  Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        height: 12,
                                        width: 12,
                                        color: AppColorConstants.themeColor,
                                      ).circular)
                              ],
                            )),
                            label: LocalizationString.clubs,
                          ),
                          // const BottomNavigationBarItem(
                          //   icon: SizedBox(
                          //     height: 30,
                          //     width: 30,
                          //   ),
                          //   label: '',
                          // ),
                          BottomNavigationBarItem(
                            icon: Image.asset(
                                    _dashboardController.currentIndex.value == 4
                                        ? 'assets/chat_selected.png'
                                        : 'assets/chats.png',
                                    height: 20,
                                    width: 20,
                                    color: _dashboardController
                                                .currentIndex.value ==
                                            4
                                        ? AppColorConstants.themeColor
                                        : AppColorConstants.iconColor)
                                .bP8,
                            label: LocalizationString.chat,
                          ),
                          if(_settingsController.setting.value!.enableLive)
                          BottomNavigationBarItem(
                            icon: Image.asset(
                                    _dashboardController.currentIndex.value == 5
                                        ? 'assets/live_bw.png'
                                    :'assets/live_bw.png',
                                    //'assets/more_selected.png'
                                        //: 'assets/more.png',
                                    height: 20,
                                    width: 20,
                                    color: _dashboardController
                                                .currentIndex.value ==
                                            5
                                        ? AppColorConstants.themeColor
                                        : AppColorConstants.iconColor)
                                .bP8,
                            label: LocalizationString.live,
                          )
                        ],
                      ),
                    )))) ;
  }

  void onTabTapped(int index) async {
    Future.delayed(
        Duration.zero, () => _dashboardController.indexChanged(index));
  }
}

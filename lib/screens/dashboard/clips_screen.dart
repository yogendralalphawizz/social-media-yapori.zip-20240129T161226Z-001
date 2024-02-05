import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/components/reel/reel_video_player.dart';
import 'package:foap/screens/add_on/controller/reel/reels_controller.dart';
import 'package:foap/screens/post/select_media.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/reel_imports.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ClipsScreen extends StatefulWidget {
  const ClipsScreen({Key? key}) : super(key: key);

  @override
  State<ClipsScreen> createState() => _ClipsScreenState();
}

class _ClipsScreenState extends State<ClipsScreen> {
  final ReelsController _reelsController = Get.find();
  final SettingsController _settingsController = Get.find();
  ///NATIVE ADS
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  @override
  void initState() {
    super.initState();
    _reelsController.getReels();
    _nativeAd = NativeAd(
      adUnitId: _settingsController.setting.value!.interstitialAdUnitIdForAndroid!,
      //'ca-app-pub-3940256099942544/1044960115',
      //'ca-app-pub-3940256099942544/6300978111',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('$NativeAd loaded.');
          setState(() {
            _nativeAdIsLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$NativeAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white12,
        callToActionTextStyle: NativeTemplateTextStyle(
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black38,
          backgroundColor: Colors.white70,
        ),
      ),
    );
    _nativeAd!.load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          floatingActionButton: Container(
            height: 50,
            width: 50,
            color: AppColorConstants.themeColor.withOpacity(0.7),
            child: ThemeIconWidget(
              ThemeIcon.edit,
              color: AppColorConstants.whiteClr,
              size: 25,
            ),
          ).circular.ripple(() {
            Future.delayed(
              Duration.zero,
              () => showGeneralDialog(
                  context: context,
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SelectMedia(
                        mediaType: PostMediaType.video,
                        isClips: true,
                      )),
            );
            // Get.to(() => const CreateReelScreen(
            //       isScene: false,
            //     ));
            // Future.delayed(
            //   Duration.zero,
            //       () => showGeneralDialog(
            //       context: context,
            //       pageBuilder: (context, animation, secondaryAnimation) =>
            //       const SelectMedia()),
            // );
          }),
          body: Stack(
            children: [
              GetBuilder<ReelsController>(
                  init: _reelsController,
                  builder: (ctx) {
                    return PageView(
                        scrollDirection: Axis.vertical,
                        allowImplicitScrolling: true,
                        onPageChanged: (index) {
                          _reelsController.currentPageChanged(
                              index, _reelsController.publicMoments[index]);
                        },
                        children: [
                          for (int i = 0;
                              i < _reelsController.publicMoments.length;
                              i++)
                            SizedBox(
                              height:
                              // MediaQuery.of(context).size.height,
                              Get.height,
                              width: Get.width,
                              // color: Colors.brown,
                              child: ReelVideoPlayer(
                                reel: _reelsController.publicMoments[i],
                                // play: false,
                              ),
                            ),
                        ]);
                  }),

              ///CAMERA ICON
              // Positioned(
              //     right: 16,
              //     top: 50,
              //     child: ThemeIconWidget(
              //       ThemeIcon.camera,
              //       color: AppColorConstants.whiteClr,
              //     ).ripple(() {
              //       Get.to(() => const CreateReelScreen(
              //             isScene: false,
              //           ));
              //     }))
              ///CAMERA ICON
            ],
          )),
    );
  }
}

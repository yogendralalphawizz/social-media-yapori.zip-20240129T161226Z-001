import 'package:foap/controllers/profile_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/post_ads_model.dart';
import 'package:foap/screens/home_feed/quick_links.dart';
import 'package:foap/screens/picked_video_editor.dart';
import 'package:foap/screens/profile/my_profile.dart';
import 'package:foap/screens/settings_menu/notifications.dart';
import 'package:foap/screens/settings_menu/settings.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_polls/flutter_polls.dart';

import '../../components/post_card.dart';
import '../../controllers/add_post_controller.dart';
import '../../controllers/agora_live_controller.dart';
import '../../controllers/home_controller.dart';
import '../../model/call_model.dart';
import '../../model/post_model.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../../util/shared_prefs.dart';
import '../dashboard/explore.dart';
import '../post/select_media.dart';
import '../post/view_post_insight.dart';
import '../settings_menu/settings_controller.dart';
import '../story/choose_media_for_story.dart';
import '../story/story_updates_bar.dart';
import '../story/story_viewer.dart';
import 'map_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  HomeFeedState createState() => HomeFeedState();
}

class HomeFeedState extends State<HomeFeedScreen> {
  final HomeController _homeController = Get.find();
  final AddPostController _addPostController = Get.find();
  final AgoraLiveController _agoraLiveController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final SettingsController _settingsController = Get.find();
  final ProfileController _profileController = Get.find();

  final _controller = ScrollController();

  String? selectedValue;
  int pollFrequencyIndex = 10;

  ///NATIVE ADS
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;



  @override
  void initState() {
    super.initState();
    _nativeAd = NativeAd(
      adUnitId: _settingsController.setting.value!.interstitialAdUnitIdForAndroid!,
      // 'ca-app-pub-3940256099942544/1044960115',
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData(isRecent: true);

      _homeController.loadQuickLinksAccordingToSettings();
    });

    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
        } else {
          loadData(isRecent: false);
        }
      }
    });
    // loadData(isRecent: false);
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Create the ad objects and load ads.
  //   _nativeAd = NativeAd(
  //     adUnitId: 'ca-app-pub-3940256099942544/6300978111',
  //     request: AdRequest(),
  //     listener: NativeAdListener(
  //       onAdLoaded: (Ad ad) {
  //         print('$NativeAd loaded.');
  //         setState(() {
  //           _nativeAdIsLoaded = true;
  //         });
  //       },
  //       onAdFailedToLoad: (Ad ad, LoadAdError error) {
  //         print('$NativeAd failedToLoad: $error');
  //         ad.dispose();
  //       },
  //       onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
  //       onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
  //     ),
  //     nativeTemplateStyle: NativeTemplateStyle(
  //       templateType: TemplateType.medium,
  //       mainBackgroundColor: Colors.white12,
  //       callToActionTextStyle: NativeTemplateTextStyle(
  //         size: 16.0,
  //       ),
  //       primaryTextStyle: NativeTemplateTextStyle(
  //         textColor: Colors.black38,
  //         backgroundColor: Colors.white70,
  //       ),
  //     ),
  //   );
  //   _nativeAd!.load();
  // }


  loadMore({required bool? isRecent}) {
    loadPosts(isRecent);
  }

  refreshData() async{
    _homeController.posts.refresh();
    _homeController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData(isRecent: true);

      // _homeController.loadQuickLinksAccordingToSettings();
    });
    // loadData(isRecent: true);
    // loadMore(isRecent: true);
    // _homeController.removePostFromList(model);

  }



  loadPosts(bool? isRecent) {
    _homeController.getPosts(
        isRecent: isRecent,
        callback: () {
          _refreshController.refreshCompleted();
        });
  }

  void loadData({required bool? isRecent}) {
    loadPosts(isRecent);
    _homeController.getStories();
    _profileController.getMyProfile();
  }

  @override
  void didUpdateWidget(covariant HomeFeedScreen oldWidget) {
    loadData(isRecent: false);
    final initFuture = MobileAds.instance.initialize();
    // final adState = AdState(initFuture);
    // adState.initialisation.then((status) {
      setState(() {
        _nativeAd = NativeAd(
          adUnitId: 'ca-app-pub-3940256099942544/6300978111',
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
      // });
    });
    super.didUpdateWidget(oldWidget);
  }



  @override
  Widget build(BuildContext context) {
    return Obx(() =>
      Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        floatingActionButton: Container(
          height: 50,
          width: 50,
          color: AppColorConstants.themeColor.withOpacity(0.7),
          child:  ThemeIconWidget(
            ThemeIcon.edit,
            color: AppColorConstants.whiteClr,
            size: 25,
          ),
        ).circular.ripple(() {
          print("floatingActionButton pressed");
          // Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoFilterScreen()));
          Future.delayed(
            Duration.zero,
            () => showGeneralDialog(
                context: context,
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SelectMedia(
                      isClips: false,
                    )),
          );
        }),
        // appBar: AppBar(
        //   backgroundColor: AppColorConstants.backgroundColor,
        //   leading: Container(
        //       // height: 60,
        //       // width: 60,
        //       child: Image.asset('assets/applogo.png')),
        //   title: Padding(
        //     padding: const EdgeInsets.only(right: 10.0),
        //     child: Heading4Text(
        //       AppConfigConstants.appName,
        //       weight: TextWeight.bold,
        //       color: AppColorConstants.themeColor,
        //     ),
        //   ),
        //     actions: [
        //        ThemeIconWidget(
        //         ThemeIcon.search,
        //         color: AppColorConstants.themeColor,
        //         size: 25,
        //       ).ripple(() {
        //         Get.to(() => const Explore());
        //       }),
        //
        //       Padding(
        //         padding: const EdgeInsets.only(left: 8.0, right: 8),
        //         child:  ThemeIconWidget(
        //           ThemeIcon.notification,
        //           color: AppColorConstants.themeColor,
        //           size: 25,
        //         ).ripple(() {
        //      //   Get.to(() => const Explore());
        //         }),
        //       ),
        //        ThemeIconWidget(
        //         ThemeIcon.name,
        //         color: AppColorConstants.themeColor,
        //         size: 25,
        //       ).ripple(() {
        //         Get.to(() =>  const MyProfile(
        //               showBack: true,
        //         ),);
        //       }),
        //       const SizedBox(width: 8,),
        //       Obx(() => Container(
        //         color: AppColorConstants.backgroundColor,
        //         height: 25,
        //         width: 25,
        //         child: ThemeIconWidget(
        //           _homeController.openQuickLinks.value == true
        //               ? ThemeIcon.close
        //               : ThemeIcon.menuIcon,
        //           color: AppColorConstants.themeColor,
        //           size: 25,
        //         ),
        //       ).ripple(() {
        //         // Get.to(() => const Settings());
        //
        //         _homeController.quickLinkSwitchToggle();
        //       })),
        //       const SizedBox(width: 7,)
        //     ],
        // ),
        body: SafeArea(
          top: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_settingsController.appearanceChanged!.value) Container(),
              Container(
                decoration: BoxDecoration(
                  color: AppColorConstants.backgroundColor,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.black54,
                          blurRadius: 15.0,
                          offset: Offset(0.0, 0.75)
                      )
                    ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/applogo.jpeg', height: 80, width: 150,),
                    Row(children: [
                      ThemeIconWidget(
                        ThemeIcon.search,
                        color: AppColorConstants.themeColor,
                        size: 25,
                      ).ripple(() {
                        // Get.to(() =>  MainScreen());

                        Get.to(() => const Explore());
                      }),

                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
                        child:  ThemeIconWidget(
                          ThemeIcon.notification,
                          color: AppColorConstants.themeColor,
                          size: 25,
                        ).ripple(() {
                          Get.to(() => const NotificationsScreen());
                          //   Get.to(() => const Explore());
                        }),
                      ),
                      ThemeIconWidget(
                        ThemeIcon.name,
                        color: AppColorConstants.themeColor,
                        size: 25,
                      ).ripple(() {
                        Get.to(() =>  const MyProfile(
                          showBack: true,
                        ),);
                      }),
                      const SizedBox(width: 8,),
                      Obx(() => Container(
                        color: AppColorConstants.backgroundColor,
                        height: 25,
                        width: 25,
                        child: ThemeIconWidget(
                          _homeController.openQuickLinks.value == true
                              ? ThemeIcon.close
                              : ThemeIcon.menuIcon,
                          color: AppColorConstants.themeColor,
                          size: 25,
                        ),
                      ).ripple(() {
                        // Get.to(() => const Settings());

                        _homeController.quickLinkSwitchToggle();
                      })),
                      const SizedBox(width: 7,)
                    ],)
                  ],
                ),
              ),
              menuView(),

              // Row(
              //   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //
              //
              //     const Spacer(),
              //     // const ThemeIconWidget(
              //     //   ThemeIcon.map,
              //     //   // color: ColorConstants.themeColor,
              //     //   size: 25,
              //     // ).ripple(() {
              //     //   Get.to(() => MapsUsersScreen());
              //     // }),
              //     // const SizedBox(
              //     //   width: 20,
              //     // ),
              //     const ThemeIconWidget(
              //       ThemeIcon.search,
              //       size: 25,
              //     ).ripple(() {
              //       Get.to(() => const Explore());
              //     }),
              //
              //     const ThemeIconWidget(
              //       ThemeIcon.notification,
              //       size: 25,
              //     ).ripple(() {
              //       Get.to(() => const Explore());
              //     }),
              //     const ThemeIconWidget(
              //       ThemeIcon.name,
              //       size: 25,
              //     ).ripple(() {
              //       Get.to(() => const Explore());
              //     }),
              //     const SizedBox(
              //       width: 20,
              //     ),
              //     Obx(() => Container(
              //           color: AppColorConstants.backgroundColor,
              //           height: 25,
              //           width: 25,
              //           child: ThemeIconWidget(
              //             _homeController.openQuickLinks.value == true
              //                 ? ThemeIcon.close
              //                 : ThemeIcon.menuIcon,
              //             // color: ColorConstants.themeColor,
              //             size: 25,
              //           ),
              //         ).ripple(() {
              //           _homeController.quickLinkSwitchToggle();
              //         })),
              //   ],
              // ).hp(20),
              // const SizedBox(
              //   height: 10,
              // ),
              Expanded(
                child: postsView(),
              ),
            ],
          ),
        )));
  }

  @override
  void dispose() {
    super.dispose();
    // _ad!.dispose();
    _nativeAd?.dispose();
    _homeController.clear();
    _homeController.closeQuickLinks();
  }

  Widget menuView() {
    return Obx(() => AnimatedContainer(
          height: _homeController.openQuickLinks.value == true ? 100 : 0,
          width: Get.width,
          color: AppColorConstants.themeColor,
          duration: const Duration(milliseconds: 500),
          child: QuickLinkWidget(
              callback: () {
            _homeController.closeQuickLinks();
          }),
        ));
  }

  Widget postingView() {
    return Obx(() => _addPostController.isPosting.value
        ? Container(
            height: 55,
            color: AppColorConstants.cardColor,
            child: Row(
              children: [
                Image.memory(
                  _addPostController.postingMedia.first.thumbnail!,
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                ).round(5),
                const SizedBox(
                  width: 10,
                ),
                Heading5Text(
                  _addPostController.isErrorInPosting.value
                      ? LocalizationString.postFailed
                      : LocalizationString.posting,
                ),
                const Spacer(),
                _addPostController.isErrorInPosting.value
                    ? Row(
                        children: [
                          Heading5Text(
                            LocalizationString.discard,
                            weight: TextWeight.medium,
                          ).ripple(() {
                            _addPostController.discardFailedPost();
                          }),
                          const SizedBox(
                            width: 20,
                          ),
                          Heading5Text(
                            LocalizationString.retry,
                            weight: TextWeight.medium,
                          ).ripple(() {
                            _addPostController.retryPublish(context);
                          }),
                        ],
                      )
                    : Container()
              ],
            ).hP8,
          ).backgroundCard(radius: 10).bp(20)
        : Container());
  }

  Widget storiesView() {
    return SizedBox(
      height: 110,
      child: GetBuilder<HomeController>(
          init: _homeController,
          builder: (ctx) {
            return StoryUpdatesBar(
              stories: _homeController.stories,
              liveUsers: _homeController.liveUsers,
              addStoryCallback: () {
                // Get.to(() => const TextStoryMaker());
                Get.to(() => const ChooseMediaForStory());
              },
              viewStoryCallback: (story) {
                Get.to(() => StoryViewer(
                      story: story,
                      storyDeleted: () {
                        _homeController.getStories();
                      },
                    ));
              },
              joinLiveUserCallback: (user) {
                Live live = Live(
                    channelName: user.liveCallDetail!.channelName,
                    isHosting: false,
                    host: user,
                    token: user.liveCallDetail!.token,
                    liveId: user.liveCallDetail!.id);
                _agoraLiveController.joinAsAudience(
                  live: live,
                );
              },
              user: _profileController.user.value!,
            ).vP16;
          }),
    );
  }

  postsView() {
    return Obx(() {
      return ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _homeController.posts.length + 3,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Obx(() =>
                      _homeController.isRefreshingStories.value == true
                          ? const StoryAndHighlightsShimmer()
                          : storiesView());
                }
                // else if (index == 1) {
                //   return const QuickLinkWidget();
                // }
                else if (index == 1) {
                  return postingView().hP16;
                } else if (index == 2) {
                  return Obx(() => Column(
                        children: [
                          HorizontalMenuBar(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              onSegmentChange: (segment) {
                                _homeController.categoryIndexChanged(
                                    index: segment,
                                    callback: () {
                                      _refreshController.refreshCompleted();
                                    });
                              },
                              selectedIndex:
                                  _homeController.categoryIndex.value,
                              menus: [
                                LocalizationString.all,
                                LocalizationString.following,
                                // LocalizationString.trending,
                                LocalizationString.recent,
                                LocalizationString.your,
                              ]),
                          _homeController.isRefreshingPosts.value == true
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.9,
                                  child: const HomeScreenShimmer())
                              : _homeController.posts.isEmpty
                                  ? SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      child: emptyPost(
                                          title: LocalizationString.noPostFound,
                                          subTitle: LocalizationString
                                              .followFriendsToSeeUpdates),
                                    )
                                  : Container()
                        ],
                      ));
                } else {
                  // final combinedList = combineLists(_homeController.posts, _homeController.adsItem);
                  PostModel model = _homeController.posts[index - 3];
                  return PostCard(
                    model: model,
                    isScene: false,
                      isClub: false,
                    isHome: true,
                    textTapHandler: (text) {
                      _homeController.postTextTapHandler(
                          post: model, text: text);
                    },
                    viewInsightHandler: () {
                      Get.to(() => ViewPostInsights(post: model));
                    },
                    // mediaTapHandler: (post) {
                    //   // Get.to(()=> PostMediaFullScreen(post: post));
                    // },
                    removePostHandler: () {
                      _homeController.removePostFromList(model);
                    },
                    blockUserHandler: () {
                      _homeController.removeUsersAllPostFromList(model);
                    },
                    followButtonHandler:() async {
                      setState(() {

                      });
                    },

                  );
                }
              },
              separatorBuilder: (context, index) {
                if ((index + 1) % 6 == 0 && index != _homeController.posts.length - 1) {
                  return _nativeAd != null && _nativeAdIsLoaded ? Container(
                    height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: AdWidget(ad: _nativeAd!))
                  : const SizedBox.shrink();
                } else {
                  return const SizedBox.shrink(); // No separator
                }

              })
          .addPullToRefresh(
              refreshController: _refreshController,
              enablePullUp: false,
              onRefresh: refreshData,
              onLoading: () {});
    });
  }
}

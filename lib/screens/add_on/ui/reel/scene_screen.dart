import 'package:foap/controllers/home_controller.dart';
import 'package:foap/controllers/profile_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';
import 'package:foap/helper/imports/post_imports.dart';
import 'package:foap/model/call_model.dart';
import 'package:foap/screens/add_on/components/reel/reel_video_player.dart';
import 'package:foap/screens/add_on/controller/reel/reels_controller.dart';
import 'package:foap/screens/post/select_media.dart';
import 'package:foap/screens/post/view_post_insight.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/screens/story/choose_media_for_story.dart';
import 'package:foap/screens/story/story_updates_bar.dart';
import 'package:foap/screens/story/story_viewer.dart';
import 'package:foap/segmentAndMenu/horizontal_menu.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/reel_imports.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'create_reel_video.dart';

class SceneScreen extends StatefulWidget {
  const SceneScreen({Key? key}) : super(key: key);

  @override
  State<SceneScreen> createState() => _SceneScreenState();
}

class _SceneScreenState extends State<SceneScreen> {
  final ReelsController _reelsController = Get.find();
  final HomeController _homeController = Get.find();
  final AddPostController _addPostController = Get.find();
  final AgoraLiveController _agoraLiveController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final _controller = ScrollController();
  final SettingsController _settingsController = Get.find();
  final ProfileController _profileController = Get.find();
  ///BANNER ADS
  BannerAd? _bannerAd;
  bool _bannerReady = false;

  ///NATIVE ADS
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;


  nativeAdWidget(){
    return Container(
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: AdWidget(ad: _nativeAd!, key: UniqueKey()
        ));
  }

  @override
  void initState() {
    super.initState();

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
    _reelsController.getReels();

    _bannerAd = BannerAd(
      adUnitId: _settingsController.setting.value!.bannerAdUnitIdForAndroid!,
      //'ca-app-pub-3940256099942544/6300978111',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print('working');
          setState(() {
            _bannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('error $err');
          setState(() {
            _bannerReady = false;
          });
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();

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
  }



  @override
  void dispose() {
    // TODO: implement dispose
    _homeController.clear();
    _homeController.closeQuickLinks();
    _bannerAd?.dispose();
    super.dispose();
  }

  Widget bannerAd() {
    return _bannerReady
        ? Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(
                ad: _bannerAd!,
              ),
            ),
          )
        : Container();
  }

  postsView() {
    return Obx(() {
      return ListView.separated(
          controller: _controller,
          padding: EdgeInsets.only(bottom: 20, top: _bannerReady ? 0 : 40),
          itemCount: _homeController.posts.length + 3,
          itemBuilder: (context, index) {
            if (index == 0) {
              return
                   const SizedBox.shrink();
                 // bannerAd();
              //   Obx(() =>
              // _homeController.isRefreshingStories.value == true
              //     ? const StoryAndHighlightsShimmer()
              //     : storiesView());
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
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          onSegmentChange: (segment) {
                            _homeController.categoryIndexChanged(
                                index: segment,
                                callback: () {
                                  _refreshController.refreshCompleted();
                                });
                          },
                          selectedIndex: _homeController.categoryIndex.value,
                          menus: [
                            LocalizationString.all,
                            LocalizationString.following,
                            // LocalizationString.trending,
                            LocalizationString.recent,
                            LocalizationString.your,
                          ]),
                      _homeController.isRefreshingPosts.value == true
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: const HomeScreenShimmer())
                          : _homeController.posts.isEmpty
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: emptyPost(
                                      title: LocalizationString.noPostFound,
                                      subTitle: LocalizationString
                                          .followFriendsToSeeUpdates),
                                )
                              : Container()
                    ],
                  ));
            } else {
              PostModel model = _homeController.posts[index - 3];
              return model.gallery.isNotEmpty
                  ? model.gallery.first.isVideoPost == true
                      ? PostCard(
                          model: model,
                          isScene: true,
                          isClub: false,
                          isHome: false,
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
                        )
                      : const SizedBox.shrink()
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: emptyPost(
                          title: LocalizationString.noPostFound,
                          subTitle:
                              LocalizationString.followFriendsToSeeUpdates),
                    );

              // : SizedBox(
              //     height:
              //     MediaQuery.of(context).size.height *
              //         0.5,
              //     child: emptyPost(
              //         title: LocalizationString.noPostFound,
              //         subTitle: LocalizationString
              //             .followFriendsToSeeUpdates),
              //   );
            }
          },
          separatorBuilder: (context, index) {
            if ((index + 1) % 6 == 0 && index != _homeController.posts.length - 1
            && _homeController.posts[index - 3].gallery.first.isVideoPost == true) {
              return
                //Container(height: 20,color: AppColorConstants.themeColor,);
                _nativeAd != null && _nativeAdIsLoaded ?
                SizedBox(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    child: AdWidget(ad: _nativeAd!, key: UniqueKey()
                    ))
                  : const SizedBox.shrink();

            } else {
              return const SizedBox.shrink(); // No separator
            }

              // _nativeAd != null && _nativeAdIsLoaded
              //   ? Container(
              //       height: 300,
              //       width: MediaQuery.of(context).size.width,
              //       child: AdWidget(ad: _nativeAd!))
              //   : const SizedBox.shrink();
          })
      .addPullToRefresh(
      refreshController: _refreshController,
      enablePullUp: false,
      onRefresh: refreshData,
      onLoading: () {});
    });
  }

  Widget postingView() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Obx(() => _addPostController.isPosting.value
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
          : Container()),
    );
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

  refreshData() async {
    _homeController.clear();
    loadData(isRecent: true);
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
  }

  @override
  void didUpdateWidget(covariant SceneScreen oldWidget) {
    loadData(isRecent: false);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        // floatingActionButton: Container(
        //   height: 50,
        //   width: 50,
        //   color: AppColorConstants.themeColor,
        //   child: const ThemeIconWidget(
        //     ThemeIcon.edit,
        //     size: 25,
        //   ),
        // ).circular.ripple(() {
        //   // Get.to(() => const CreateReelScreen(
        //   //   isScene: true,
        //   // ));
        //   Future.delayed(
        //     Duration.zero,
        //         () => showGeneralDialog(
        //         context: context,
        //         pageBuilder: (context, animation, secondaryAnimation) =>
        //         const SelectMedia()),
        //   );
        // }),
        // body: Stack(
        //   alignment: Alignment.topCenter,
        //   children: [
        // GetBuilder<ReelsController>(
        //     init: _reelsController,
        //     builder: (ctx) {
        //       return PageView(
        //           scrollDirection: Axis.vertical,
        //           allowImplicitScrolling: true,
        //           onPageChanged: (index) {
        //             _reelsController.currentPageChanged(
        //                 index, _reelsController.publicMoments[index]);
        //           },
        //           children: [
        //             for (int i = 0;
        //             i < _reelsController.publicMoments.length;
        //             i++)
        //               SizedBox(
        //                 height: Get.height,
        //                 width: Get.width,
        //                 // color: Colors.brown,
        //                 child: ReelVideoPlayer(
        //                   reel: _reelsController.publicMoments[i],
        //                   // play: false,
        //                 ),
        //               )
        //           ]);
        //     }),
        body: postsView(),
        // Positioned(
        //     right: 16,
        //     top: 50,
        //     child: const ThemeIconWidget(ThemeIcon.camera).ripple(() {
        //       Get.to(() => const CreateReelScreen(
        //         isScene: true,
        //       ));
        //     }))
        //   ],
        // )
      ),
    );
  }
}

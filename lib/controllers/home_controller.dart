import 'dart:convert';

import 'package:foap/apiHandler/network_constant.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/ui/reel/create_reel_video.dart';
import 'package:foap/util/ad_helper.dart';
import 'package:foap/util/shared_prefs.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../model/post_ads_model.dart';
import '../model/post_model.dart';
import '../screens/settings_menu/settings_controller.dart';
import '../screens/tvs/tv_dashboard.dart';
import 'dart:async';
import 'package:foap/manager/db_manager.dart';
import 'package:foap/apiHandler/api_controller.dart';
import 'package:foap/model/story_model.dart';
import 'package:foap/model/post_gallery.dart';
import 'package:foap/model/post_search_query.dart';
import 'package:foap/screens/dashboard/posts.dart';
import 'package:foap/screens/highlights/choose_stories.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:foap/screens/story/choose_media_for_story.dart';
import 'package:foap/screens/home_feed/quick_links.dart';
import 'package:foap/screens/live/random_live_listing.dart';
import 'package:foap/screens/live/checking_feasibility.dart';
import 'package:foap/screens/competitions/competitions_screen.dart';
import 'package:http/http.dart' as http;
class HomeController extends GetxController {
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  RxList<PostModel> posts = <PostModel>[].obs;
  List<Ads> ads = [];
  Ads? advertis;
  RxList<StoryModel> stories = <StoryModel>[].obs;
  RxList<UserModel> liveUsers = <UserModel>[].obs;

  RxList<BannerAd> bannerAds = <BannerAd>[].obs;
  List<Items> adsItem = [];
  RxInt currentVisibleVideoId = 0.obs;
  Map<int, double> _mediaVisibilityInfo = {};
  PostSearchQuery postSearchQuery = PostSearchQuery();

  RxBool isRefreshingPosts = false.obs;
  RxBool isRefreshingStories = false.obs;

  RxInt categoryIndex = 0.obs;

  int _postsCurrentPage = 1;
  bool _canLoadMorePosts = true;

  RxBool openQuickLinks = false.obs;

  RxList<QuickLink> quickLinks = <QuickLink>[].obs;

  clear() {
    stories.clear();
    liveUsers.clear();
  }

  clearPosts() {
    _postsCurrentPage = 1;
    _canLoadMorePosts = true;
    posts.clear();
  }

  quickLinkSwitchToggle() {
    openQuickLinks.value = !openQuickLinks.value;

    if (openQuickLinks.value == true) {
      // Get.bottomSheet(
      QuickLinkWidget(callback: () {
        closeQuickLinks();
        Get.back();
      });
      //     .then((value) {
      //   closeQuickLinks();
      // });
    }
  }

  closeQuickLinks() {
    openQuickLinks.value = false;
  }

  loadQuickLinksAccordingToSettings() {
    quickLinks.clear();
    if (_settingsController.setting.value!.enableStories) {
      quickLinks.add(QuickLink(
          icon: 'assets/stories.png',
          heading: LocalizationString.story,
          subHeading: LocalizationString.story,
          linkType: QuickLinkType.story,
      isSetting: false));
    }
    if (_settingsController.setting.value!.enableHighlights) {
      // quickLinks.add(QuickLink(
      //     icon: 'assets/highlights.png',
      //     heading: LocalizationString.highlights,
      //     subHeading: LocalizationString.highlights,
      //     linkType: QuickLinkType.highlights));
    }
    if (_settingsController.setting.value!.enableLive) {
      quickLinks.add(QuickLink(
          icon: 'assets/live.png',
          heading: LocalizationString.goLive,
          subHeading: LocalizationString.goLive,
          linkType: QuickLinkType.goLive,
          isSetting: false));
    }
    // if (_settingsController.setting.value!.enableCompetitions) {
    //   quickLinks.add(QuickLink(
    //       icon: 'assets/competitions.png',
    //       heading: LocalizationString.competition,
    //       subHeading: LocalizationString.joinCompetitionsToEarn,
    //       linkType: QuickLinkType.competition));
    // }
    // if (_settingsController.setting.value!.enableClubs) {
    //   quickLinks.add(QuickLink(
    //       icon: 'assets/club_colored.png',
    //       heading: LocalizationString.clubs,
    //       subHeading: LocalizationString.placeForPeopleOfCommonInterest,
    //       linkType: QuickLinkType.clubs));
    // }
    //
    // if (_settingsController.setting.value!.enableStrangerChat) {
    //   quickLinks.add(QuickLink(
    //       icon: 'assets/chat_colored.png',
    //       heading: LocalizationString.strangerChat,
    //       subHeading: LocalizationString.haveFunByRandomChatting,
    //       linkType: QuickLinkType.randomChat));
    // }
    // if (_settingsController.setting.value!.enableCompetitions) {
    //   quickLinks.add(QuickLink(
    //       icon: 'assets/competitions.png',
    //       heading: LocalizationString.competition,
    //       subHeading: LocalizationString.joinCompetitionsToEarn,
    //       linkType: QuickLinkType.competition));
    // }
    // if (_settingsController.setting.value!.enableReel) {
    // quickLinks.add(QuickLink(
    //     icon: 'assets/reel.png',
    //     heading: LocalizationString.reel,
    //     subHeading: LocalizationString.reel,
    //     linkType: QuickLinkType.reel));
    // // }
    // if (_settingsController.setting.value!.enableWatchTv) {
    //   quickLinks.add(QuickLink(
    //       icon: 'assets/television.png',
    //       heading: LocalizationString.tvs,
    //       subHeading: LocalizationString.tvs,
    //       linkType: QuickLinkType.tv));
    // }
    quickLinks.add(QuickLink(
        icon: 'assets/settings.png',
        heading: LocalizationString.settings,
        subHeading: LocalizationString.settings,
        linkType: QuickLinkType.settings,
        isSetting: true));
  }

  categoryIndexChanged({required int index, required VoidCallback callback}) {
    if (index != categoryIndex.value) {
      categoryIndex.value = index;
      clearPosts();
      postSearchQuery = PostSearchQuery();

      if (index == 1) {
        postSearchQuery.isFollowing = 1;
        postSearchQuery.isRecent = 1;
      }
      // else if (index == 2) {
      //   postSearchQuery.isPopular = 1;
      // }
      else if (index == 2) {
        postSearchQuery.isRecent = 1;
      } else if (index == 3) {
        postSearchQuery.isMine = 1;
        postSearchQuery.isRecent = 1;
      } else {
        postSearchQuery.isRecent = 1;
      }

      getPosts(isRecent: false, callback: callback);
    }
  }

  removePostFromList(PostModel post) {
    posts.removeWhere((element) => element.id == post.id);
    posts.refresh();
  }

  removeUsersAllPostFromList(PostModel post) {
    posts.removeWhere((element) => element.user.id == post.user.id);
    posts.refresh();
  }

  void addNewPost(PostModel post) {
    posts.insert(0, post);
    posts.refresh();
  }

  // void getAds(
  //     {required bool? isRecent, required VoidCallback callback}) async {
  //   print('pp working!');
  //   if (_canLoadMorePosts == true) {
  //
  //     // for (int i = 0; i < 5; i++) {
  //     //   BannerAdsHelper().loadBannerAds((ad) {
  //     //     bannerAds.add(ad);
  //     //     bannerAds.refresh();
  //     //   });
  //     // }
  //
  //     if (isRecent == true) {
  //       postSearchQuery.isRecent = 1;
  //     }
  //
  //     if (_postsCurrentPage == 1) {
  //       isRefreshingPosts.value = true;
  //     }
  //
  //     AppUtil.checkInternet().then((value) async {
  //       print('working !!');
  //       if (value) {
  //         ApiController()
  //             .getPosts(
  //             userId: postSearchQuery.userId,
  //             isPopular: postSearchQuery.isPopular,
  //             isFollowing: postSearchQuery.isFollowing,
  //             isSold: postSearchQuery.isSold,
  //             isMine: postSearchQuery.isMine,
  //             isRecent: postSearchQuery.isRecent,
  //             title: postSearchQuery.title,
  //             hashtag: postSearchQuery.hashTag,
  //             clubId: postSearchQuery.clubId,
  //             page: _postsCurrentPage)
  //             .then((response) async {
  //           print('this is response---->>> ${response.success}');
  //           posts.addAll(response.success
  //               ? response.posts
  //               .where((element) => element.gallery.isNotEmpty)
  //               .toList()
  //               : []);
  //           ads.addAll(response.success
  //               ? response.ads
  //               .where((element) => element.items!.isNotEmpty)
  //               .toList()
  //               : []);
  //           posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
  //           isRefreshingPosts.value = false;
  //
  //           if (_postsCurrentPage >= response.metaData!.pageCount) {
  //             _canLoadMorePosts = false;
  //           }
  //           else {
  //             _canLoadMorePosts = true;
  //           }
  //           _postsCurrentPage += 1;
  //
  //           callback();
  //         });
  //       }
  //     });
  //   }
  // }

  void getPosts(
      {required bool? isRecent, required VoidCallback callback}) async {
    print('pp working! $_canLoadMorePosts');
    if (_canLoadMorePosts == true) {

      // for (int i = 0; i < 5; i++) {
      //   BannerAdsHelper().loadBannerAds((ad) {
      //     bannerAds.add(ad);
      //     bannerAds.refresh();
      //   });
      // }

      if (isRecent == true) {
        postSearchQuery.isRecent = 1;
        _postsCurrentPage = 1;
      }

      if (_postsCurrentPage == 1) {
        isRefreshingPosts.value = true;
      }

      AppUtil.checkInternet().then((value) async {

        print('working !! $_postsCurrentPage');
        if (value) {
          ApiController()
              .getPosts(
                  userId: postSearchQuery.userId,
                  isPopular: postSearchQuery.isPopular,
                  isFollowing: postSearchQuery.isFollowing,
                  isSold: postSearchQuery.isSold,
                  isMine: postSearchQuery.isMine,
                  isRecent: postSearchQuery.isRecent,
                  title: postSearchQuery.title,
                  hashtag: postSearchQuery.hashTag,
                  clubId: postSearchQuery.clubId,
                  page: _postsCurrentPage
          )
              .then((response) async {
            // getAds(
            //     userId: postSearchQuery.userId,
            //     isPopular: postSearchQuery.isPopular,
            //     isFollowing: postSearchQuery.isFollowing,
            //     isSold: postSearchQuery.isSold,
            //     isMine: postSearchQuery.isMine,
            //     isRecent: postSearchQuery.isRecent,
            //     title: postSearchQuery.title,
            //     hashtag: postSearchQuery.hashTag,
            //     clubId: postSearchQuery.clubId,
            // //     page: _postsCurrentPage);
            //     print('this is response---->>> ${response.posts[0].title}');
                posts.clear();
            posts.addAll(response.success
                ? response.posts
                    .where((element) => element.gallery.isNotEmpty)
                    .toList()
                : []);
            update();


                ads.addAll(response.success
                    ? response.ads
                    .where((element) => element.items!.isNotEmpty)
                    .toList()
                    : []);

            posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
            isRefreshingPosts.value = false;

            if (_postsCurrentPage >= response.metaData!.pageCount) {
              _canLoadMorePosts = false;
            }
            else {
              _canLoadMorePosts = true;
            }
            _postsCurrentPage += 1;

            callback();
          });
        }
      });
    }
  }

  int i = 0;
   getAds(
      {int? userId,
        int? isPopular,
        int? isFollowing,
        int? clubId,
        int? isSold,
        int? isReel,
        int? audioId,
        int? isMine,
        int? isRecent,
        String? title,
        String? hashtag,
        int page = 0}) async {

    String? authKey = await SharedPrefs().getAuthorizationKey();

    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.searchPost;

    if (userId != null) {
      url = '$url&user_id=$userId';
    }
    if (isPopular != null) {
      url = '$url&is_popular_post=$isPopular';
    }
    if (title != null) {
      url = '$url&title=$title';
    }
    if (isRecent != null) {
      url = '$url&is_recent=$isRecent';
    }
    if (isFollowing != null) {
      url = '$url&is_following_user_post=$isFollowing';
    }
    if (isMine != null) {
      url = '$url&is_my_post=$isMine';
    }
    if (isSold != null) {
      url = '$url&is_winning_post=$isSold';
    }
    if (hashtag != null) {
      url = '$url&hashtag=$hashtag';
    }
    if (clubId != null) {
      url = '$url&club_id=$clubId';
    }
    if (isReel != null) {
      url = '$url&is_reel=$isReel';
    }
    if (audioId != null) {
      url = '$url&audio_id=$audioId';
    }
    url = '$url&page=$page';
    print("workin here! $url and");
    return await http.get(Uri.parse(url), headers: {
      "Authorization": "Bearer ${authKey!}"
    }).then((http.Response response) async {
      print('this is ads**** ${response.body}');
      var data = PostAdsModel.fromJson(json.decode(response.body)) ;
      // advertis = data.data!.ads;
      // List<String> adsData = [];
      //
      // for(i = 0; i < advertis!.items!.length; i ++){
      //   adsItem.add(advertis!.items![i]);
      // }
      update();
      print('this is ads**** ${adsItem.length}');
      // print('this is ads ===>>>${ads.length}');
      // final ApiResponseModel parsedResponse =
      // await getResponse(response.body, NetworkConstantsUtil.searchPost);
      // return parsedResponse;
    });
  }

  contentOptionSelected(String option) {
    if (option == LocalizationString.story) {
      Get.to(() => const ChooseMediaForStory());
    } else if (option == LocalizationString.post) {
      // Get.offAll(const DashboardScreen(
      //   selectedTab: 2,
      // ));
    } else if (option == LocalizationString.highlights) {
      Get.to(() => const ChooseStoryForHighlights(show: false,));
    } else if (option == LocalizationString.goLive) {
      Get.to(() => const CheckingLiveFeasibility());
    } else if (option == LocalizationString.competition) {
      Get.to(() => const CompetitionsScreen());
    } else if (option == LocalizationString.liveNow) {
      Get.to(() => const RandomLiveListing());
    } else if (option == LocalizationString.liveTv) {
      Get.to(() => const TvDashboardScreen());
      // Get.to(() => const LiveTVStreaming());
    } else if (option == LocalizationString.reel) {
      Get.to(() => const CreateReelScreen(
        isScene: true
      ));
      // Get.to(() => const LiveTVStreaming());
    }
  }

  setCurrentVisibleVideo(
      {required PostGallery media, required double visibility}) {
    // print(visibility);
    if (visibility < 20) {
      currentVisibleVideoId.value = -1;
    }
    _mediaVisibilityInfo[media.id] = visibility;
    double maxVisibility =
        _mediaVisibilityInfo[_mediaVisibilityInfo.keys.first] ?? 0;
    int maxVisibilityMediaId = _mediaVisibilityInfo.keys.first;

    for (int key in _mediaVisibilityInfo.keys) {
      double visibility = _mediaVisibilityInfo[key] ?? 0;
      if (visibility >= maxVisibility) {
        maxVisibilityMediaId = key;
      }
    }

    if (currentVisibleVideoId.value != maxVisibilityMediaId &&
        visibility > 80) {
      currentVisibleVideoId.value = maxVisibilityMediaId;
      update();
    }
  }

  void reportPost(int postId) {
    AppUtil.checkInternet().then((value) async {
      if (value) {
        ApiController().reportPost(postId).then((response) async {
          if (response.success == true) {
            AppUtil.showToast(
                message: LocalizationString.postReportedSuccessfully,
                isSuccess: true);
          } else {
            AppUtil.showToast(
                message: LocalizationString.errorMessage, isSuccess: true);
          }
        });
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet, isSuccess: true);
      }
    });
  }

  // void likeUnlikePost(PostModel post, BuildContext context) {
  //   post.isLike = !post.isLike;
  //   post.totalLike = post.isLike ? (post.totalLike) + 1 : (post.totalLike) - 1;
  //   AppUtil.checkInternet().then((value) async {
  //     if (value) {
  //       ApiController()
  //           .likeUnlike(post.isLike, post.id)
  //           .then((response) async {});
  //     } else {
  //       AppUtil.showToast(
  //           context: context,
  //           message: LocalizationString.noInternet,
  //           isSuccess: true);
  //     }
  //   });
  //
  //   posts.refresh();
  //   update();
  // }

  postTextTapHandler({required PostModel post, required String text}) {
    if (text.startsWith('#')) {
      Get.to(() => Posts(
                hashTag: text.replaceAll('#', ''),
                source: PostSource.posts,
              ))!
          .then((value) {
        getPosts(isRecent: false, callback: () {});
        getStories();
      });
    } else {
      String userTag = text.replaceAll('@', '');
      if (post.mentionedUsers
          .where((element) => element.userName == userTag)
          .isNotEmpty) {
        int mentionedUserId = post.mentionedUsers
            .where((element) => element.userName == userTag)
            .first
            .id;
        Get.to(() => OtherUserProfile(userId: mentionedUserId))!.then((value) {
          getPosts(isRecent: false, callback: () {});
          getStories();
        });
      }
    }
  }

// stories

  void getStories() async {
    isRefreshingStories.value = true;
    update();

    AppUtil.checkInternet().then((value) async {
      if (value) {
        var responses = await Future.wait([
          getCurrentActiveStories(),
          getFollowersStories(),
          getLiveUsers()
        ]).whenComplete(() {});
        stories.clear();

        StoryModel story = StoryModel(
            id: 1,
            name: '',
            userName: _userProfileManager.user.value!.userName,
            email: '',
            image: _userProfileManager.user.value!.picture,
            media: responses[0] as List<StoryMediaModel>);

        stories.add(story);
        stories.addAll(responses[1] as List<StoryModel>);
        liveUsers.value = responses[2] as List<UserModel>;
      }

      isRefreshingStories.value = false;
      update();
    });
  }

  Future<List<UserModel>> getLiveUsers() async {
    List<UserModel> currentLiveUsers = [];
    await AppUtil.checkInternet().then((value) async {
      if (value) {
        await ApiController().getCurrentLiveUsers().then((response) async {
          currentLiveUsers = response.liveUsers;
        });
      }
    });
    return currentLiveUsers;
  }

  Future<List<StoryModel>> getFollowersStories() async {
    List<StoryModel> followersStories = [];
    List<StoryModel> viewedAllStories = [];
    List<StoryModel> notViewedStories = [];

    List<int> viewedStoryIds = await getIt<DBManager>().getAllViewedStories();

    await ApiController().getStories().then((response) async {
      for (var story in response.stories) {
        var allMedias = story.media;
        var notViewedStoryMedias = allMedias
            .where((element) => viewedStoryIds.contains(element.id) == false);

        if (notViewedStoryMedias.isEmpty) {
          story.isViewed = true;
          viewedAllStories.add(story);
        } else {
          notViewedStories.add(story);
        }
      }
    });

    followersStories.addAll(notViewedStories);
    followersStories.addAll(viewedAllStories);

    return followersStories;
  }

  Future<List<StoryMediaModel>> getCurrentActiveStories() async {
    List<StoryMediaModel> myActiveStories = [];

    await ApiController().getCurrentActiveStories().then((response) async {
      myActiveStories = response.myActiveStories;
      update();
    });

    return myActiveStories;
  }

  liveUsersUpdated() {
    getStories();
  }
}



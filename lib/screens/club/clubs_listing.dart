import 'package:flutter/material.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/screens/club/search_club.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/util/ad_helper.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../components/actionSheets/action_sheet1.dart';
import '../../components/custom_texts.dart';
import '../../components/group_avatars/group_avatar1.dart';
import '../../components/group_avatars/group_avatar2.dart';
import '../../components/shimmer_widgets.dart';
import '../../components/top_navigation_bar.dart';
import '../../controllers/clubs/clubs_controller.dart';
import '../../helper/common_components.dart';
import '../../helper/localization_strings.dart';
import '../../model/category_model.dart';
import '../../model/club_invitation.dart';
import '../../model/club_model.dart';
import '../../model/generic_item.dart';
import '../../model/post_model.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../../theme/theme_icon.dart';
import '../../util/app_config_constants.dart';
import '../../util/app_util.dart';
import 'categories_list.dart';
import 'category_club_listing.dart';
import 'club_detail.dart';

class ClubsListing extends StatefulWidget {
  const ClubsListing({Key? key}) : super(key: key);

  @override
  ClubsListingState createState() => ClubsListingState();
}

class ClubsListingState extends State<ClubsListing> {
  final ClubsController _clubsController = ClubsController();
  final ScrollController _controller = ScrollController();
  BannerAd? _bannerAd;
  bool _bannerReady = false;
  final SettingsController _settingsController = Get.find();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clubsController.getCategories();
      _clubsController.getClubs(isStartOver: true);
      _clubsController.selectedSegmentIndex(index: 0, forceRefresh: false);
    });

    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
        } else {
          if (_clubsController.segmentIndex.value == 3) {
            if (!_clubsController.isLoadingInvitations.value) {
              _clubsController.getClubInvitations();
            }
          } else {
            if (!_clubsController.isLoadingClubs.value) {
              _clubsController.getClubs(isStartOver: false);
            }
          }
        }
      }
    });
    // _bannerAd?.dispose();
    _bannerAd = BannerAd(

      adUnitId: _settingsController.setting.value!.interstitialAdUnitIdForAndroid!,
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

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _clubsController.clear();
    _clubsController.clearMembers();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      floatingActionButton: Container(
        height: 50,
        width: 50,
        color: AppColorConstants.themeColor.withOpacity(0.7),
        child:  ThemeIconWidget(
          ThemeIcon.plus,
          color: AppColorConstants.whiteClr,
          size: 25,
        ),
      ).circular.ripple(() {
        Get.to(() =>  CategoriesList(clubsController: _clubsController));
      }),
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: AppColorConstants.backgroundColor,
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      //   title: BodyLargeText(LocalizationString.clubs, weight: TextWeight.medium),),
      body: Column(
        children: [
          const SizedBox(
            height: 35,
          ),

          // backNavigationBarWithIcon(
          //     context: context,
          //     title: LocalizationString.clubs,
          //     iconBtnClicked: () {
          //       _clubsController.clear();
          //       Get.to(() => const SearchClubsListing());
          //     },
          //     icon: ThemeIcon.search),
          divider(context: context).tP8,
          const SizedBox(
            height: 10,
          ),
          bannerAd(),
          const SizedBox(
            height: 10,
          ),
          categories(),
          const SizedBox(
            height: 30,
          ),
          links(),
          Expanded(
            child: Obx(() {
              List<ClubModel> clubs = _clubsController.clubs;
              List<ClubInvitation> invitations = _clubsController.invitations;
              return _clubsController.segmentIndex.value == 3
                  ? clubsInvitationsListingWidget(invitations)
                  : clubsListingWidget(clubs);
            }),
          ),
        ],
      ),
    );
  }
  Widget bannerAd(){
    return _bannerReady
        ? SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    )
        : Container();
  }
  Widget categories() {
    return SizedBox(
      height: 100,
      child: Obx(() {
        List<CategoryModel> categories = _clubsController.categories;
        return _clubsController.isLoadingCategories.value
            ? const ClubsCategoriesScreenShimmer()
            : ListView.separated(
                padding: const EdgeInsets.only(left: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return CategoryAvatarType1(category: categories[index])
                      .ripple(() {
                    Get.to(() =>
                        CategoryClubsListing(category: categories[index]));
                  });
                },
                separatorBuilder: (BuildContext ctx, int index) {
                  return const SizedBox(
                    width: 10,
                  );
                });
      }),
    );
  }

  Widget links() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: HorizontalMenuBar(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  onSegmentChange: (segment) {
                    _clubsController.selectedSegmentIndex(
                        index: segment, forceRefresh: false);
                  },
                  selectedIndex: _clubsController.segmentIndex.value,
                  menus: [
                    LocalizationString.all,
                    LocalizationString.joined,
                    LocalizationString.myClub,
                    LocalizationString.invites,
                  ]),
            ),
          ],
        ));
  }

  Widget clubsListingWidget(List<ClubModel> clubs) {
    return _clubsController.isLoadingClubs.value
        ? const ClubsScreenShimmer()
        : _clubsController.clubs.isEmpty
            ? Container()
            : ListView.separated(
                controller: _controller,
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 20, bottom: 100),
                itemCount: clubs.length,
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext ctx, int index) {
                  return ClubCard(
                    club: clubs[index],
                    joinBtnClicked: () {
                      _clubsController.joinClub(clubs[index]);
                    },
                    leaveBtnClicked: () {
                      _clubsController.leaveClub(clubs[index]);
                    },
                    previewBtnClicked: () {
                      if(clubs[index].privacyType == 3) {
                        if (clubs[index].isJoined == true) {
                          Get.to(() =>
                              ClubDetail(
                                club: clubs[index],
                                needRefreshCallback: () {
                                  _clubsController.getClubs(isStartOver: false);
                                },
                                deleteCallback: (club) {
                                  _clubsController.clubDeleted(club);
                                  AppUtil.showToast(
                                      message: LocalizationString.clubIsDeleted,
                                      isSuccess: true);
                                },
                              ));
                        }
                      }else{
                        Get.to(() =>
                            ClubDetail(
                              club: clubs[index],
                              needRefreshCallback: () {
                                _clubsController.getClubs(isStartOver: false);
                              },
                              deleteCallback: (club) {
                                _clubsController.clubDeleted(club);
                                AppUtil.showToast(
                                    message: LocalizationString.clubIsDeleted,
                                    isSuccess: true);
                              },
                            ));
                      }
                    },
                  );
                },
                separatorBuilder: (BuildContext ctx, int index) {
                  return const SizedBox(
                    height: 25,
                  );
                });
  }

  Widget clubsInvitationsListingWidget(List<ClubInvitation> invitations) {
    return _clubsController.isLoadingClubs.value
        ? const ClubsScreenShimmer()
        : _clubsController.clubs.isEmpty
            ? Container()
            : ListView.separated(
                controller: _controller,
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 20, bottom: 100),
                itemCount: invitations.length,
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext ctx, int index) {
                  return ClubInvitationCard(
                    invitation: invitations[index],
                    acceptBtnClicked: () {
                      _clubsController.acceptClubInvitation(invitations[index]);
                    },
                    declineBtnClicked: () {
                      _clubsController
                          .declineClubInvitation(invitations[index]);
                    },
                    previewBtnClicked: () {
                      // Get.to(() => ClubDetail(
                      //       club: invitations[index].club!,
                      //       needRefreshCallback: () {
                      //         _clubsController.getClubs(isStartOver: false);
                      //       },
                      //       deleteCallback: (club) {
                      //         _clubsController.clubDeleted(club);
                      //         AppUtil.showToast(
                      //             message: LocalizationString.clubIsDeleted,
                      //             isSuccess: true);
                      //       },
                      //     ));
                    },
                  );
                },
                separatorBuilder: (BuildContext ctx, int index) {
                  return const SizedBox(
                    height: 25,
                  );
                });
  }

  showActionSheet(PostModel post) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ActionSheet1(
              items: [
                GenericItem(
                    id: '1',
                    title: LocalizationString.share,
                    icon: ThemeIcon.share),
                GenericItem(
                    id: '2',
                    title: LocalizationString.report,
                    icon: ThemeIcon.report),
                GenericItem(
                    id: '3',
                    title: LocalizationString.hide,
                    icon: ThemeIcon.hide),
              ],
              itemCallBack: (item) {},
            ));
  }
}

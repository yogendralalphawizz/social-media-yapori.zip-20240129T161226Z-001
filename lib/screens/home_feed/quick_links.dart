import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:foap/screens/add_on/ui/reel/create_reel_video.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../chat/random_chat/choose_profile_category.dart';

import '../club/clubs_listing.dart';
import '../competitions/competitions_screen.dart';
import '../highlights/choose_stories.dart';
import '../live/checking_feasibility.dart';
import '../live/random_live_listing.dart';
import '../story/choose_media_for_story.dart';
import '../tvs/tv_dashboard.dart';

enum QuickLinkType {
  live,
  randomChat,
  randomCall,
  competition,
  clubs,
  pages,
  tv,
  story,
  highlights,
  goLive,
  reel,
  settings
}

class QuickLink {
  String icon;
  String heading;
  String subHeading;
  QuickLinkType linkType;
  final bool isSetting;

  QuickLink(
      {required this.icon,
      required this.heading,
      required this.subHeading,
      required this.linkType, required this.isSetting });
}

class QuickLinkWidget extends StatefulWidget {
  final VoidCallback callback;

  const QuickLinkWidget({Key? key, required this.callback}) : super(key: key);

  @override
  State<QuickLinkWidget> createState() => _QuickLinkWidgetState();
}

class _QuickLinkWidgetState extends State<QuickLinkWidget> {
  final HomeController _homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      decoration: BoxDecoration(
          // color: AppColorConstants.themeColor,
          borderRadius: BorderRadius.circular(30)),

          child: GridView(
              padding: EdgeInsets.zero,
              // spacing: 10,
              // runSpacing: 10,
              clipBehavior: Clip.hardEdge,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 30.0,
              ),
              children: [
                for (QuickLink link in _homeController.quickLinks)
                  quickLinkView(link).ripple(() {
                    widget.callback();
                    if (link.linkType == QuickLinkType.live) {
                      Get.to(() => const RandomLiveListing());
                    } else if (link.linkType == QuickLinkType.competition) {
                      Get.to(() => const CompetitionsScreen());
                    }
                    else if (link.linkType == QuickLinkType.randomChat) {
                      if (AppConfigConstants.isDemoApp) {
                        AppUtil.showDemoAppConfirmationAlert(
                            title: 'Demo app',
                            subTitle:
                                'This is demo app so might not find online user to test it',
                            okHandler: () {
                              Get.to(() => const ChooseProfileCategory(
                                    isCalling: false,
                                  ));
                            });
                        return;
                      } else {
                        Get.to(() => const ChooseProfileCategory(
                              isCalling: false,
                            ));
                      }
                    }
                    else if (link.linkType == QuickLinkType.randomCall) {
                      Get.to(() => const ChooseProfileCategory(
                            isCalling: true,
                          ));
                    } else if (link.linkType == QuickLinkType.clubs) {
                      Get.to(() => const ClubsListing());
                    } else if (link.linkType == QuickLinkType.pages) {
                    } else if (link.linkType == QuickLinkType.goLive) {
                      Get.to(() => const CheckingLiveFeasibility());
                    } else if (link.linkType == QuickLinkType.reel) {
                      Get.to(() => const CreateReelScreen(
                        isScene: false,
                      ));
                    } else if (link.linkType == QuickLinkType.story) {
                      Get.to(() => const ChooseMediaForStory());
                    }
                    // else if (link.linkType == QuickLinkType.highlights) {
                    //   Get.to(() => const ChooseStoryForHighlights(
                    //     show: false,
                    //   ));
                    // }
                    else if (link.linkType == QuickLinkType.tv) {
                      Get.to(() => const TvDashboardScreen());
                    }
                    else if (link.linkType == QuickLinkType.settings) {
                      Get.to(() => const Settings());
                    }
                  })
              ]).setPadding(left: 16, right: 16, top: 20),
        ).topRounded(30));
  }

  Widget quickLinkView(QuickLink link) {
    return Container(
      // height: 30,
      color: AppColorConstants.cardColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            link.icon,
            height: 20,
            width: 20,
            color: link.isSetting ? AppColorConstants.iconColor : null,
          ),
          // const Spacer(),
          const SizedBox(
            width: 10,
          ),
          Heading6Text(
            link.heading.tr,
          ),
        ],
      ).hP16,
    ).round(40);

    //   Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Container(
    //       height: 50,
    //       color: AppColorConstants.cardColor,
    //       child: Row(
    //         mainAxisSize: MainAxisSize.min,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           Image.asset(
    //             link.icon,
    //             height: 20,
    //             width: 20,
    //           ),
    //           // const Spacer(),
    //           const SizedBox(
    //             width: 10,
    //           ),
    //           Heading6Text(
    //             link.heading.tr,
    //           ),
    //         ],
    //       ).hP16,
    //     ).round(40),
    //     // divider(context: context).vP8
    //   ],
    // );
  }
}

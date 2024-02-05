import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/competition_imports.dart';
import 'package:get/get.dart';

import '../settings_menu/settings_controller.dart';
import '../settings_menu/web_view_screen.dart';

class CompetitionDetailScreen extends StatefulWidget {
  final int competitionId;

  final VoidCallback refreshPreviousScreen;

  const CompetitionDetailScreen(
      {Key? key,
      required this.competitionId,
      required this.refreshPreviousScreen})
      : super(key: key);

  @override
  CompetitionDetailState createState() => CompetitionDetailState();
}

class CompetitionDetailState extends State<CompetitionDetailScreen> {
  final CompetitionController competitionController = CompetitionController();
  final SettingsController settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (widget.competition != null) {
      //   competitionController.setCompetition(widget.competition!);
      // } else {
      competitionController.loadCompetitionDetail(id: widget.competitionId);
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ThemeIconWidget(
                    ThemeIcon.backArrow,
                    size: 20,
                  ).ripple(() {
                    Get.back();
                  }),
                  const Spacer(),
                  BodyLargeText(LocalizationString.disclaimer,
                          weight: TextWeight.medium)
                      .ripple(() {
                    Get.to(() => WebViewScreen(
                        header: LocalizationString.disclaimer,
                        url: settingsController.setting.value!.disclaimerUrl!));
                  }),
                ],
              ).hP16,
              Positioned(
                left: 0,
                right: 0,
                child: Center(
                  child: BodyLargeText(
                    LocalizationString.competition,
                      weight: TextWeight.bold
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          divider(context: context).tP8,
          GetBuilder<CompetitionController>(
              init: competitionController,
              builder: (ctx) {
                return competitionController.competition.value != null
                    ? Expanded(
                        child: Stack(children: [
                          SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: competitionController
                                          .competition.value!.photo,
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                      height: 270,
                                      placeholder: (context, url) =>
                                          AppUtil.addProgressIndicator(
                                              size:100),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                    applyShader(),
                                    CompetitionHighlightBar(
                                        model: competitionController
                                            .competition.value!)
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Heading5Text(
                                      competitionController
                                          .competition.value!.title,
                                      weight: TextWeight.bold,
                                      color: AppColorConstants.themeColor,
                                    ).bP8,
                                    Heading5Text(
                                        competitionController
                                            .competition.value!.description,
                                        ),
                                  ],
                                ).p16,
                                const SizedBox(
                                  height: 40,
                                ),
                                competitionController.competition.value!
                                            .competitionMediaType ==
                                        1
                                    ? addPhotoGrid().hP16
                                    : addVideoGrid().hP16,
                              ])),
                          addBottomActionButton()
                        ]),
                      )
                    : Container();
              }),
        ],
      ),
    );
  }

  Widget addVideoGrid() {
    CompetitionModel model = competitionController.competition.value!;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      model.exampleImages.isNotEmpty
          ? Heading4Text(
              LocalizationString.exampleVideos,
          weight: TextWeight.bold
            ).hP16
          : Container(),
      const SizedBox(height: 65)
    ]).hP16;
  }

  Widget addPhotoGrid() {
    CompetitionModel model = competitionController.competition.value!;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      model.exampleImages.isNotEmpty
          ? Heading3Text(LocalizationString.examplePhotos,
              weight: TextWeight.medium,)
          : Container(),
      const SizedBox(
        height: 20,
      ),
      GridView.builder(
        itemCount: model.exampleImages.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        // You won't see infinite size error
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            mainAxisExtent: 100),
        itemBuilder: (BuildContext context, int index) => InkWell(
            onTap: () async {
              // File path = await AppUtil.findPath(model.exampleImages[index]);

              // Get.to(
              //     () => EnlargeImageViewScreen(model: model!, handler: () {}));
            },
            child: CachedNetworkImage(
              imageUrl: model.exampleImages[index],
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  AppUtil.addProgressIndicator(size:100),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ).round(10)),
        // staggeredTileBuilder: (int index) => new StaggeredTile.count(1, 1),

      ),
      const SizedBox(height: 65)
    ]);
  }

  applyShader() {
    return Container(
        height: 270.0,
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: FractionalOffset.bottomCenter,
              end: FractionalOffset.topCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
              ],
              stops: const [
                0.0,
                1.0
              ]),
        ));
  }

  addBottomActionButton() {
    CompetitionModel model = competitionController.competition.value!;

    String title;
    var loggedInUserPost = model.posts
        .where((element) =>
            element.user.id == _userProfileManager.user.value!.id)
        .toList();
    if (model.isJoined == 1) {
      title = loggedInUserPost.isNotEmpty
          ? LocalizationString.viewSubmission
          : model.competitionMediaType == 1
              ? LocalizationString.postPhoto
              : LocalizationString.postVideo;
    } else {
      title =
          "${LocalizationString.join} (${LocalizationString.fee} ${model.joiningFee} ${LocalizationString.coins})";
    }

    return Positioned(
      bottom: 0,
      child: InkWell(
          onTap: () async {
            if (model.isJoined == 1) {
              //Already Joined Mission
              if (loggedInUserPost.isNotEmpty) {
                //User have already published post for this competition
                competitionController.viewMySubmission(model);
              } else {
                competitionController.submitMedia(model);
              }
            } else {
              competitionController.joinCompetition(model, context);
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 95,
            color: AppColorConstants.themeColor,
            child: Center(
              child: Heading6Text(title,
                  ),
            ),
          )),
    );
  }
}

import 'package:foap/components/thumbnail_view.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';


class StoryUpdatesBar extends StatefulWidget {
  final List<StoryModel> stories;
  final List<UserModel> liveUsers;

  final VoidCallback addStoryCallback;
  final Function(StoryModel) viewStoryCallback;
  final Function(UserModel) joinLiveUserCallback;
  final UserModel user;
  const StoryUpdatesBar({
    Key? key,
    required this.stories,
    required this.liveUsers,
    required this.addStoryCallback,
    required this.viewStoryCallback,
    required this.joinLiveUserCallback,
    required this.user}) : super(key: key);

  @override
  State<StoryUpdatesBar> createState() => _StoryUpdatesBarState();
}

class _StoryUpdatesBarState extends State<StoryUpdatesBar> {
  final ProfileController _profileController = Get.find();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _profileController.getMyProfile();
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
        init: _profileController,
        builder: (ctx)
    {
      return
        ListView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16),
          scrollDirection: Axis.horizontal,
          itemCount: widget.stories.length + widget.liveUsers.length,
          itemBuilder: (BuildContext ctx, int index) {
            if (index == 0) {
              return SizedBox(
                width: 70,
                child: widget.stories.isNotEmpty
                    ? widget.stories[index].media.isEmpty == true
                    ? Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: UserAvatarView(
                              user: _profileController.user.value!,
                              size: 50,
                              onTapHandler: () {}),
                        )
                            .borderWithRadius(
                            value: 2, radius: 20)
                            .ripple(() {
                          widget.addStoryCallback();
                        }),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            color: AppColorConstants.themeColor,
                            height: 20,
                            width: 20,
                            child: ThemeIconWidget(
                              ThemeIcon.plus,
                              size: 14,
                              color: AppColorConstants.whiteClr,
                            ),
                          )
                              .borderWithRadius(
                              value: 2, radius: 20)
                              .ripple(() {
                            widget.addStoryCallback();
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 5,
                    ),
                    BodySmallText(LocalizationString.yourStory.tr,
                        weight: TextWeight.medium)
                  ],
                )
                    : Container(
                  height: 60,
                  width: 60,
                  child: Column(
                    children: [

                      widget.stories[index].media.isNotEmpty ?
                      MediaThumbnailView(
                        borderColor: widget.stories[index].isViewed == true
                            ? AppColorConstants.disabledColor
                            : AppColorConstants.themeColor,
                        media: widget.stories[index].media.last,
                      ).ripple(() {
                        widget.viewStoryCallback(widget.stories[index]);
                      })
                          : SizedBox.shrink(),
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        child: BodySmallText(LocalizationString.yourStory.tr,
                            maxLines: 1,
                            weight: TextWeight.medium),
                      )
                    ],
                  ),
                )
                    : Container(),
              );
            } else {
              if (index <= widget.liveUsers.length) {
                return SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        UserAvatarView(
                          size: 50,
                          user: widget.liveUsers[index - 1],
                          onTapHandler: () {
                            widget.joinLiveUserCallback(
                                widget.liveUsers[index - 1]);
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Expanded(
                            child: BodySmallText(
                                widget.liveUsers[index - 1].userName,
                                maxLines: 1,
                                weight: TextWeight.medium).hP4)
                      ],
                    ));
              } else {
                return SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        MediaThumbnailView(
                          borderColor:
                          widget.stories[index - widget.liveUsers.length]
                              .isViewed == true
                              ? AppColorConstants.disabledColor
                              : AppColorConstants.themeColor,
                          media: widget.stories[index - widget.liveUsers.length]
                              .media.last,
                        ).ripple(() {
                          widget.viewStoryCallback(widget.stories[index - widget
                              .liveUsers.length]);
                        }).ripple(() {
                          widget.viewStoryCallback(
                              widget.stories[index - widget.liveUsers.length]);
                        }),
                        const SizedBox(
                          height: 4,
                        ),
                        Expanded(
                          child: BodySmallText(
                              widget.stories[index - widget.liveUsers.length]
                                  .userName,
                              maxLines: 1,
                              weight: TextWeight.medium).hP4,
                        ),
                      ],
                    ));
              }
            }
          },
        );
    }
    );
  }
}

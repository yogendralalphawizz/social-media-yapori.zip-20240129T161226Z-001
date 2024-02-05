import 'package:chewie/chewie.dart';
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart';
import 'package:foap/components/post_card_controller.dart';
import 'package:foap/controllers/explore_controller.dart';
import 'package:foap/controllers/user_network_controller.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/profile_imports.dart';
import 'package:foap/helper/imports/reel_imports.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:foap/screens/chat/select_users.dart';
import 'package:foap/screens/home_feed/comments_screen.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../controllers/chat_and_call/select_user_for_chat_controller.dart';
import '../../../profile/follower_following_list.dart';

class ReelVideoPlayer extends StatefulWidget {
  final PostModel reel;

  const ReelVideoPlayer({
    Key? key,
    required this.reel,
  }) : super(key: key);

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late Future<void> initializeVideoPlayerFuture;
  VideoPlayerController? videoPlayerController;
  late bool playVideo;
  final ReelsController _reelsController = Get.find();
  final SelectUserForChatController selectUserForChatController =
      SelectUserForChatController();
  final UserNetworkController _userNetworkController = UserNetworkController();
  final PostCardController postCardController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();
  final ExploreController exploreController = ExploreController();
  final ProfileController _profileController = Get.find();
  bool enableFollowButton = true;
  bool followButtonPressed = true;
  bool showReact = false;

  bool isUserFollower() {
    bool res = false;
    _userNetworkController
        .getFollowingUsers(_userProfileManager.user.value!.id);
    for (var element in followerList) {
      if (element.id == widget.reel.user.id) {
        res = true;
        break;
      }
    }
    if (!res) followButtonPressed = false;
    return res;
  }

  @override
  void initState() {
    super.initState();
    // playVideo = widget.play;
    prepareVideo(url: widget.reel.gallery.first.filePath);
  }

  @override
  void didUpdateWidget(covariant ReelVideoPlayer oldWidget) {
    playVideo = _reelsController.currentViewingReel.value!.id == widget.reel.id;

    if (playVideo == true) {
      play();
    } else {
      pause();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }

  String svgString = '';
  Future<void> convertSVGToString(String emoji) async {
    // Replace 'assets/your_svg_file.svg' with the path to your SVG file
    final String svgData =
    await DefaultAssetBundle.of(context).loadString(emoji);
    setState(() {
      svgString = svgData;
    });
    print('this is emoji path $svgString');
  }

  void openProfile() async {
    if (widget.reel.user.isMe) {
      Get.to(() => const MyProfile(
        showBack: true,
      ));
    } else {
      _profileController.otherUserProfileView(
          refId: widget.reel.id, sourceType: 1);
      Get.to(() => OtherUserProfile(userId: widget.reel.user.id));
    }
  }

  Widget getFollowButton() {
    print("getFollowButton enableFollowButton : $enableFollowButton");
    Widget followButton = Container();
    if (enableFollowButton) {
      print("getFollowButton inside if");
      setState(() {
        followButton = const SizedBox.shrink();
      });
    } else {
      print("getFollowButton inside else");
      setState(() {
        followButton = Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: SizedBox(
              height: 25,
              // width: 80,
              child: AppThemeBorderButton(
                  // icon: ThemeIcon.message,
                  text: widget.reel.user.isFollower == true
                      ? LocalizationString.followBack
                      : LocalizationString.follow,
                  textStyle: TextStyle(
                      fontSize: FontSizes.b2,
                      fontWeight: TextWeight.medium,
                      color: AppColorConstants.themeColor),
                  onPress: () {
                    exploreController.followUser(widget.reel.user);
                    setState(() {
                      enableFollowButton = true;
                      followButton = const SizedBox.shrink();
                      getFollowButton();
                      // commentAndLikeWidget(widget.model.user.id);
                    });
                  })),
        );
      });
    }
    print("getFollowButton followButton : $followButton");
    return followButton;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      enableFollowButton = isUserFollower();
    });
    return Stack(
      children: [
        FutureBuilder(
          future: initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SizedBox(
                key: PageStorageKey(widget.reel.gallery.first.filePath),
                child: Chewie(
                  key: PageStorageKey(widget.reel.gallery.first.filePath),
                  controller: ChewieController(
                    allowFullScreen: true,
                    videoPlayerController: videoPlayerController!,
                    aspectRatio: Get.width / (Get.height - 80),
                    showOptions: false,
                    showControls: false,
                    autoInitialize: true,
                    looping: false,
                    autoPlay: false,

                    // allowMuting: true,
                    errorBuilder: (context, errorMessage) {
                      return Center(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        Positioned(
            bottom: 25,
            left: 16,
            right: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatarView(
                      size: 25,
                      user: widget.reel.user,
                      hideOnlineIndicator: true,
                    ).ripple(() {
    openProfile();
    }),
                    const SizedBox(
                      width: 10,
                    ),
                    BodyLargeText(
                      widget.reel.user.userName,
                      weight: TextWeight.medium,
                      color: AppColorConstants.whiteClr,
                    ).ripple(() {
                      openProfile();
                    }),
                    widget.reel.user.isVerified == false
                        ? const SizedBox.shrink()
                        : Image.asset(
                            'assets/verified.png',
                            height: 15,
                            width: 15,
                          ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 10),
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://yapori.in/backend/web/flags/${widget.reel.user.country.toString().toLowerCase().replaceAll(' ', '-')}.jpg',
                        fit: BoxFit.cover,
                        height: 20,
                        width: 30,
                        placeholder: (context, url) => SizedBox(
                            height: 20,
                            width: 20,
                            child: const CircularProgressIndicator().p16),
                        errorWidget: (context, url, error) => SizedBox(
                            height: 20,
                            width: 30,
                            child: Icon(
                              Icons.error,
                              size: 30 / 2,
                              color: AppColorConstants.iconColor,
                            )),
                      ),
                    ),

                    // if (widget.reel.user.isMe == false)
                    // // widget.model.user.isFollower == false ?
                    // // getFollowButton(),
                    // //     == true ?
                    widget.reel.user.isMe == false
                        ? enableFollowButton == false &&
                                followButtonPressed == false
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: SizedBox(
                                    height: 25,
                                    // width: 80,
                                    child: AppThemeBorderButton(
                                        // icon: ThemeIcon.message,
                                        text:
                                            widget.reel.user.isFollower == true
                                                ? LocalizationString.followBack
                                                : LocalizationString.follow,
                                        borderColor:
                                            AppColorConstants.themeColor,
                                        textStyle: TextStyle(
                                            fontSize: FontSizes.b4,
                                            fontWeight: TextWeight.medium,
                                            color:
                                                AppColorConstants.themeColor),
                                        onPress: () async {
                                          print(
                                              "onPress enableFollowButton : $enableFollowButton");
                                          setState(() {
                                            enableFollowButton = false;
                                            followButtonPressed = true;
                                            // commentAndLikeWidget(widget.reel.user.id);
                                          });
                                          await exploreController
                                              .followUser(widget.reel.user)
                                              .then((res) {
                                            // loadData();
                                           _reelsController.getReels();

                                            setState(() {});
                                          });
                                        })),
                              )
                            : const SizedBox.shrink()
                        : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (widget.reel.title.isNotEmpty)
                  Column(
                    children: [
                      BodyLargeText(
                        widget.reel.title,
                        weight: TextWeight.medium,
                        color: AppColorConstants.whiteClr,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                SizedBox(
                    width: Get.width * 0.5,
                    height: 25,
                    child: Row(
                      children: [
                        ThemeIconWidget(
                          ThemeIcon.music,
                          size: 15,
                          color: AppColorConstants.whiteClr,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          // width: Get.width * 0.5,
                          child: BodyMediumText(
                            widget.reel.audio == null
                                ? LocalizationString.originalAudio
                                : widget.reel.audio!.name,
                            weight: TextWeight.medium,
                            color: AppColorConstants.whiteClr,
                          ),
                        ),
                      ],
                    ).ripple(() {
                      if (widget.reel.audio != null) {
                        Get.to(() => ReelAudioDetail(
                              audio: widget.reel.audio!,
                            ));
                      }
                    })),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: BodyMediumText(
                    '${widget.reel.totalView} ${LocalizationString.views}',
                    color: AppColorConstants.whiteClr,
                    fSize: 12,
                  ),
                )
              ],
            )),
        Positioned(
            bottom: 180,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Column(
                  children: [
                    Obx(() => InkWell(
                        onLongPress: () {
                          setState(() {
                            showReact = !showReact;
                          });


                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {
                              showReact = false;
                            });
                          });
                        },
                        onTap: () {
                          _reelsController.likeUnlikeReel(
                              post: widget.reel, context: context);
                          // widget.likeTapHandler();
                        },
                        child: ThemeIconWidget(
                          _reelsController.likedReels.contains(widget.reel) ||
                                  widget.reel.isLike
                              ? ThemeIcon.favFilled
                              : ThemeIcon.fav,
                          color: _reelsController.likedReels
                                      .contains(widget.reel) ||
                                  widget.reel.isLike
                              ? AppColorConstants.red
                              :
                              //AppColorConstants.iconColor
                              AppColorConstants.whiteClr,
                        ))),
                    const SizedBox(
                      height: 5,
                    ),
                    // Obx(() {
                    // int totalLikes = 0;
                    // if (_reelsController.likedReels.contains(widget.reel)) {
                    //   PostModel post = _reelsController.likedReels
                    //       .where((e) => e.id == widget.reel.id)
                    //       .first;
                    //   // totalLikes = post.totalLike;
                    // } else {
                    //   // totalLikes = widget.reel.totalLike;
                    // }
                    BodyMediumText(
                      '${widget.reel.totalLike}',
                      color: AppColorConstants.whiteClr,
                    ),

                    // }),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    ThemeIconWidget(
                      ThemeIcon.message,
                      size: 25,
                      color: AppColorConstants.whiteClr,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    BodyMediumText(
                      widget.reel.totalComment.formatNumber,
                      color: AppColorConstants.whiteClr,
                    )
                  ],
                ).ripple(() {
                  openComments();
                }),
                const SizedBox(
                  height: 20,
                ),
                // const ThemeIconWidget(
                //   ThemeIcon.send,
                //   size: 20,
                // ),
                // const SizedBox(
                //   height: 20,
                // ),
                ThemeIconWidget(
                  ThemeIcon.share,
                  color: AppColorConstants.whiteClr,
                ).ripple(() {
                  showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) =>
                          SelectFollowingUserForMessageSending(
                            post: widget.reel.gallery[0],
                            sendToUserCallback: (user) {
                              selectUserForChatController.sendMessage(
                                  toUser: user, post: widget.reel);
                            },
                            show: true,
                              isClips: true
                          ));
                }),
                if (widget.reel.audio != null)
                  CachedNetworkImage(
                          height: 25,
                          width: 25,
                          imageUrl: widget.reel.audio!.thumbnail)
                      .borderWithRadius(value: 1, radius: 5)
                      .ripple(() {
                    if (widget.reel.audio != null) {
                      Get.to(() => ReelAudioDetail(audio: widget.reel.audio!));
                    }
                  })
              ],
            )),
        Positioned(
          bottom: 250,
          child: showReact
    ? Container(
            // color: AppColorConstants.whiteClr.withOpacity(0.7),
            // height: 80,
            width: MediaQuery.of(context).size.width,
            child:  EmojiFeedback(
              showLabel: false,
              // emojiPreset: [],
              animDuration: const Duration(milliseconds: 300),
              curve: Curves.bounceIn,
              inactiveElementScale: .7,
              elementSize: 32,
              inactiveElementBlendColor: Colors.white,
              onChanged: (value) {
                String emoji = '';
                if(value == 1) {
                  emoji = '😖';
                }else if(value == 2){
                  emoji = '😞';
                }
                else if(value == 3){
                  emoji = '🙂';
                }
                else if(value == 4){
                  emoji = '😄';
                }
                else {
                  emoji = '😍';
                }
                print('this is emoji feedback val $value');
                postCardController.reactOnPost(
                    post: widget.reel, context: context, emoji: emoji.toString());
                // postCardController.likeUnlikePost(
                //     post: widget.model, context: context);
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    showReact = false;
                  });
                });

                print(value);
              },
            )

          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  prepareVideo({required String url}) {
    if (videoPlayerController != null) {
      videoPlayerController!.pause();
    }
    print('this is video url $url');
    videoPlayerController = VideoPlayerController.network(url);

    initializeVideoPlayerFuture = videoPlayerController!.initialize().then((_) {
      setState(() {});

      if (playVideo == true) {
        play();
      } else {
        pause();
      }
    });

    // videoPlayerController!.addListener(checkVideoProgress);
  }

  play() {
    videoPlayerController!.play().then((value) => {
          // videoPlayerController!.addListener(checkVideoProgress)
        });
  }

  openComments() {
    Get.bottomSheet(CommentPopUp(
      isPopup: true,
      model: widget.reel,
      commentPostedCallback: () {
        setState(() {
          widget.reel.totalComment += 1;
        });
      },
    ));
  }

  pause() {
    videoPlayerController!.pause();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // isFreeTimePlayed = true;
      });
    });
  }

  clear() {
    videoPlayerController!.pause();
    videoPlayerController!.dispose();
    // videoPlayerController!.removeListener(checkVideoProgress);
  }
}

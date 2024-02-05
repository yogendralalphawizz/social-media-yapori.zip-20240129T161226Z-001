import 'package:carousel_slider/carousel_slider.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart';
import 'package:foap/components/post_card_controller.dart';
import 'package:foap/components/video_widget.dart';
import 'package:foap/controllers/explore_controller.dart';
import 'package:foap/controllers/profile_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/club_model.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../apiHandler/api_controller.dart';
import '../controllers/chat_and_call/chat_detail_controller.dart';
import '../controllers/chat_and_call/select_user_for_chat_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/user_network_controller.dart';
import '../model/post_gallery.dart';
import '../model/post_model.dart';
import '../screens/chat/select_users.dart';
import '../screens/club/club_detail.dart';
import '../screens/home_feed/comments_screen.dart';
import '../screens/home_feed/post_media_full_screen.dart';
import '../screens/profile/follower_following_list.dart';
import '../screens/profile/my_profile.dart';
import '../screens/profile/other_user_profile.dart';

class PostMediaTile extends StatelessWidget {
  final PostCardController postCardController = Get.find();

  final HomeController homeController = Get.find();
  final PostModel model;
  final bool isScene;
  final bool isHome;
  final RxBool play;
  PostMediaTile(
      {Key? key,
      required this.model,
      required this.isScene,
      required this.isHome,
      required this.play})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isScene) {
      return mediaTileScene(context);
    } else {
      return mediaTile(context);
    }
  }

  Widget mediaTile(BuildContext context) {
    if (model.gallery.length > 1) {
      return SizedBox(
        // height: 350,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            CarouselSlider(
              items: mediaList(),
              options: CarouselOptions(
                aspectRatio: 1,
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
                height: double.infinity,
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  postCardController.updateGallerySlider(index, model.id);
                },
              ),
            ),
            Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Obx(
                    () {
                      return DotsIndicator(
                        dotsCount: model.gallery.length,
                        position: (postCardController
                                    .postScrollIndexMapping[model.id] ??
                                0)
                            .toDouble(),
                        decorator: DotsDecorator(
                            activeColor: Theme.of(Get.context!).primaryColor),
                      );
                    },
                  ),
                ))
          ],
        ),
      );
    } else {
      return model.gallery.first.isVideoPost == true
          ? videoPostTile(model.gallery.first)
          : SizedBox(
              // height: 350,
              child: photoPostTile(model.gallery.first));
    }
  }

  Widget mediaTileScene(BuildContext context) {
    return
        // model.gallery.first.isVideoPost == true
        //   ?
        videoPostTile(model.gallery.first);

    // : SizedBox(height: 350, child: photoPostTile(model.gallery.first));
    // if (model.gallery.length > 1) {
    //   return SizedBox(
    //     height: 350,
    //     width: MediaQuery.of(context).size.width,
    //     child: Stack(
    //       children: [
    //         CarouselSlider(
    //           items: mediaList(),
    //           options: CarouselOptions(
    //             aspectRatio: 1,
    //             enlargeCenterPage: false,
    //             enableInfiniteScroll: false,
    //             height: double.infinity,
    //             viewportFraction: 1,
    //             onPageChanged: (index, reason) {
    //               postCardController.updateGallerySlider(index, model.id);
    //             },
    //           ),
    //         ),
    //         Positioned(
    //             bottom: 10,
    //             left: 0,
    //             right: 0,
    //             child: Align(
    //               alignment: Alignment.center,
    //               child: Obx(
    //                     () {
    //                   return DotsIndicator(
    //                     dotsCount: model.gallery.length,
    //                     position: (postCardController
    //                         .postScrollIndexMapping[model.id] ??
    //                         0)
    //                         .toDouble(),
    //                     decorator: DotsDecorator(
    //                         activeColor: Theme.of(Get.context!).primaryColor),
    //                   );
    //                 },
    //               ),
    //             ))
    //       ],
    //     ),
    //   );
    // } else {
    //   return
    //     isScene?
    //     model.gallery.first.isVideoPost == true
    //         ? videoPostTile(model.gallery.first)
    //         : SizedBox(height: 350, child: photoPostTile(model.gallery.first))
    //         : SizedBox(height: 350, child: photoPostTile(model.gallery.first));
    // }
  }

  List<Widget> mediaList() {
    return model.gallery.map((item) {
      if (item.isVideoPost == true) {
        return videoPostTile(item);
      } else {
        return photoPostTile(item);
      }
    }).toList();
  }

  Widget videoPostTile(PostGallery media) {
    return VisibilityDetector(
      key: Key(media.id.toString()),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 80;
        // if (visiblePercentage > 80) {
        homeController.setCurrentVisibleVideo(
            media: media, visibility: visiblePercentage);
        // }
      },
      child: Obx(() => VideoPostTile(
            url: media.filePath,
            isLocalFile: false,
            isHome: isHome,
            play: play.value
            // play: homeController.currentVisibleVideoId.value == media.id,
          )),
    );
  }

  Widget photoPostTile(PostGallery media) {
    return CachedNetworkImage(
      imageUrl: media.filePath,
      fit: BoxFit.cover,
      width: Get.width,
      placeholder: (context, url) => AppUtil.addProgressIndicator(size: 100),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}

class PostCard extends StatefulWidget {
  final PostModel model;
  final bool isScene;
  final bool isClub;
  final bool isHome;
  final ClubModel? club;
  final Function(String) textTapHandler;
  final VoidCallback removePostHandler;
  final VoidCallback blockUserHandler;
  final VoidCallback viewInsightHandler;
  final VoidCallback? followButtonHandler;

  const PostCard({
    Key? key,
    required this.model,
    required this.isScene,
    required this.isClub,
    required this.isHome,
    this.club,
    required this.textTapHandler,
    required this.removePostHandler,
    required this.blockUserHandler,
    required this.viewInsightHandler,
    this.followButtonHandler,
  }) : super(key: key);

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  final HomeController homeController = Get.find();
  final PostCardController postCardController = Get.find();
  final ChatDetailController chatDetailController = Get.find();
  final ExploreController exploreController = ExploreController();
  final SelectUserForChatController selectUserForChatController =
      SelectUserForChatController();
  final ProfileController _profileController = Get.find();

  final FlareControls flareControls = FlareControls();
  bool enableFollowButton = true;
  bool followButtonPressed = true;
  String country = '';
  String flagUrl = '';
  RxBool play = false.obs;

  @override
  void initState() {
    super.initState();
    loadData();

    flagUrl = '';
  }

  @override
  Widget build(BuildContext context) {
    flagUrl =
        'https://yapori.in/backend/web/flags/${widget.model.user.country.toString().toLowerCase().replaceAll(' ', '-')}.jpg';
    // String countryName = widget.model.user.country.toString().toLowerCase();
    // country = countryName.replaceAll(' ', '-');
    print('this is users current country ${widget.model.user.country.toString()}');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      addPostUserInfo().setPadding(left: 16, right: 16, bottom: 8),
      if (widget.model.title.isNotEmpty)
        _convertHashtag(widget.model.title)
            .hp(DesignConstants.horizontalPadding),
      if (widget.model.title.isNotEmpty)
        const SizedBox(
          height: 20,
        ),
      GestureDetector(
          onLongPress: () {
            setState(() {
              showReact = !showReact;
            });
            widget.model.gallery.first.isVideoPost == true
                ? Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          PostMediaFullScreen(post: widget.model),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),)
                : null;
          },
          onDoubleTap: () {
            //   widget.model.isLike = !widget.model.isLike;
            postCardController.likeUnlikePost(
                post: widget.model, context: context);
            // widget.likeTapHandler();
            flareControls.play("like");
          },
          onTap: () {
            setState(() {
              play.value = !play.value;
            });
            // if(homeController.currentVisibleVideoId.value == widget.model.gallery.first.id) {
            //   homeController.currentVisibleVideoId.value ==
            //       0;
            //   print('111----');
            //
            // }else{
            //   homeController.currentVisibleVideoId.value ==
            //       widget.model.gallery.first.id;
            //   print('workiung here!');
            //
            // }
            // homeController.setCurrentVisibleVideo(
            //     media: widget.model.gallery.first, visibility: 100);
            // widget.model.gallery.first.isVideoPost == false ?
            // Navigator.push(
            //   context,
            //   PageRouteBuilder(
            //     pageBuilder: (context, animation1, animation2) =>
            //         PostMediaFullScreen(post: widget.model),
            //     transitionDuration: Duration.zero,
            //     reverseTransitionDuration: Duration.zero,
            //   ),
            // );
            // : null;

            // widget.mediaTapHandler(widget.model);
          },
          child: Stack(
            children: [
              Column(
                children: [
                  PostMediaTile(
                      model: widget.model,
                      isScene: widget.isScene,
                      isHome: widget.isHome,
                      play: play),
                ],
              ),
              Obx(() => Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: FlareActor(
                              'assets/like.flr',
                              controller: flareControls,
                              animation: 'idle',
                              color: postCardController.likedPosts
                                          .contains(widget.model) ||
                                      widget.model.isLike
                                  ? Colors.red
                                  : Colors.white,
                            ),
                          ),
                        )),
                  ))
            ],
          )),
      const SizedBox(
        height: 10,
      ),
      commentAndLikeWidget(widget.model.user.id).hP16,
    ]).vP16;
  }

  final UserNetworkController _userNetworkController = UserNetworkController();
  final UserProfileManager _userProfileManager = Get.find();

  bool showFlag = false;
  loadData() async {
    _userNetworkController.clear();
    _userNetworkController
        .getFollowingUsers(_userProfileManager.user.value!.id);
    await ApiController()
        .viewCounter(widget.model.id)
        .then((response) async {});
  }

  bool isUserFollower() {
    bool res = false;
    _userNetworkController
        .getFollowingUsers(_userProfileManager.user.value!.id);
    for (var element in followerList) {
      if (element.id == widget.model.user.id) {
        res = true;
        break;
      }
    }
    if (!res) followButtonPressed = false;
    return res;
  }

  bool showReact = false;

  String formatNumber(int number) {
    if (number >= 1000) {
      double result = number / 1000;
      return '${result.toStringAsFixed(1)}k';
    } else {
      return number.toString();
    }
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
    setState(() {
      svgString = svgData;
    });
  }

  Widget commentAndLikeWidget(int userId) {
    setState(() {
      enableFollowButton = isUserFollower();
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showReact
            ? EmojiFeedback(
                showLabel: false,
                // emojiPreset: [],
                animDuration: const Duration(milliseconds: 300),
                curve: Curves.bounceIn,
                inactiveElementScale: .7,
                elementSize: 32,
                inactiveElementBlendColor: Colors.white,
                onChanged: (value) {
                  String emoji = '';
                  // convertSVGToString(value.toString());
                  print('this is emoji feedback val $value');
                  if (value == 1) {
                    emoji = '😖';
                  } else if (value == 2) {
                    emoji = '😞';
                  } else if (value == 3) {
                    emoji = '🙂';
                  } else if (value == 4) {
                    emoji = '😄';
                  } else {
                    emoji = '😍';
                  }

                  postCardController.reactOnPost(
                      post: widget.model,
                      context: context,
                      emoji: emoji.toString());
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
            : const SizedBox.shrink(),
        const SizedBox(
          height: 5,
        ),

        // Container(
        //     height: 200,
        //     width: double.infinity,
        //     child: FbReaction()),
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
          Obx(() => InkWell(
              onLongPress: () {
                setState(() {
                  showReact = !showReact;
                });
              },
              onTap: () {
                postCardController.likeUnlikePost(
                    post: widget.model, context: context);
                // widget.likeTapHandler();
              },
              child: ThemeIconWidget(
                postCardController.likedPosts.contains(widget.model) ||
                        widget.model.isLike
                    ? ThemeIcon.favFilled
                    : ThemeIcon.fav,
                color: postCardController.likedPosts.contains(widget.model) ||
                        widget.model.isLike
                    ? AppColorConstants.red
                    : AppColorConstants.themeColor,
              ))),
          const SizedBox(
            width: 5,
          ),
          Obx(() {
            int totalLikes = 0;
            if (postCardController.likedPosts.contains(widget.model)) {
              PostModel post = postCardController.likedPosts
                  .where((e) => e.id == widget.model.id)
                  .first;
              totalLikes = post.totalLike;
            } else {
              totalLikes = widget.model.totalLike;
            }
            return totalLikes > 0
                ? BodyExtraSmallText(
                    formatNumber(widget.model.totalLike).toString(),
                    // '${widget.model.totalLike}',
                    weight: TextWeight.regular,
                  )
                : Container();
          }),
          const SizedBox(
            width: 10,
          ),
          InkWell(
              onTap: () => openComments(),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                ThemeIconWidget(
                  ThemeIcon.message,
                  color: AppColorConstants.iconColor,
                ),
                const SizedBox(
                  width: 5,
                ),
                widget.model.totalComment > 0
                    ? BodyExtraSmallText(
                            formatNumber(widget.model.totalComment).toString(),
                            // '${widget.model.totalComment}',
                            weight: TextWeight.regular)
                        .ripple(() {
                        openComments();
                      })
                    : Container(),
              ])),
          const SizedBox(
            width: 10,
          ),
          ThemeIconWidget(
            ThemeIcon.share,
            color: AppColorConstants.iconColor,
          ).ripple(() {
            showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => SelectFollowingUserForMessageSending(
                    post: widget.model.gallery[0],
                    sendToUserCallback: (user) {
                      selectUserForChatController.sendMessage(
                        toUser: user,
                        post: widget.model,
                      );
                    },
                    show: true,
                    isClips: false));
          }),
          const SizedBox(
            width: 5,
          ),
          widget.model.totalShare > 0
              ? BodyExtraSmallText(
                      formatNumber(widget.model.totalShare).toString(),
                      // '${widget.model.totalComment}',
                      weight: TextWeight.regular)
                  .ripple(() {})
              : Container(),
          Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
              ),
              child:
                  // widget.model.totalView > 0
                  //     ?
                  BodyExtraSmallText(
                          '${formatNumber(widget.model.totalView).toString()} views',
                          // '${widget.model.totalComment}',
                          weight: TextWeight.semiBold)
                      .ripple(() {})
              // : Container(),
              ),
          if (widget.model.user.isMe == false)
            // widget.model.user.isFollower == false ?
            // getFollowButton(),
            //     == true ?
            enableFollowButton == false && followButtonPressed == false
                ? Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: SizedBox(
                        height: 20,
                        // width: 80,
                        child: AppThemeBorderButton(
                            // icon: ThemeIcon.message,x
                            text: widget.model.user.isFollower == true
                                ? LocalizationString.followBack
                                : LocalizationString.follow,
                            borderColor: AppColorConstants.themeColor,
                            textStyle: TextStyle(
                                fontSize: FontSizes.b4,
                                fontWeight: TextWeight.medium,
                                color: AppColorConstants.themeColor),
                            onPress: () async {
                              enableFollowButton = false;
                              followButtonPressed = true;

                              await exploreController
                                  .followUser(widget.model.user)
                                  .then((res) {
                                loadData();
                                homeController.getPosts(
                                    isRecent: true, callback: () {});

                                setState(() {});
                              });
                            })),
                  )
                : const SizedBox.shrink(),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ThemeIconWidget(
                ThemeIcon.clock,
                size: 15,
              ),
              const SizedBox(width: 5),
              BodySmallText(widget.model.postTime.tr,
                  weight: TextWeight.regular),
            ],
          )
        ]),
      ],
    );
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
                  text: widget.model.user.isFollower == true
                      ? LocalizationString.followBack
                      : LocalizationString.follow,
                  textStyle: TextStyle(
                      fontSize: FontSizes.b2,
                      fontWeight: TextWeight.medium,
                      color: AppColorConstants.themeColor),
                  onPress: () {
                    exploreController.followUser(widget.model.user);
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

  Widget addPostUserInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            height: 35,
            width: 35,
            child: UserAvatarView(
              size: 35,
              user: widget.model.user,
              onTapHandler: () {
                openProfile();
              },
            )),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.model.user.userName,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColorConstants.grayscale900,
                            fontWeight: TextWeight.bold))
                    .ripple(() {
                  openProfile();
                }),
                // BodyMediumText(
                //   widget.model.user.userName,
                //   weight: TextWeight.medium,
                // ).ripple(() {
                //   openProfile();
                // }),

                widget.model.user.isVerified == false
                    ? const SizedBox.shrink()
                    : Image.asset(
                        'assets/verified.png',
                        height: 12,
                        width: 12,
                      ),
                if (widget.model.club != null)
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4.3,
                    child: Text(' ${widget.model.club!.name}',
                            textAlign: TextAlign.left,
                            // overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: FontSizes.b5,
                                // overflow: TextOverflow.ellipsis,
                                color: AppColorConstants.themeColor,
                                fontWeight: TextWeight.medium))
                        .ripple(() {
                      openClubDetail();
                    }),
                  ),
                Spacer(),

                Padding(
                  padding: const EdgeInsets.only(right: 5.0, top: 7),
                  child: CachedNetworkImage(
                    imageUrl: flagUrl,
                    fit: BoxFit.cover,
                    height: 18,
                    width: 25,
                    placeholder: (context, url) => SizedBox(
                        height: 20,
                        width: 20,
                        child: const CircularProgressIndicator().p16),
                    errorWidget: (context, url, error) => Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: SizedBox(
                          height: 18,
                          width: 25,
                          child: Icon(
                            Icons.error,
                            size: 30 / 2,
                            color: AppColorConstants.iconColor,
                          )),
                    ),
                  ),
                )

                // .borderWithRadius(
                // value: 1,
                // radius: 40 / 3,
                // color: AppColorConstants.themeColor)
              ],
            ),
            widget.model.user.profileCategoryTypeName != ''
                ? BodyExtraSmallText(
                    widget.model.user.profileCategoryTypeName,
                  )
                : Container()
          ],
        )),
        SizedBox(
          height: 17,
          width: 17,
          child: ThemeIconWidget(
            ThemeIcon.more,
            color: AppColorConstants.iconColor,
            size: 13,
          ),
        ).borderWithRadius(value: 1, radius: 15).ripple(() {
          openActionPopup();
        })
      ],
    );
  }

  Widget _convertHashtag(String text) {
    List<String> split = text.split(' ');

    if (text == 'Repost') {
      return Row(
        children: [
          ImageIcon(
            AssetImage('assets/images/share.png'),
            size: 18,
            color: AppColorConstants.iconColor,
          ),
          Text(
            ' Shared Post',
            style: TextStyle(
                color: AppColorConstants.grayscale900,
                fontWeight: FontWeight.w400),
          ),
        ],
      );
    }
    return RichText(
        text: TextSpan(children: [
      // TextSpan(
      //   text: '${widget.model.user.userName}  ',
      //   style: TextStyle(
      //       color: AppColorConstants.grayscale900, fontWeight: FontWeight.w900),
      //   recognizer: TapGestureRecognizer()
      //     ..onTap = () {
      //       openProfile();
      //     },
      // ),
      for (String text in split)
        text.startsWith('#')
            ? TextSpan(
                text: '$text ',
                style: TextStyle(
                    color: AppColorConstants.themeColor,
                    fontWeight: FontWeight.w700),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    widget.textTapHandler(text);
                  },
              )
            : text.startsWith('@')
                ? TextSpan(
                    text: '$text ',
                    style: TextStyle(
                        color: AppColorConstants.themeColor,
                        fontWeight: FontWeight.w700),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        widget.textTapHandler(text);
                      },
                  )
                : text.toString() == 'Repost'
                    ? TextSpan(
                        text: '',
                        style: TextStyle(
                            color: AppColorConstants.themeColor,
                            fontWeight: FontWeight.w700),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            widget.textTapHandler(text);
                          },
                      )
                    : TextSpan(
                        text: '$text ',
                        style: TextStyle(
                            color: AppColorConstants.grayscale900,
                            fontWeight: FontWeight.w400))
    ]));
  }

  void openActionPopup() {
    Get.bottomSheet(Container(
      color: AppColorConstants.cardColor.darken(),
      child: widget.isClub
          ? widget.club!.amIAdmin
              ? Wrap(
                  children: [
                    ListTile(
                        title: Center(
                            child: Heading6Text(
                          LocalizationString.deletePost,
                          weight: TextWeight.bold,
                        )),
                        onTap: () async {
                          Get.back();
                          postCardController.deletePost(
                              post: widget.model,
                              context: context,
                              callback: () {
                                widget.removePostHandler();
                              },
                              isClubOwner: true,
                              clubId: widget.club!.id!);
                        }),
                    divider(context: context),
                    ListTile(
                        title: Center(
                            child: BodyLargeText(LocalizationString.cancel)),
                        onTap: () => Get.back()),
                    const SizedBox(
                      height: 25,
                    )
                  ],
                )
              : widget.model.user.isMe
                  ? Wrap(
                      children: [
                        ListTile(
                            title: Center(
                                child: Heading6Text(
                              LocalizationString.deletePost,
                              weight: TextWeight.bold,
                            )),
                            onTap: () async {
                              Get.back();
                              postCardController.deletePost(
                                  post: widget.model,
                                  context: context,
                                  callback: () {
                                    widget.removePostHandler();
                                  },
                                  isClubOwner: false,
                                  clubId: widget.club!.id!);
                            }),
                        divider(context: context),
                        ListTile(
                            title: Center(
                                child:
                                    BodyLargeText(LocalizationString.cancel)),
                            onTap: () => Get.back()),
                        const SizedBox(
                          height: 25,
                        )
                      ],
                    )
                  : Wrap(
                      children: [
                        ListTile(
                            title: Center(
                                child: Heading6Text(
                              LocalizationString.report,
                              weight: TextWeight.bold,
                            )),
                            onTap: () async {
                              Get.back();

                              AppUtil.showConfirmationAlert(
                                  title: LocalizationString.report,
                                  subTitle:
                                      LocalizationString.areYouSureToReportPost,
                                  okHandler: () {
                                    postCardController.reportPost(
                                        post: widget.model,
                                        context: context,
                                        callback: () {
                                          widget.removePostHandler();
                                        });
                                  });
                            }),
                        divider(context: context),
                        ListTile(
                            title: Center(
                                child: Heading6Text(
                                    LocalizationString.blockUser,
                                    weight: TextWeight.bold)),
                            onTap: () async {
                              Get.back();
                              AppUtil.showConfirmationAlert(
                                  title: LocalizationString.block,
                                  subTitle:
                                      LocalizationString.areYouSureToBlockUser,
                                  okHandler: () {
                                    postCardController.blockUser(
                                        userId: widget.model.user.id,
                                        callback: () {
                                          widget.blockUserHandler();
                                        });
                                  });
                            }),
                        divider(context: context),
                        ListTile(
                            title: Center(
                              child: Heading6Text(
                                LocalizationString.cancel,
                                weight: TextWeight.regular,
                                color: AppColorConstants.red,
                              ),
                            ),
                            onTap: () => Get.back()),
                        const SizedBox(
                          height: 25,
                        )
                      ],
                    )
          : widget.model.user.isMe
              ? Wrap(
                  children: [
                    ListTile(
                        title: Center(
                            child: Heading6Text(
                          LocalizationString.deletePost,
                          weight: TextWeight.bold,
                        )),
                        onTap: () async {
                          Get.back();
                          postCardController.deletePost(
                              post: widget.model,
                              context: context,
                              callback: () {
                                widget.removePostHandler();
                              },
                              isClubOwner: false,
                              clubId: 0);
                        }),
                    divider(context: context),
                    ListTile(
                        title: Center(
                            child: BodyLargeText(LocalizationString.cancel)),
                        onTap: () => Get.back()),
                    const SizedBox(
                      height: 25,
                    )
                  ],
                )
              : Wrap(
                  children: [
                    ListTile(
                        title: Center(
                            child: Heading6Text(
                          LocalizationString.report,
                          weight: TextWeight.bold,
                        )),
                        onTap: () async {
                          Get.back();

                          AppUtil.showConfirmationAlert(
                              title: LocalizationString.report,
                              subTitle:
                                  LocalizationString.areYouSureToReportPost,
                              okHandler: () {
                                postCardController.reportPost(
                                    post: widget.model,
                                    context: context,
                                    callback: () {
                                      widget.removePostHandler();
                                    });
                              });
                        }),
                    divider(context: context),
                    ListTile(
                        title: Center(
                            child: Heading6Text(LocalizationString.blockUser,
                                weight: TextWeight.bold)),
                        onTap: () async {
                          Get.back();
                          AppUtil.showConfirmationAlert(
                              title: LocalizationString.block,
                              subTitle:
                                  LocalizationString.areYouSureToBlockUser,
                              okHandler: () {
                                postCardController.blockUser(
                                    userId: widget.model.user.id,
                                    callback: () {
                                      widget.blockUserHandler();
                                    });
                              });
                        }),
                    divider(context: context),
                    ListTile(
                        title: Center(
                          child: Heading6Text(
                            LocalizationString.cancel,
                            weight: TextWeight.regular,
                            color: AppColorConstants.red,
                          ),
                        ),
                        onTap: () => Get.back()),
                    const SizedBox(
                      height: 25,
                    )
                  ],
                ),
    ).round(40));
  }

  void openComments() {
    Get.bottomSheet(CommentPopUp(
      isPopup: true,
      model: widget.model,
      commentPostedCallback: () {
        setState(() {
          widget.model.totalComment += 1;
        });
      },
    ).round(40));
  }

  void openProfile() async {
    if (widget.model.user.isMe) {
      Get.to(() => const MyProfile(
            showBack: true,
          ));
    } else {
      _profileController.otherUserProfileView(
          refId: widget.model.id, sourceType: 1);
      Get.to(() => OtherUserProfile(userId: widget.model.user.id));
    }
  }

  void openClubDetail() async {
    Get.to(() => ClubDetail(
        club: widget.model.club!,
        needRefreshCallback: () {},
        deleteCallback: (club) {}));
  }
}

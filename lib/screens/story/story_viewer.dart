import 'dart:async';

import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart';
import 'package:foap/components/post_card_controller.dart';
import 'package:foap/controllers/chat_and_call/chat_detail_controller.dart';
import 'package:foap/controllers/comments_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';
import 'package:foap/screens/chat/chat_detail.dart';
import 'package:get/get.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:story_view/utils.dart';

import '../../universal_components/rounded_input_field.dart';
import '../profile/my_profile.dart';
import '../profile/other_user_profile.dart';
import '../settings_menu/settings_controller.dart';

class StoryViewer extends StatefulWidget {
  final StoryModel story;
  final VoidCallback storyDeleted;

  const StoryViewer({Key? key, required this.story, required this.storyDeleted})
      : super(key: key);

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  final controller = StoryController();
  final AppStoryController storyController = AppStoryController();
  final SettingsController settingsController = Get.find();
  final PostCardController postCardController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();
  TextEditingController commentInputField = TextEditingController();
  final CommentsController _commentsController = CommentsController();
  final ChatDetailController _chatDetailController = Get.find();
  bool showReact = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [

          storyWidget(),
          widget.story.userName == _userProfileManager.user.value!.userName ?
          const SizedBox.shrink() :
          buildMessageTextField()
        ],
      ),

    );
  }

  Widget storyWidget() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        StoryView(
            storyItems: [
              for (StoryMediaModel media in widget.story.media.reversed)
                media.isVideoPost() == true
                    ?
                StoryItem.pageVideo(
                        media.image!,
                        controller: controller,
                        duration: Duration(
                            seconds: int.parse(settingsController
                                .setting.value!.maximumVideoDurationAllowed!)),
                        key: Key(media.id.toString()),
                      )
                    :
                StoryItem.pageImage(
                        key: Key(media.id.toString()),
                        url: media.image!,
                        controller: controller,
                  duration: const Duration(
                    seconds: 5
                  )
                      ),
            ],
            controller: controller,
            // pass controller here too
            repeat: true,
            // should the stories be slid forever
            onStoryShow: (s) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                storyController.setCurrentStoryMedia(widget.story.media
                    .where(
                        (element) => Key(element.id.toString()) == s.view.key)
                    .first);
              });
            },
            onComplete: () {
              Get.back();
            },
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                Get.back();
              }
            } // To disable vertical swipe gestures, ignore this parameter.
            // Preferrably for inline story view.
            ),
        Positioned(top: 70, left: 20, right: 0, child: userProfileView()),
        widget.story.userName == _userProfileManager.user.value!.userName ?
        const SizedBox.shrink()
       :  showReact ?
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height - 140),
          child: EmojiFeedback(
            showLabel: false,
            animDuration: const Duration(milliseconds: 300),
            curve: Curves.bounceIn,
            inactiveElementScale: .7,
            // elementSize: 20,
            inactiveElementBlendColor: Colors.white,
            onChanged: (value) {
              String emoji = '';
              // convertSVGToString(value.toString());
              print('this is emoji feedback val $value');
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

              // postCardController.reactOnPost(
              //     post: widget.story.id, context: context, emoji: emoji.toString());
              // postCardController.likeUnlikePost(
              //     post: widget.model, context: context);
              Future.delayed(const Duration(seconds: 2), () {
                setState(() {
                  showReact = false;
                });
              });
            },
          ),
        )
            : const SizedBox.shrink()
        // Positioned(bottom: 0, left: 0, right: 0, child: replyView()),
      ],
    );
  }
  Widget buildMessageTextField() {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: AppColorConstants.whiteClr,
        borderRadius: BorderRadius.circular(15)
      ),

      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Obx(() {
                commentInputField.value = TextEditingValue(
                    text: _commentsController.searchText.value,
                    selection: TextSelection.fromPosition(
                        TextPosition(offset: _commentsController.position.value)));

                return TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: commentInputField,
                  onChanged: (text) {
                    _commentsController.textChanged(
                        text, commentInputField.selection.baseOffset);
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: LocalizationString.writeComment,
                    hintStyle: TextStyle(
                        fontSize: FontSizes.h6,
                        color: AppColorConstants.grayscale700),
                  ),
                  textInputAction: TextInputAction.send,
                  style: TextStyle(
                      fontSize: FontSizes.h6,
                      color: AppColorConstants.grayscale900),
                  onSubmitted: (_) {
                    // addNewMessage();
                  },
                  onTap: () {
                    // Timer(
                    //     const Duration(milliseconds: 300),
                    //         () => _controller
                    //         .jumpTo(_controller.position.maxScrollExtent));
                  },
                ).hP8;
              }).borderWithRadius(value: 0.5, radius: 25)),
          SizedBox(
            width: 50.0,
            child: InkWell(
              onTap: (){
                _chatDetailController.getChatRoomWithUser(
                    userId: widget.story.id,
                    callback: (room) {
                      EasyLoading.dismiss();
                      _chatDetailController.sendTextMessage(
                          messageText: commentInputField.text.toString(),
                          fromStory: true,
                          mode: ChatMessageActionMode.none,
                          room: room);
                      Get.close(1);
                      Future.delayed(const Duration(seconds: 1), (){
                        Get.to(() => ChatDetail(
                          // opponent: usersList[index - 1].toChatRoomMember,
                          chatRoom: room,
                        ));
                      });

                    });

              },
              child: Icon(
                Icons.send,
                color: AppColorConstants.themeColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget replyWidget() {
    return FooterLayout(
      footer: KeyboardAttachable(
        // backgroundColor: Colors.blue,
        child: Container(
          height: 60,
          color: AppColorConstants.themeColor,
          child: Row(
            children: [
              Expanded(
                child: InputField(
                  hintText: LocalizationString.reply,
                ),
              ),
              ThemeIconWidget(
                ThemeIcon.send,
                color: AppColorConstants.iconColor,
              )
            ],
          ).hP25,
        ),
      ),
      child: storyWidget(),
    );
  }

  Widget userProfileView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            AvatarView(
              url: widget.story.image,
              size: 30,
            ).rP8,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BodyMediumText(
                  widget.story.userName,
    weight: TextWeight.medium,
    color: Colors.white

                ),
                Obx(() => storyController.storyMediaModel.value != null
                    ? BodyMediumText(
                        storyController.storyMediaModel.value!.createdAt,
                        color: AppColorConstants.grayscale100,

                      )
                    : Container())
              ],
            ),
          ],
        ),
        if (widget.story.media.first.userId ==
            _userProfileManager.user.value!.id)
          SizedBox(
            height: 25,
            width: 40,
            child: ThemeIconWidget(
              ThemeIcon.more,
              color: AppColorConstants.whiteClr,
              size: 20,
            ).ripple(() {
              openActionPopup();
            }),
          )
      ],
    ).ripple(() {
      int userId = widget.story.media.first.userId;
      if (userId == _userProfileManager.user.value!.id) {
        Get.to(() => const MyProfile(showBack: true));
      } else {
        Get.to(() => OtherUserProfile(
              userId: userId,
            ));
      }
    });
  }

  void openActionPopup() {
    controller.pause();

    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
              children: [
                // SizedBox(
                //   height: 50,
                //   width: 50,
                //   child: ThemeIconWidget(
                //     ThemeIcon.plus,
                //     size: 25,
                //     color: AppColorConstants.iconColor,
                //   ),
                // )
                //     .borderWithRadius(
                //     value: 2, radius: 20)
                //     .ripple(() {
                //   Get.to(() => const ChooseMediaForStory());
                // }),
                ListTile(
                    title: Center(child: BodyLargeText(LocalizationString.deleteStory, color: Colors.black,)),
                    onTap: () async {
                      Get.back();
                      controller.play();

                      storyController.deleteStory(() {
                        widget.storyDeleted();
                      });
                    }),
                divider(context: context),
                ListTile(
                    title: Center(child: BodyLargeText(LocalizationString.addStory,  color: Colors.black,)),
                    onTap: () async {
                      Get.to(() => const ChooseMediaForStory());
                      // Get.back();
                      // controller.play();
                      //
                      // storyController.deleteStory(() {
                      //   widget.storyDeleted();
                      // });
                    }),
                divider(context: context),
                ListTile(
                    title: Center(child: BodyLargeText(LocalizationString.cancel,  color: Colors.black,)),
                    onTap: () {
                      controller.play();
                      Get.back();
                    }),
              ],
            )).then((value) {
      controller.play();
    });
  }

// Widget replyView() {
//   return Column(
//     children: [
//       Text(
//         widget.story.title,
//         style: TextStyle(fontSize: FontSizes.b2).bold,
//         textAlign: TextAlign.center,
//       ).hP16,
//       divider(height: 0.5, color: AppTheme.dividerColor).tP16,
//     ],
//   );
// }
}

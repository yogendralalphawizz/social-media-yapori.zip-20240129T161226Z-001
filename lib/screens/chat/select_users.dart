import 'dart:convert';
import 'dart:typed_data';

import 'package:foap/apiHandler/api_controller.dart';
import 'package:foap/controllers/add_post_controller.dart';
import 'package:foap/controllers/story_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import 'package:foap/screens/chat/random_chat/choose_profile_category.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../components/user_card.dart';
import '../../controllers/agora_call_controller.dart';
import '../../helper/permission_utils.dart';
import '../../model/call_model.dart';

class SelectUserForChat extends StatefulWidget {
  final Function(UserModel) userSelected;

  const SelectUserForChat({Key? key, required this.userSelected})
      : super(key: key);

  @override
  SelectUserForChatState createState() => SelectUserForChatState();
}

class SelectUserForChatState extends State<SelectUserForChat> {
  final SelectUserForChatController _selectUserForChatController =
      SelectUserForChatController();
  final AgoraCallController _agoraCallController = Get.find();

  @override
  void initState() {
    super.initState();

    _selectUserForChatController.clear();
    _selectUserForChatController.getFollowingUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: AppColorConstants.cardColor.darken(),
            width: double.infinity,
            child: Column(
              children: [
                // const SizedBox(
                //   height: 20,
                // ),
                // SearchBar(
                //         showSearchIcon: true,
                //         iconColor: ColorConstants.themeColor,
                //         onSearchChanged: (value) {
                //           selectUserForChatController.searchTextChanged(value);
                //         },
                //         onSearchStarted: () {
                //           //controller.startSearch();
                //         },
                //         onSearchCompleted: (searchTerm) {})
                //     .hP8,
                // divider(context: context).tP16,
                Expanded(
                  child: GetBuilder<SelectUserForChatController>(
                      init: _selectUserForChatController,
                      builder: (ctx) {
                        ScrollController scrollController = ScrollController();
                        scrollController.addListener(() {
                          if (scrollController.position.maxScrollExtent ==
                              scrollController.position.pixels) {
                            if (!_selectUserForChatController
                                .followingIsLoading) {
                              _selectUserForChatController.getFollowingUsers();
                            }
                          }
                        });

                        List<UserModel> usersList =
                            _selectUserForChatController.following;
                        return _selectUserForChatController.followingIsLoading
                            ? const ShimmerUsers().hP16
                            : usersList.isNotEmpty
                                ? ListView.builder(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 50),
                                    controller: scrollController,
                                    itemCount: usersList.length,
                                    itemBuilder: (context, index) {
                                    /*  if (index == 0) {
                                        print('this is len ${usersList.length}');
                                        return SizedBox(
                                          height: 40,
                                          child: Row(
                                            children: [
                                              Container(
                                                      color: AppColorConstants
                                                          .themeColor
                                                          .withOpacity(0.2),
                                                      child: ThemeIconWidget(
                                                        ThemeIcon.group,
                                                        size: 15,
                                                        color: AppColorConstants
                                                            .themeColor,
                                                      ).p8)
                                                  .circular,
                                              const SizedBox(
                                                width: 16,
                                              ),
                                              Heading6Text(
                                                LocalizationString.createGroup,
                                                weight: TextWeight.semiBold,
                                              )
                                            ],
                                          ),
                                        ).ripple(() {
                                          Get.back();
                                          Get.to(() =>
                                              const SelectUserForGroupChat());
                                        }).hP16;
                                      } else if (index == 1) {
                                        return SizedBox(
                                          height: 40,
                                          child: Row(
                                            children: [
                                              Container(
                                                      color: AppColorConstants
                                                          .themeColor
                                                          .withOpacity(0.2),
                                                      child: ThemeIconWidget(
                                                        ThemeIcon.randomChat,
                                                        size: 15,
                                                        color: AppColorConstants
                                                            .themeColor,
                                                      ).p8)
                                                  .circular,
                                              const SizedBox(
                                                width: 16,
                                              ),
                                              Heading6Text(
                                                LocalizationString.strangerChat,
                                                weight: TextWeight.semiBold,
                                              )
                                            ],
                                          ),
                                        ).ripple(() {
                                          Get.to(
                                              () => const ChooseProfileCategory(
                                                    isCalling: false,
                                                  ));
                                        }).hP16;
                                      } else {*/
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: 15),
                                          child: UserTile(
                                            profile: usersList[index],
                                            viewCallback: () {
                                              EasyLoading.show(
                                                  status:
                                                      LocalizationString.loading);

                                              widget.userSelected(
                                                  usersList[index]);
                                            },
                                            audioCallCallback: () {
                                              Get.back();
                                              initiateAudioCall(
                                                  context, usersList[index]);
                                            },
                                            chatCallback: () {
                                              EasyLoading.show(
                                                  status:
                                                      LocalizationString.loading);

                                              widget.userSelected(
                                                  usersList[index]);
                                            },
                                            videoCallCallback: () {
                                              Get.back();
                                              initiateVideoCall(
                                                  usersList[index]);
                                            },
                                          ).hP16,
                                        );
                                      // }
                                    },
                                    // separatorBuilder: (context, index) {
                                    //   // if (index < 2) {
                                    //     return divider(context: context).vP16;
                                    //   // }
                                    //   //
                                    //   // return const SizedBox(
                                    //   //   height: 20,
                                    //   // );
                                    // },
                                  )
                                : emptyUser(
                                    title: LocalizationString.noUserFound,
                                    subTitle:
                                        LocalizationString.followSomeUserToChat,
                                  );
                      }),
                ),
              ],
            ),
          ).round(20).p16,
        ),
        const SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 50,
            width: 50,
            color: AppColorConstants.backgroundColor,
            child: Center(
              child: ThemeIconWidget(
                ThemeIcon.close,
                color: AppColorConstants.iconColor,
                size: 25,
              ),
            ),
          ).circular.ripple(() {
            Get.back();
          }),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void initiateVideoCall(UserModel opponent) {
    PermissionUtils.requestPermission(
        [Permission.camera, Permission.microphone], context,
        isOpenSettings: false, permissionGrant: () async {
      Call call = Call(
          uuid: '',
          callId: 0,
          channelName: '',
          token: '',
          isOutGoing: true,
          callType: 2,
          opponent: opponent);

      _agoraCallController.makeCallRequest(call: call);
    }, permissionDenied: () {
      AppUtil.showToast(
          message: LocalizationString.pleaseAllowAccessToCameraForVideoCall,
          isSuccess: false);
    }, permissionNotAskAgain: () {
      AppUtil.showToast(
          message: LocalizationString.pleaseAllowAccessToCameraForVideoCall,
          isSuccess: false);
    });
  }

  void initiateAudioCall(BuildContext context, UserModel opponent) {
    PermissionUtils.requestPermission([Permission.microphone], context,
        isOpenSettings: false, permissionGrant: () async {
      Call call = Call(
          uuid: '',
          callId: 0,
          channelName: '',
          token: '',
          isOutGoing: true,
          callType: 1,
          opponent: opponent);

      _agoraCallController.makeCallRequest(call: call);
    }, permissionDenied: () {
      AppUtil.showToast(
          message: LocalizationString.pleaseAllowAccessToMicrophoneForAudioCall,
          isSuccess: false);
    }, permissionNotAskAgain: () {
      AppUtil.showToast(
          message: LocalizationString.pleaseAllowAccessToMicrophoneForAudioCall,
          isSuccess: false);
    });
  }
}

class SelectFollowingUserForMessageSending extends StatefulWidget {
  PostGallery? post;
  bool? show;
  final Function(UserModel) sendToUserCallback;
  bool? isClips;
   SelectFollowingUserForMessageSending({
    Key? key,
     this.post,
     this.show,
    required this.sendToUserCallback,this.isClips

    // this.post,
  }) : super(key: key);

  @override
  SelectFollowingUserForMessageSendingState createState() =>
      SelectFollowingUserForMessageSendingState();
}

class SelectFollowingUserForMessageSendingState
    extends State<SelectFollowingUserForMessageSending> {
  final SelectUserForChatController selectUserForChatController =
      SelectUserForChatController();
  final AddPostController addPostController = Get.find();
  final AppStoryController storyController = AppStoryController();
  @override
  void initState() {
    super.initState();
    selectUserForChatController.getFollowingUsers();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    selectUserForChatController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.show! ?  Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 40,
                // width: 50,
                color: AppColorConstants.backgroundColor,
                child:  Center(
                    child: Text(LocalizationString.sharePostStory, style: TextStyle(
                        color: AppColorConstants.iconColor
                    ),)
                ),
              ).circular.ripple(() async {

                String url = widget.post!.filePath.toString();
                Uri uri = Uri.parse(url);
                String lastPathSegment = uri.pathSegments.last;
                Map<String, String> dataMap= {};
                Uint8List? thumbnail ;
                if(widget.post!.mediaType.toString() == '2') {
                  thumbnail =  await VideoThumbnail.thumbnailData(
                    video: url,
                    //config.controller.file.path.toString(),
                    //widget.reel.path,
                    //widget.reel.path,
                    imageFormat: ImageFormat.PNG,
                    maxWidth: 400,
                    // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                    quality: 50,
                  );
                }
                dataMap['image'] = widget.post!.mediaType.toString() == '1' ? lastPathSegment : '';
                dataMap['video'] = widget.post!.mediaType.toString() == '1' ? '': lastPathSegment;
                dataMap['type'] = widget.post!.mediaType.toString();
                dataMap['thumbnail'] =
                    // lastPathSegment;
                widget.post!.type.toString() == '1' ? lastPathSegment : thumbnail.toString();
                dataMap['description'] = '';
                dataMap['background_color']= '';
                List<Map<String, String>> data = [];
                data.add(dataMap);
                print('this is post item $data');
                storyController.publishAction(galleryItems: [] , postItems: data , isPosts: true);
                await ApiController()
                    .sharePostCount(widget.post!.postId)
                    .then((response) async {});
                // uploadAllMedia(
                //     context: context, items: widget.post);
              }).round(20).hP16,
            ),
            const SizedBox(
              height: 7,
            ),

            Align(
              alignment: Alignment.center,
              child: Container(
                height: 40,
                // width: 50,
                color: AppColorConstants.backgroundColor,
                child:  Center(
                    child: Text(
                      widget.isClips == true?
                      LocalizationString.sharePostOnTimeline
                     : LocalizationString.sharePostOnTimeline
                      , style: TextStyle(
                        color: AppColorConstants.iconColor
                    ),)
                ),
              ).circular.ripple(() async {

                String url = widget.post!.filePath.toString();
                Uri uri = Uri.parse(url);
                String lastPathSegment = uri.pathSegments.last;
                Map<String, String> dataMap= {};

                dataMap['filename'] = lastPathSegment.toString();
                dataMap['media_type'] = widget.post!.mediaType.toString();
                dataMap['video_thumb'] = widget.post!.mediaType.toString() == '1' ? '' : lastPathSegment;
                ///widget.post!.type.toString() == '1' ? lastPathSegment : widget.post!.thumbnail.toString();
                dataMap['type'] = '1';
                dataMap['is_default']= '1';
                List<Map<String, String>> data=[];
                data.add(dataMap);
                if(widget.isClips!) {
                  print('working on clips');
                  addPostController.publishAction(
                    galleryItems: data,
                    title: 'Repost',
                    tags: [],
                    mentions: [],
                    competitionId: null,
                    clubId: null,
                    isReel: true,
                    audioId: null,
                    audioStartTime: 0,
                    audioEndTime: 0,
                  );
                  await ApiController()
                      .sharePostCount(widget.post!.postId)
                      .then((response) async {});
                  Get.back();
                } else {
                  print('working normal');
                  addPostController.publishAction(
                    galleryItems: data,
                    title: 'Repost',
                    tags: [],
                    mentions: [],
                    competitionId: null,
                    clubId: null,
                    isReel: false,
                    audioId: null,
                    audioStartTime: 0,
                    audioEndTime: 0,
                  );
                  await ApiController()
                      .sharePostCount(widget.post!.postId)
                      .then((response) async {});
                  Get.back();
                }

              }).round(20).hP16,
            ),

            const SizedBox(
              height: 7,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 40,
                // width: 50,
                color: AppColorConstants.backgroundColor,
                child:  Center(
                    child: Text(LocalizationString.sharePostOther, style: TextStyle(
                        color: AppColorConstants.iconColor
                    ),)
                ),
              ).circular.ripple(() async{
                Map<String, String> dataMap= {};

                dataMap['image'] = widget.post!.type.toString() == '1' ? widget.post!.filePath.toString() : '';
                dataMap['video'] = widget.post!.type.toString() == '1' ? '': widget.post!.filePath.toString();
                dataMap['type'] = widget.post!.type.toString();
                dataMap['description'] = '';
                dataMap['background_color']= '';
                // List<Map<String, String>> data=[];
                // data.add(dataMap);
                await Share.share(
                  widget.post!.filePath.toString(),
                  subject: 'Ya-Pori Post',
                  // sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                );
                await ApiController()
                    .sharePostCount(widget.post!.postId)
                    .then((response) async {});

              }).round(20).hP16,
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        )
        : const SizedBox.shrink(),
        Container(
          height: 250,
          color: AppColorConstants.backgroundColor,
          child: GetBuilder<SelectUserForChatController>(
              init: selectUserForChatController,
              builder: (ctx) {
                ScrollController scrollController = ScrollController();
                scrollController.addListener(() {
                  if (scrollController.position.maxScrollExtent ==
                      scrollController.position.pixels) {
                    if (!selectUserForChatController.followingIsLoading) {
                      selectUserForChatController.getFollowingUsers();
                    }
                  }
                });

                List<UserModel> usersList =
                    selectUserForChatController.following;
                return selectUserForChatController.followingIsLoading
                    ? const ShimmerUsers().hP16
                    : usersList.isNotEmpty
                        ? ListView.separated(
                            padding: const EdgeInsets.only(top: 20, bottom: 50),
                            controller: scrollController,
                            itemCount: usersList.length,
                            itemBuilder: (context, index) {
                              UserModel user = usersList[index];
                              return SendMessageUserTile(
                                state: selectUserForChatController
                                        .completedActionUsers
                                        .contains(user)
                                    ? ButtonState.success
                                    : selectUserForChatController
                                            .failedActionUsers
                                            .contains(user)
                                        ? ButtonState.fail
                                        : selectUserForChatController
                                                .processingActionUsers
                                                .contains(user)
                                            ? ButtonState.loading
                                            : ButtonState.idle,
                                profile: usersList[index],
                                sendCallback: () async{
                                  Get.back();
                                  widget.sendToUserCallback(usersList[index]);
                                  await ApiController()
                                      .sharePostCount(widget.post!.postId)
                                      .then((response) async {});
                                },
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 20,
                              );
                            },
                          ).hP16
                        : emptyUser(
                            title: LocalizationString.noUserFound,
                            subTitle:
                                LocalizationString.followFriendsToSendPost,
                          );
              }),
        ).round(20).p16,
        const SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 50,
            width: 50,
            color: AppColorConstants.backgroundColor,
            child: Center(
              child: ThemeIconWidget(
                ThemeIcon.close,
                color: AppColorConstants.iconColor,
                size: 25,
              ),
            ),
          ).circular.ripple(() {
            Get.back();
          }),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

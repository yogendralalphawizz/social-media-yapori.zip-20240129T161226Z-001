import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:agora_rtc_engine/rtc_engine.dart';
//
// import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;

import 'package:foap/controllers/subscription_packages_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:foap/screens/live/broadcast_page.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';


import '../apiHandler/api_controller.dart';
import '../helper/permission_utils.dart';
import '../manager/socket_manager.dart';
import '../model/call_model.dart';
import '../model/chat_message_model.dart';
import '../model/gift_model.dart';
import '../model/package_model.dart';
import '../screens/settings_menu/settings_controller.dart';
import '../util/ad_helper.dart';
import '../util/constant_util.dart';

class AgoraLiveController extends GetxController {
  final SubscriptionPackageController packageController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  Rx<TextEditingController> messageTf = TextEditingController().obs;
  RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  RxList<ReceivedGiftModel> giftsReceived = <ReceivedGiftModel>[].obs;

  RxInt remoteUserId = 0.obs;
  Rx<GiftModel?> sendingGift = Rx<GiftModel?>(null);

  RxList<String> infoStrings = <String>[].obs;
  // late RtcEngine _engine;
  late int liveId;
  late String localLiveId;

  RxList<UserModel> currentJoinedUsers = <UserModel>[].obs;
  RxList<UserModel> allJoinedUsers = <UserModel>[].obs;

  UserModel? host;

  RxInt canLive = 0.obs;
  String? errorMessage;

  RxBool askLiveEndConformation = false.obs;

  RxBool isFront = false.obs;
  RxBool reConnectingRemoteView = false.obs;
  RxBool mutedAudio = false.obs;
  RxBool mutedVideo = false.obs;
  RxBool videoPaused = false.obs;
  RxBool liveEnd = false.obs;

  DateTime? liveStartTime;
  DateTime? liveEndTime;
  final SettingsController _settingsController = Get.find();
  int remoteUid = 0;
  bool localUserJoined = false;
  String channelId="";

  String get liveTime {
    int totalSeconds = liveEndTime!.difference(liveStartTime!).inSeconds;
    int h, m, s;

    h = totalSeconds ~/ 3600;

    m = ((totalSeconds - h * 3600)) ~/ 60;

    s = totalSeconds - (h * 3600) - (m * 60);

    if (h > 0) {
      return "${h}h:${m}m:${s}s";
    } else if (m > 0) {
      return "${m}m:${s}s";
    }

    return "$s sec";
  }

  int get totalCoinsEarned {
    if (giftsReceived.isNotEmpty) {
      return giftsReceived
          .map((element) => element.giftDetail.coins)
          .reduce((a, b) => a + b);
    } else {
      return 0;
    }
  }

  clear() {
    isFront.value = false;
    reConnectingRemoteView.value = false;
    mutedAudio.value = false;
    mutedVideo.value = false;
    videoPaused.value = false;
    liveEnd.value = false;
    canLive.value = 0;

    currentJoinedUsers.clear();
    allJoinedUsers.clear();
    messages.clear();
    giftsReceived.clear();

    askLiveEndConformation.value = false;
  }

  checkFeasibilityToLive(
      {required BuildContext context, required bool isOpenSettings}) {
    AppUtil.checkInternet().then((value) {
      Timer(const Duration(seconds: 2), () {
        if (value) {
          PermissionUtils.requestPermission(
              [Permission.camera, Permission.microphone], context,
              isOpenSettings: isOpenSettings, permissionGrant: () async {
            canLive.value = 1;
            errorMessage = null;
          }, permissionDenied: () {
            canLive.value = -1;

            errorMessage = LocalizationString.pleaseAllowAccessToCameraForLive;
          }, permissionNotAskAgain: () {
            canLive.value = -1;
            errorMessage = LocalizationString.pleaseAllowAccessToCameraForLive;
          });
        } else {
          canLive.value = value == true ? 1 : -1;
        }
      });
    });
  }

  closeLive() {
    clear();
    Get.back();
    Get.back();
    // InterstitialAds().show();
  }
  String appId = 'da298c31ec0749498d527a0a69115bdb';

  //Initialize All The Setup For Agora Video Call
  // Future<Widget> initializeLive() async {
  //   localLiveId = randomId();
  //   getIt<SocketManager>().connect();
  //   print('this is live data $channelId and ${_userProfileManager.user.value!.id}');
  //   remoteUid = _userProfileManager.user.value!.id;
  //   getIt<SocketManager>().emit(SocketConstants.goLive, {
  //     'userId': _userProfileManager.user.value!.id,
  //     'localCallId': localLiveId,
  //   });
  //
  //
  //   await [Permission.microphone, Permission.camera].request();
  //
  //   print("permission allowed");
  //
  //   //create the engine
  //   _engine = await RtcEngine.create(appId);
  //
  //   print("rectEngine created");
  //
  //   await _engine.enableVideo();
  //   print("video enabled");
  //
  //   _engine.setEventHandler( RtcEngineEventHandler(
  //       joinChannelSuccess: (String channel, int uid, int elapsed) {
  //         print("local user $uid joined");
  //         localUserJoined = true;
  //         localLiveId = channel;
  //       },
  //       userOffline: (int uid, UserOfflineReason reason) {
  //         print("remote user $uid left channel");
  //         remoteUid = 0;
  //       },
  //       userJoined: (int uid, int elapsed) {
  //         print("remote user $uid joined");
  //         remoteUid = uid;
  //       }));
  //
  //   print("setEventHandler completed");
  //   _engine.joinChannel('da298c31ec0749498d527a0a69115bdb', localLiveId, null, 0);
  //   // Get.to(() => BroadcastPage(
  //   //   channelName: localLiveId,
  //   //   isBroadcaster: true,
  //   // ));
  //   // _joinLive(live: live);
  //
  //   await [Permission.microphone, Permission.camera].request();
  //   print("initializeLive permission access");
  //
  //   await _engine.initialize(RtcEngineContext(localLiveId));
  //   print("initializeLive initialization ${ClientRole.Broadcaster}");
  //
  //   // _engine!.register
  //   // _engine!.registerEventHandler(
  //   //   RtcEngineEventHandler(
  //   //     onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
  //   //       debugPrint("local user ${connection.localUid} joined");
  //   //       setState(() {
  //   //         _localUserJoined = true;
  //   //       });
  //   //     },
  //   //     onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
  //   //       debugPrint("remote user $remoteUid joined");
  //   //       setState(() {
  //   //         _remoteUid = remoteUid;
  //   //       });
  //   //     },
  //   //     onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
  //   //       debugPrint("remote user $remoteUid left channel");
  //   //       setState(() {
  //   //         _remoteUid = null;
  //   //       });
  //   //     },
  //   //     onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
  //   //       debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
  //   //     },
  //   //   ),
  //   // );
  //
  //   // await _engine.setClientRole(ClientRole.Broadcaster);
  //   //     ClientRole.Broadcaster);
  //   await _engine.enableVideo();
  //   await _engine.startPreview();
  //
  //   // await _engine.joinChannel('da298c31ec0749498d527a0a69115bdb', _userProfileManager.user.value!.id.toString(),  "", 0);
  //
  //   // await _engine.joinChannel(
  //   //   token: token,
  //   //   channelId: channel,
  //   //   uid: 0,
  //   //   options:  ChannelMediaOptions(),
  //   // );
  //
  //   return _remoteVideo();
  //
  // }
  // Widget _remoteVideo() {
  //   if (remoteUid != null) {
  //     return AgoraVideoView(
  //       controller: VideoViewController.remote(
  //         rtcEngine: _engine,
  //         canvas: VideoCanvas(uid: remoteUid),
  //         connection: const RtcConnection(channelId: channel),
  //       ),
  //     );
  //   } else {
  //     return const Text(
  //       'Please wait for remote user to join',
  //       textAlign: TextAlign.center,
  //     );
  //   }
  // }

  // Widget _remoteVideo() {
  //   // if (remoteUid != null) {
  //   //
  //   //   return
  //      return rtc_remote_view.SurfaceView(
  //       uid: remoteUid,
  //       channelId: channelId
  //       // channel id need to check
  //     );
  //   // } else {
  //   //   return Text(
  //   //     'Please wait for remote user to join',
  //   //     textAlign: TextAlign.center,
  //   //   );
  //   // }
  //   // return Container();
  // }


  Future<void> initAgora() async {
    // retrieve permissions

  }

  joinAsAudience({required Live live}) async {
    liveEnd.value = false;
    // liveEnd.value = false;
    // if (live.host != null) {
    //   host = hostUser;
    // } else {
    await ApiController()
        .getOtherUser(live.host.id.toString())
        .then((response) {
      host = response.user;
    });
    // }
    liveId = live.liveId;

    remoteUserId.value = live.host.id;

    getIt<SocketManager>().emit(SocketConstants.joinLive, {
      'userId': _userProfileManager.user.value!.id,
      'liveCallId': liveId,
    });
    sendTextMessage('Joined');
    currentJoinedUsers.add(_userProfileManager.user.value!);
    // _joinLive(live: live);
  }

  // _joinLive({
  //   required Live live,
  // }) {
  //   if (_settingsController.setting.value!.agoraApiKey!.isEmpty) {
  //     infoStrings.add(
  //       _settingsController.setting.value!.agoraApiKey!,
  //     );
  //     infoStrings.add('Agora Engine is not starting');
  //     update();
  //     return;
  //   }
  //
  //   Future.delayed(Duration.zero, () async {
  //     await _initAgoraRtcEngine();
  //     _addAgoraEventHandlers();
  //     var configuration = VideoEncoderConfiguration();
  //     configuration.dimensions =
  //         const VideoDimensions(width: 1920, height: 1080);
  //     configuration.orientationMode = VideoOutputOrientationMode.Adaptative;
  //     _engine.leaveChannel();
  //     await _engine.setVideoEncoderConfiguration(configuration);
  //     await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
  //
  //     live.isHosting
  //         ? await _engine.setClientRole(ClientRole.Broadcaster)
  //         : await _engine.setClientRole(ClientRole.Audience);
  //     await _engine.joinChannel(live.token, live.channelName, null,
  //         _userProfileManager.user.value!.id);
  //
  //     liveStartTime = DateTime.now();
  //
  //     Get.to(() => LiveBroadcastScreen(
  //           live: live,
  //         ));
  //   });
  // }
  //
  // //Initialize Agora RTC Engine
  // Future<void> _initAgoraRtcEngine() async {
  //   _engine =
  //       await RtcEngine.create(_settingsController.setting.value!.agoraApiKey!);
  //   await _engine.enableVideo();
  // }

  //Switch Camera
  onToggleCamera() {
    // _engine.switchCamera().then((value) {
    //   isFront.value = !isFront.value;
    // }).catchError((err) {});
  }

  //Audio On / Off
  void onToggleMuteAudio() {
    mutedAudio.value = !mutedAudio.value;
    // _engine.muteLocalAudioStream(mutedAudio.value);
  }

  //Video On / Off
  void onToggleMuteVideo() {
    mutedVideo.value = !mutedVideo.value;
    // _engine.muteLocalVideoStream(mutedVideo.value);
  }

  //Agora Events Handler To Implement Ui/UX Based On Your Requirements
  // void _addAgoraEventHandlers() {
  //   _engine.setEventHandler(RtcEngineEventHandler(
  //     error: (code) {
  //       final info = 'onError:$code ${code.index}';
  //       infoStrings.add(info);
  //     },
  //     joinChannelSuccess: (channel, uid, elapsed) {
  //       final info = 'onJoinChannel: $channel, uid: $uid';
  //       infoStrings.add(info);
  //       // joinedUsers.add(_userProfileManager.user.value!);
  //     },
  //     leaveChannel: (stats) {
  //       infoStrings.add('onLeaveChannel');
  //     },
  //     userJoined: (uid, elapsed) {
  //       final info = 'userJoined: $uid';
  //       infoStrings.add(info);
  //     },
  //     userOffline: (uid, elapsed) async {
  //       if (elapsed == UserOfflineReason.Dropped) {
  //         Wakelock.disable();
  //       } else {
  //         final info = 'userOffline: $uid';
  //         infoStrings.add(info);
  //         // _timerKey.currentState?.cancelTimer();
  //       }
  //     },
  //     firstRemoteVideoFrame: (uid, width, height, elapsed) {
  //       final info = 'firstRemoteVideo: $uid ${width}x $height';
  //       infoStrings.add(info);
  //     },
  //     connectionStateChanged: (type, reason) async {
  //       if (type == ConnectionStateType.Connected) {
  //         reConnectingRemoteView.value = false;
  //       } else if (type == ConnectionStateType.Reconnecting) {
  //         reConnectingRemoteView.value = true;
  //       }
  //     },
  //     remoteVideoStats: (remoteVideoStats) {
  //       if (remoteVideoStats.receivedBitrate == 0) {
  //         videoPaused.value = true;
  //       } else {
  //         videoPaused.value = false;
  //       }
  //     },
  //   ));
  // }

  dontEndLiveCall() {
    askLiveEndConformation.value = false;
  }

  askConfirmationForEndCall() {
    askLiveEndConformation.value = true;
  }

  //Use This Method To End Call
  void onCallEnd({required bool isHost}) async {
    // _engine!.leaveChannel();
    // _engine!.destroy();
    Wakelock.disable(); // Turn off wakelock feature after call end
    // Emit End live Event Into Socket

    if (isHost) {
      getIt<SocketManager>().emit(
          SocketConstants.endLive,
          ({
            'userId': _userProfileManager.user.value!.id,
            'liveCallId': liveId
          }));
      liveEndTime = DateTime.now();
      liveEnd.value = true;

      // Get.back();
    } else {
      sendTextMessage('Left');
      getIt<SocketManager>().emit(
          SocketConstants.leaveLive,
          ({
            'userId': _userProfileManager.user.value!.id,
            'liveCallId': liveId
          }));
      clear();
      Get.back();
      InterstitialAds().show();
    }
  }

  messageChanges() {
    // getIt<SocketManager>().emit(SocketConstants.typing, {'room': chatRoomId});
    // messageTf.refresh();
    // update();
  }

  sendTextMessage(String messageText) {
    // if (messageTf.value.text.removeAllWhitespace.trim().isNotEmpty) {
    String localMessageId = randomId();
    String encrtyptedMessage = messageText.encrypted();
    var message = {
      'userId': _userProfileManager.user.value!.id,
      'liveCallId': liveId,
      'messageType': messageTypeId(MessageContentType.text),
      'message': encrtyptedMessage,
      'localMessageId': localMessageId,
      'picture': _userProfileManager.user.value!.picture,
      'username': _userProfileManager.user.value!.userName,
      'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    };

    //save message to socket server
    getIt<SocketManager>().emit(SocketConstants.sendMessageInLive, message);

    ChatMessageModel localMessageModel = ChatMessageModel();
    localMessageModel.localMessageId = localMessageId;
    localMessageModel.roomId = liveId;
    // localMessageModel.messageTime = LocalizationString.justNow;
    localMessageModel.userName = LocalizationString.you;
    // localMessageModel.userPicture = _userProfileManager.user.value!.picture;
    localMessageModel.senderId = _userProfileManager.user.value!.id;
    localMessageModel.messageType = messageTypeId(MessageContentType.text);
    localMessageModel.messageContent = messageText;

    localMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();

    messages.add(localMessageModel);
    messageTf.value.text = '';
    update();
    // }
  }

  sendGiftMessage(String giftImage, int coins) {
    String localMessageId = randomId();
    var content = {'giftImage': giftImage, 'coins': coins.toString()};
    String encrtyptedMessage = json.encode(content).encrypted();

    var message = {
      'userId': _userProfileManager.user.value!.id,
      'liveCallId': liveId,
      'messageType': messageTypeId(MessageContentType.gift),
      'message': encrtyptedMessage,
      'localMessageId': localMessageId,
      'picture': _userProfileManager.user.value!.picture,
      'username': _userProfileManager.user.value!.userName,
      'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    };

    //save message to socket server
    getIt<SocketManager>().emit(SocketConstants.sendMessageInLive, message);

    ChatMessageModel localMessageModel = ChatMessageModel();
    localMessageModel.localMessageId = localMessageId;
    localMessageModel.roomId = liveId;
    // localMessageModel.messageTime = LocalizationString.justNow;
    localMessageModel.userName = LocalizationString.you;
    // localMessageModel.userPicture = _userProfileManager.user.value!.picture;
    localMessageModel.senderId = _userProfileManager.user.value!.id;
    localMessageModel.messageType = messageTypeId(MessageContentType.gift);
    localMessageModel.messageContent = json.encode(content);

    localMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();

    messages.add(localMessageModel);
    messageTf.value.text = '';
    update();
  }

  sendGift(GiftModel gift, BuildContext context) {
    if (_userProfileManager.user.value!.coins > gift.coins) {
      sendingGift.value = gift;
      ApiController()
          .sendGift(gift: gift, liveId: liveId, userId: host!.id, postId: null)
          .then((value) {
        Timer(const Duration(seconds: 1), () {
          sendingGift.value = null;
        });

        //send gift message
        sendGiftMessage(gift.logo, gift.coins);

        // refresh profile to get updated wallet info
        _userProfileManager.refreshProfile();
      });
    } else {
      List<PackageModel> availablePackages = packageController.packages
          .where((package) => package.coin >= gift.coins)
          .toList();
      PackageModel package = availablePackages.first;
      buyPackage(package, context);
    }
  }

  buyPackage(PackageModel package, BuildContext context) {
    if (AppConfigConstants.isDemoApp) {
      AppUtil.showDemoAppConfirmationAlert(
          title: 'Demo app',
          subTitle:
              'This is demo app so you can not make payment to test it, but still you will get some coins',
          okHandler: () {
            packageController.subscribeToDummyPackage(context, randomId());
          });
      return;
    }
    if (packageController.isAvailable.value) {
      // For production build
      packageController.selectedPurchaseId.value = Platform.isIOS
          ? package.inAppPurchaseIdIOS
          : package.inAppPurchaseIdAndroid;
      List<ProductDetails> matchedProductArr = packageController.products
          .where((element) =>
              element.id == packageController.selectedPurchaseId.value)
          .toList();
      if (matchedProductArr.isNotEmpty) {
        ProductDetails matchedProduct = matchedProductArr.first;
        PurchaseParam purchaseParam = PurchaseParam(
            productDetails: matchedProduct, applicationUserName: null);
        packageController.inAppPurchase.buyConsumable(
            purchaseParam: purchaseParam,
            autoConsume: packageController.kAutoConsume || Platform.isIOS);
      } else {
        AppUtil.showToast(
            message: LocalizationString.noProductAvailable,
            isSuccess: false);
      }
    } else {
      AppUtil.showToast(
          message: LocalizationString.storeIsNotAvailable,
          isSuccess: false);
    }
  }

  //*************** updates from socket *******************//

  onNewUserJoined(UserModel user) {
    currentJoinedUsers.add(user);
    if (!allJoinedUsers.contains(user)) {
      allJoinedUsers.add(user);
    }
    update();
  }

  onUserLeave(int userId) {
    currentJoinedUsers.removeWhere((element) => element.id == userId);
    update();
  }

  onLiveEnd(int liveId) {
    // _engine!.leaveChannel();
    // _engine!.destroy();
    Wakelock.disable();

    currentJoinedUsers.clear();
    messages.clear();
    update();
    if (this.liveId == liveId) {
      // Get.back();

      liveEnd.value = true;
    }
  }

  onNewMessageReceived(ChatMessageModel message) {
    if (host!.isMe == true &&
        message.messageContentType == MessageContentType.gift) {
      GiftModel gift = GiftModel(
          id: 1,
          name: '',
          logo: message.giftContent.image,
          coins: message.giftContent.coins);

      UserModel sender = UserModel();
      sender.id = message.senderId;
      sender.userName = message.userName;
      sender.picture = message.userPicture;
      ReceivedGiftModel receivedGiftDetail =
          ReceivedGiftModel(giftDetail: gift, sender: sender);

      sendingGift.value = gift;
      giftsReceived.add(receivedGiftDetail);

      Timer(const Duration(seconds: 1), () {
        sendingGift.value = null;
      });
    }
    messages.add(message);
    update();
  }

  String agoraToken = '';
  liveCreatedConfirmation(dynamic data) {
    if (data['localCallId'] == localLiveId) {
      liveId = data['liveCallId'];
    }
     agoraToken = data['token'];
    String channelName = data['channelName'];

    host = _userProfileManager.user.value!;
    Live live = Live(
        channelName: channelName,
        isHosting: true,
        host: host!,
        token: agoraToken,
        liveId: liveId);

    // _joinLive(live: live);

    update();
  }

  // gifts

  loadGiftsReceived() {
    ApiController()
        .receivedGifts(sendOnType: 1, liveId: liveId, postId: null)
        .then((response) {
      giftsReceived.value = response.giftReceived;

      update();
    });
  }
}


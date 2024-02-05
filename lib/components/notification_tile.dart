import 'package:foap/controllers/explore_controller.dart';
import 'package:foap/controllers/notifications_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../model/notification_modal.dart';

class NotificationTileType4 extends StatefulWidget {
  final NotificationModel notification;
  final Color? backgroundColor;
  final TextStyle? titleTextStyle;
  final TextStyle? subTitleTextStyle;
  final TextStyle? dateTextStyle;
  final Color? borderColor;
  const NotificationTileType4({
    Key? key,
    required this.notification,
    this.backgroundColor,
    this.titleTextStyle,
    this.subTitleTextStyle,
    this.dateTextStyle,
    this.borderColor
  }) : super(key: key);

  @override
  State<NotificationTileType4> createState() => _NotificationTileType4State();
}

class _NotificationTileType4State extends State<NotificationTileType4> {
  //
  // final NotificationModel notification;
  // final Color? backgroundColor;
  // final TextStyle? titleTextStyle;
  // final TextStyle? subTitleTextStyle;
  // final TextStyle? dateTextStyle;
  // final Color? borderColor;
  //
  //  NotificationTileType4(
  //     {Key? key,
  //     required this.notification,
  //     this.backgroundColor,
  //     this.titleTextStyle,
  //     this.subTitleTextStyle,
  //     this.dateTextStyle,
  //     this.borderColor})
  //     : super(key: key);

  final NotificationController _notificationController =
  NotificationController();
  bool followButton = false;


  @override
  void initState() {
    // TODO: implement initState
    print("initState got invoked message : ");
    super.initState();
  }

  Widget getButton()
  {
    print("getButton got invoked id : ${widget.notification.actionBy!.id}");
    Widget appButton = AppThemeButton(
        text: LocalizationString.followBack,
        onPress: () {
          setState(() {
            followButton = true;
            widget.notification.isFollowing = true;
          });
          print("getButton onPressed got invoked followButton : $followButton && isFollowing : ${widget.notification.isFollowing}");
          _notificationController.followUser(widget.notification.actionBy!, widget.notification);
    });
    print("getButton followButton : $followButton && isFollowing : ${widget.notification.isFollowing}");
    if(followButton) {
      followButton = false;
      setState((){
        widget.notification.isFollowing = true;
      });
      print("inside if followButton : $followButton");
    }
    return appButton;
  }

  @override
  Widget build(BuildContext context) {
    print("build got invoked followButton : $followButton && id : ${widget.notification.actionBy?.id} && ${widget.notification.actionBy?.isFollowing}");
    return Row(
      children: [
        if (widget.notification.actionBy != null)
          UserAvatarView(user: widget.notification.actionBy!),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyMediumText(widget.notification.title, weight: TextWeight.semiBold)
                  .bP8,
              BodyMediumText(
                widget.notification.message,
              ).bP8,
              BodySmallText(
                widget.notification.notificationTime(),
                color: AppColorConstants.grayscale500,
              ),
            ],
          ).setPadding(top: 16, bottom: 16, left: 8, right: 8),
        ),
        if (widget.notification.type == NotificationType.like ||
            widget.notification.type == NotificationType.comment)
          CachedNetworkImage(
                  height: 60,
                  width: 60,
                  imageUrl: widget.notification.post!.gallery.first.thumbnail)
              .round(10),
        if (widget.notification.type == NotificationType.follow)
        widget.notification.isFollowing == false ?
            getButton() : const SizedBox.shrink()
      ],
    ).hP8.shadowWithBorder(
        borderWidth: 0.2,
        shadowOpacity: 0.5,
        borderColor: widget.borderColor,
        radius: 10,
        fillColor: widget.backgroundColor ?? AppColorConstants.backgroundColor);
  }
}

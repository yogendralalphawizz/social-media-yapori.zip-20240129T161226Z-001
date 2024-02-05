import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
class ChatHistoryTile extends StatelessWidget {
  final ChatRoomModel model;

  const ChatHistoryTile({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 55,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  model.isGroupChat
                      ? Container(
                          color: AppColorConstants.themeColor,
                          height: 45,
                          width: 45,
                          child:
                              model.image == null || (model.image ?? '').isEmpty
                                  ? const ThemeIconWidget(
                                      ThemeIcon.group,
                                      color: Colors.white,
                                      size: 35,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: model.image!,
                                      height: 35,
                                      width: 35,
                                      fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.person),
                                    ),
                        ).round(15)
                      :

                  // UserAvatarView(
                  //         size: 45,
                  //         user: model.opponent.userDetail,
                  //         onTapHandler: () {},
                  //       ),
                  model.opponent.userDetail.picture != null || model.opponent.userDetail.picture != ''?
                  AvatarView(size: 50, url: model.opponent.userDetail.picture)
                  : const SizedBox.shrink(),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Spacer(),
                        BodyLargeText(
                          model.isGroupChat
                              ? model.name!
                              :
                           model.opponent.userDetail.userName,
                          maxLines: 1,
                          weight:TextWeight.medium,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        // messageTypeShortInfo(message: model.lastMessage!),
                        model.whoIsTyping.isNotEmpty
                            ? BodyMediumText(
                                '${model.whoIsTyping.join(',')} ${LocalizationString.typing}',
                              )
                            :
                        model.lastMessage == null
                                ?
                        Container()
                                : messageTypeShortInfo(
                                    message: model.lastMessage! ,
                                  ),
                        const Spacer(),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                model.unreadMessages > 0
                    ? Container(
                        height: 25,
                        width: 25,
                        color: AppColorConstants.themeColor,
                        child: Center(
                          child: BodyLargeText(
                            '${model.unreadMessages}',
                            weight: TextWeight.bold,
                          ),
                        ),
                      ).circular.bP8
                    : Container(),
                model.lastMessage == null
                    ? Container()
                    : BodyMediumText(
                        model.lastMessage!.messageTime,
                        weight: TextWeight.bold,
                        color: AppColorConstants.themeColor,
                      ),
              ],
            ),
          ],
        ));
  }
}

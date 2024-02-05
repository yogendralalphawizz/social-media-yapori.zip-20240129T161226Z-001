import 'package:foap/helper/imports/call_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class CallHistoryTile extends StatelessWidget {
  final CallHistoryModel model;

  const CallHistoryTile({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatarView(size: 45, user: model.opponent),
        // AvatarView(size: 45, url: model.opponent.picture,name: model.opponent.userName,),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BodyLargeText(
              model.opponent.userName,
              weight:TextWeight.medium,
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                ThemeIconWidget(
                  model.callType == 1
                      ? ThemeIcon.mobile
                      : ThemeIcon.videoCamera,
                  size: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodyMediumText(
                  model.isMissedCall
                      ? LocalizationString.missed
                      : model.isOutgoing
                          ? LocalizationString.outgoing
                          : LocalizationString.incoming,
                  color: model.isMissedCall
                      ? AppColorConstants.red
                      : AppColorConstants.grayscale900,
                ),
              ],
            )
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BodySmallText(
              model.timeOfCall,
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const ThemeIconWidget(
                  ThemeIcon.clock,
                  size: 12,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodySmallText(
                  model.duration,
                  weight:TextWeight.medium,
                ),
              ],
            )
          ],
        ),
        // const SizedBox(
        //   width: 5,
        // ),
        // const ThemeIconWidget(
        //   ThemeIcon.info,
        //   size: 20,
        // ),
      ],
    );
  }
}

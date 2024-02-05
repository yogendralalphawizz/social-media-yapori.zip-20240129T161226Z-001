import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../apiHandler/api_controller.dart';
import '../model/comment_model.dart';
import '../screens/dashboard/posts.dart';
import '../screens/profile/other_user_profile.dart';

class CommentTile extends StatefulWidget {
  final CommentModel model;

  const CommentTile({Key? key, required this.model}) : super(key: key);

  @override
  CommentTileState createState() => CommentTileState();
}

class CommentTileState extends State<CommentTile> {
  late final CommentModel model;

  @override
  void initState() {
    super.initState();
    model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarView(
                url: model.userPicture,
                name: model.userName,
                size: 35,
              ).ripple(() {
                Get.to(() => OtherUserProfile(userId: model.userId));
              }),
              const SizedBox(width: 10),
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 4),
                  Heading6Text(
                    model.userName,
                    weight: TextWeight.medium,
                  ).ripple(() {
                    Get.to(() => OtherUserProfile(userId: model.userId));
                  }),
                  DetectableText(
                    text: model.comment,
                    detectionRegExp:
                    RegExp(r'(@\w+)|(#\w+)|(https?://[^\s]+)',
                      multiLine: true,),
                    // RegExp(
                    //   r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)",
                    //
                    //   // "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegexContent",
                    //   multiLine: true,
                    // ),
                    detectedStyle: TextStyle(
                        fontSize: FontSizes.b3,
                        fontWeight: TextWeight.semiBold,
                        color: AppColorConstants.blueClr),
                    basicStyle: TextStyle(
                        fontSize: FontSizes.b3,
                        color: AppColorConstants.grayscale900),
                    onTap: (tappedText) {
                      commentTextTapHandler(text: tappedText);
                      // postCardController.titleTextTapped(text: tappedText,post: widget.model);
                    },
                  )
                ],
              ))
            ],
          )),
          BodySmallText(model.commentTime, weight: TextWeight.medium).tP4
        ]);
  }
  bool _isLink(String input) {
    final matcher =  RegExp(
        r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");
    return matcher.hasMatch(input);
  }
  Future<void> _launchUrl(String text) async {
    final Uri url = Uri.parse(text);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  commentTextTapHandler({required String text}) {
    if (text.startsWith('#')) {
      Get.to(() => Posts(
            hashTag: text.replaceAll('#', ''),
            source: PostSource.posts,
          ));
    } else if(_isLink(text) == true){
      _launchUrl(text);
    }
    else {
      String userTag = text.replaceAll('@', '');

      ApiController()
          .findFriends(isExactMatch: 1, searchText: userTag)
          .then((response) {
        if (response.users.isNotEmpty) {
          Get.to(() => OtherUserProfile(userId: response.users.first.id));
        }
      });
    }
  }
}

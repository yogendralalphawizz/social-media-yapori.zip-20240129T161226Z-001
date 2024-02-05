import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import '../../apiHandler/api_controller.dart';
import '../../model/post_model.dart';
import '../home_feed/comments_screen.dart';
import '../home_feed/enlarge_image_view.dart';
import '../profile/other_user_profile.dart';

class WinnerDetailScreen extends StatefulWidget {
  final PostModel winnerPost;

  const WinnerDetailScreen({Key? key, required this.winnerPost})
      : super(key: key);

  @override
  WinnerDetailState createState() => WinnerDetailState();
}

class WinnerDetailState extends State<WinnerDetailScreen> {
  late final PostModel model;

  @override
  void initState() {
    super.initState();
    model = widget.winnerPost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,
          title: Heading5Text(
            LocalizationString.winner,
            color: AppColorConstants.themeColor,
          ),
          leading: InkWell(
              onTap: () => Get.back(),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.black)),
        ),
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            addUserInfo(),
            Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                child: BodyLargeText(model.title,
                    color: AppColorConstants.backgroundColor)),
            Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 15),
                child: BodyLargeText(
                  model.tags.join(' '),
                  weight: TextWeight.medium,
                  color: AppColorConstants.backgroundColor,
                )),
            InkWell(
                onTap: () async {
                  Get.to(() => EnlargeImageViewScreen(
                      model: model,
                      handler: () {
                        setState(() {});
                      }));
                },
                child: SizedBox(
                    height: 300.0,
                    child: CachedNetworkImage(
                      imageUrl: model.gallery.first.filePath,
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.width,
                      placeholder: (context, url) =>
                          AppUtil.addProgressIndicator(size:100),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ))),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                              onTap: () => likeUnlikeApiCall(),
                              child: Icon(
                                  model.isLike ? Icons.star : Icons.star_border,
                                  color: AppColorConstants.themeColor,
                                  size: 25)),
                          model.totalLike > 0
                              ? BodyLargeText(
                                  '${model.totalLike} ${LocalizationString.likes}',
                                  weight: TextWeight.medium,
                                  color: AppColorConstants.backgroundColor,
                                )
                              : Container(),
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          InkWell(
                              onTap: () => openComments(),
                              child: Icon(Icons.comment_outlined,
                                  color: AppColorConstants.themeColor)),
                          InkWell(
                            onTap: () => openComments(),
                            child: model.totalComment > 0
                                ? BodyLargeText(
                                    '${model.totalComment} ${LocalizationString.comments}',
                                    weight: TextWeight.medium,
                                    color: AppColorConstants.backgroundColor,
                                  )
                                : Container(),
                          )
                        ])
                  ]),
            ),
          ]),
        ));
  }

  addUserInfo() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
          onTap: () => openProfile(),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  border: Border.all(color: AppColorConstants.themeColor)),
              child: model.user.picture != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: CachedNetworkImage(
                        imageUrl: model.user.picture!,
                        fit: BoxFit.fill,
                        placeholder: (context, url) =>
                            AppUtil.addProgressIndicator(size:100),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ))
                  : Icon(Icons.person, color: Colors.grey.shade600, size: 40),
            ),
            const SizedBox(width: 5),
            Heading5Text(model.user.userName, color: AppColorConstants.themeColor),
          ]),
        ));
  }

  void likeUnlikeApiCall() {
    setState(() {
      model.isLike = !model.isLike;
      model.totalLike =
          model.isLike ? model.totalLike + 1 : model.totalLike - 1;
    });
    AppUtil.checkInternet().then((value) async {
      if (value) {
        ApiController()
            .likeUnlike(!model.isLike, model.id)
            .then((response) async {});
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet,
            isSuccess: false);
      }
    });
  }

  void openComments() {
    Get.to(() => CommentsScreen(
        model: model,
        commentPostedCallback: () {
          model.totalComment += 1;
        },
        handler: () {
          setState(() {});
        }));
  }

  void openProfile() async {
    Get.to(() => OtherUserProfile(userId: model.user.id));

    setState(() {});
  }
}

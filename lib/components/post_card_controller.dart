import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../apiHandler/api_controller.dart';
import '../controllers/post_controller.dart';
import '../model/post_model.dart';

class PostCardController extends GetxController {
  final PostController postController = Get.find();
  RxMap<int, int> postScrollIndexMapping = <int, int>{}.obs;
  RxInt currentIndex = 0.obs;
  int currentPostId = 0;
  RxList<PostModel> likedPosts = <PostModel>[].obs;

  updateGallerySlider(int index, int postId) {
    postScrollIndexMapping[postId] = index;
    currentIndex.value = index;
    currentPostId = postId;
  }

  reportPost(
      {required PostModel post,
      required BuildContext context,
      required VoidCallback callback}) {
    ApiController().reportPost(post.id).then((response) {
      if (response.success == true) {
        // AppUtil.showToast(
        //     context: context,
        //     message: LocalizationString.postReportedSuccessfully,
        //     isSuccess: false);
        callback();
      }
    });
  }

  deletePost(
      {required PostModel post,
      required BuildContext context,
      required VoidCallback callback,
      required bool isClubOwner,
      int? clubId}) {
    ApiController().deletePost(post.id, isClubOwner, clubId!).then((response) {
      if (response.success == true) {
        AppUtil.showToast(
            message: LocalizationString.postDeletedSuccessfully,
            isSuccess: true);
        if(isClubOwner){
          Navigator.pop(context);
        }
        callback();
      }
    });
  }

  void blockUser(
      {required int userId,
      required VoidCallback callback}) {
    AppUtil.checkInternet().then((value) async {
      if (value) {
        EasyLoading.show(status: LocalizationString.loading);
        ApiController().blockUser(userId).then((response) async {
          EasyLoading.dismiss();
          callback();
        });
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet,
            isSuccess: false);
      }
    });
  }

  void likeUnlikePost(
      {required PostModel post, required BuildContext context}) {
    post.isLike = !post.isLike;
    if (post.isLike) {
      likedPosts.add(post);
    } else {
      likedPosts.remove(post);
    }
    likedPosts.refresh();
    post.totalLike = post.isLike ? (post.totalLike) + 1 : (post.totalLike) - 1;
    AppUtil.checkInternet().then((value) async {
      if (value) {
        ApiController()
            .likeUnlike(post.isLike, post.id)
            .then((response) async {});
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet,
            isSuccess: true);
      }
    });

    // update();
  }

  void reactOnPost(
      { required PostModel post, required BuildContext context,required String emoji}) {
    post.isLike = !post.isLike;
    if (post.isLike) {
      likedPosts.add(post);
    } else {
      likedPosts.remove(post);
    }
    likedPosts.refresh();
    post.totalLike = post.isLike ? (post.totalLike) + 1 : (post.totalLike) - 1;
    AppUtil.checkInternet().then((value) async {
      if (value) {
        print('react request $emoji');
        ApiController()
            .reactPost(post.isLike, post.id, emoji)
            .then((response) async {});
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet,
            isSuccess: true);
      }
    });

    // update();
  }
}

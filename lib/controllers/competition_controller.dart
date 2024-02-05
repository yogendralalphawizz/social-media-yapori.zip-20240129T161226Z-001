import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../apiHandler/api_controller.dart';
import '../model/competition_model.dart';
import '../model/post_model.dart';
import '../screens/competitions/earn_coins_for_contest_popup.dart';
import '../screens/competitions/video_player_screen.dart';
import '../screens/home_feed/enlarge_image_view.dart';
import '../screens/post/select_media.dart';

class CompetitionController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  RxList<CompetitionModel> current = <CompetitionModel>[].obs;
  RxList<CompetitionModel> completed = <CompetitionModel>[].obs;
  RxList<CompetitionModel> winners = <CompetitionModel>[].obs;
  RxList<CompetitionModel> allCompetitions = <CompetitionModel>[].obs;

  // late ApiResponseModel competitionResponse;
  final picker = ImagePicker();

  Rx<CompetitionModel?> competition = Rx<CompetitionModel?>(null);

  int page = 1;
  bool canLoadMoreCompetition = true;
  RxBool isLoadingCompetition = false.obs;

  clear() {
    current.clear();
    completed.clear();
    winners.clear();
    allCompetitions.clear();

    page = 1;
    canLoadMoreCompetition = true;
    isLoadingCompetition.value = false;
  }

  getCompetitions(VoidCallback callback) async {
    if (canLoadMoreCompetition) {
      await ApiController().getCompetitions(page: page).then((response) {
        allCompetitions.addAll(response.competitions);
        allCompetitions.value = allCompetitions.toSet().toList();

        current.value =
            allCompetitions.where((element) => element.isOngoing).toList();
        completed.value =
            allCompetitions.where((element) => element.isPast).toList();
        winners.value = allCompetitions
            .where((element) => element.winnerAnnounced())
            .toList();

        isLoadingCompetition.value = false;

        if (response.competitions.length == response.metaData?.perPage) {
          canLoadMoreCompetition = true;
        } else {
          canLoadMoreCompetition = false;
        }
        page += 1;

        callback();

        update();
      });
    } else {
      callback();
    }
  }

  // Future<String> loadVideoThumbnail(String videoPath) async {
  //   final fileName = await VideoThumbnail.thumbnailFile(
  //     video: videoPath,
  //     thumbnailPath: (await getTemporaryDirectory()).path,
  //     imageFormat: ImageFormat.PNG,
  //     maxHeight: 64,
  //     // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
  //     quality: 75,
  //   );
  //
  //   return fileName!;
  // }

  setCompetition(CompetitionModel modal) {
    competition.value = modal;
    update();
  }

  loadCompetitionDetail({required int id}) {
    ApiController().getCompetitionsDetail(id).then((response) {
      competition.value = response.competition;

      update();
    });
  }

  void joinCompetition(CompetitionModel competition, BuildContext context) {
    int coin = _userProfileManager.user.value!.coins;

    if (coin >= competition.joiningFee) {
      AppUtil.checkInternet().then((value) {
        if (value) {
          EasyLoading.show(status: LocalizationString.loading);
          ApiController()
              .joinCompetition(competition.id)
              .then((response) async {
            EasyLoading.dismiss();
            AppUtil.showToast(
                 message: response.message, isSuccess: true);
            competition.isJoined = 1;
            update();
            _userProfileManager.refreshProfile();
          });
        } else {
          AppUtil.showToast(
              message: LocalizationString.noInternet,
              isSuccess: false);
        }
      });
    } else {
      Get.to(() =>
          EarnCoinForContestPopup(needCoins: competition.joiningFee - coin));
    }
  }

  viewMySubmission(CompetitionModel competition) async {
    var loggedInUserPost = competition.posts
        .where((element) =>
            element.user.id == _userProfileManager.user.value!.id)
        .toList();
    //User have already published post for this competition
    PostModel postModel = loggedInUserPost.first;
    // File path = await AppUtil.findPath(postModel.gallery.first.filePath);

    if (competition.competitionMediaType == 1) {
      Get.to(() => EnlargeImageViewScreen(model: postModel, handler: () {}));
    } else {
      Get.to(() => PlayVideoController(
            media: postModel.gallery.first,
          ));
    }
  }

  submitMedia(CompetitionModel competition) async {
    if (competition.competitionMediaType == 1) {
      Get.to(() => SelectMedia(
        isClips: false,
            mediaType: PostMediaType.photo,
            competitionId: competition.id,
          ));
    } else {
      Get.to(() => SelectMedia(
        isClips: false,
            mediaType: PostMediaType.video,
            competitionId: competition.id,
          ));
    }
  }
}

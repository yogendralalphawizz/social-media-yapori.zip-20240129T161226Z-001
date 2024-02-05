import 'dart:io';
import 'package:camera/camera.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/club_imports.dart';
import '../../apiHandler/api_controller.dart';
import '../../model/category_model.dart';

class CreateClubController extends GetxController {
  final ClubsController _clubsController = ClubsController();

  RxInt privacyType = 1.obs;

  RxBool enableChat = false.obs;
  Rx<CategoryModel?> category = Rx<CategoryModel?>(null);
  Rx<File?> imageFile = Rx<File?>(null);

  clear() {
    privacyType.value = 1;
    enableChat.value = false;
    imageFile.value = null;
    category.value = null;
  }

  privacyTypeChange(int type) {
    privacyType.value = type;
    update();

  }

  toggleChatGroup() {
    enableChat.value = !enableChat.value;
  }

  createClub(
      ClubModel club, BuildContext context, VoidCallback callback, privacyTyp) async {
    EasyLoading.show(status: LocalizationString.loading);

    await ApiController()
        .uploadFile(file: imageFile.value!.path, type: UploadMediaType.club)
        .then((response) async {
      if (response.postedMediaFileName != null) {
        print('this is privacuy mode ${privacyTyp} ${privacyType.value}');
        ApiController()
            .createClub(
                categoryId: club.categoryId!,
                isOnRequestType: privacyType.value == 3 ? 1 : 0,
                privacyMode: privacyTyp,
                enableChatRoom: club.enableChat!,
                name: club.name!,
                image: response.postedMediaFileName!,
                description: club.desc!)
            .then((response) {
          EasyLoading.dismiss();
          _clubsController.refreshClubs();
          Get.close(3);
          clear();

          Get.to(() => InviteUsersToClub(clubId: response.clubId!));
        });
      } else {
        EasyLoading.dismiss();
        AppUtil.showToast(
            message: LocalizationString.errorMessage,
            isSuccess: false);
      }
    });
  }

  void editClubImageAction(XFile pickedFile, BuildContext context) async {
    imageFile.value = File(pickedFile.path);
    imageFile.refresh();
  }

  updateClubImage(ClubModel club, BuildContext context,
      Function(ClubModel) callback) async {
    EasyLoading.show(status: LocalizationString.loading);

    await ApiController()
        .uploadFile(file: imageFile.value!.path, type: UploadMediaType.club)
        .then((response) async {
      if (response.postedMediaFileName != null) {
        club.imageName = response.postedMediaFileName!;
        club.image = response.postedMediaCompletePath!;

        updateClubInfo(
            club: club,
            callback: () {
              callback(club);
            });
      } else {
        EasyLoading.dismiss();
        AppUtil.showToast(
            message: LocalizationString.errorMessage,
            isSuccess: false);
      }
    });
  }

  updateClubInfo({required ClubModel club, required VoidCallback callback}) {
    EasyLoading.show(status: LocalizationString.loading);

    ApiController()
        .updateClub(
            clubId: club.id!,
            categoryId: club.categoryId!,
            privacyMode: 1,
            name: club.name!,
            image: club.imageName!,
            description: club.desc!)
        .then((response) {
      EasyLoading.dismiss();
      Get.back();
      callback();
    });
  }
}

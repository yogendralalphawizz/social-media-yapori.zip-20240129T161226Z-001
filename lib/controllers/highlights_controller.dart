import 'dart:io';
import 'dart:typed_data';

import 'package:foap/components/custom_gallery_picker.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/highlights_imports.dart';
import 'package:get/get.dart';

import '../apiHandler/api_controller.dart';
import '../model/story_model.dart';

class HighlightsController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  RxList<HighlightsModel> highlights = <HighlightsModel>[].obs;
  RxList<StoryMediaModel> selectedStoriesMedia = <StoryMediaModel>[].obs;
  RxList<StoryMediaModel> stories = <StoryMediaModel>[].obs;

  Rx<HighlightMediaModel?> storyMediaModel = Rx<HighlightMediaModel?>(null);

  String coverImage = '';
  String coverImageName = '';

  File? pickedImage;
  String? picture;
  UserModel? model;

  bool isLoading = true;

  clear(){
    selectedStoriesMedia.clear();
  }

  setCurrentStoryMedia(HighlightMediaModel storyMedia) {
    storyMediaModel.value = storyMedia;
    update();
  }

  updateCoverImage(File? image) {
    pickedImage = image;
    update();
  }

  updateCoverImagePath(String coverImage, List<StoryMediaModel> selectedStory) {
    for (StoryMediaModel media in selectedStory) {
      print('this is coverimage ${media}');
      if (media.image != null) {
        coverImage = media.image!;
        coverImageName = media.imageName!;
        break;
      }
    }
    coverImageName = coverImage;
    update();
  }

  void getHighlights({required int userId}) {
    AppUtil.checkInternet().then((value) {
      if (value) {
        // isLoading = true;
        update();
        ApiController().getHighlights(userId: userId).then((response) async {
          isLoading = false;
          highlights.value = response.success ? response.highlights : [];
          update();
        });
      }
    });
  }

  getAllStories() async {
    isLoading = true;
    update();
     ApiController().getMyStories().then((response) {
      stories.value = response.myStories;
      print('-----$isLoading');
      isLoading = false;
      update();
    });
  }

  createHighlights({required String name, List<StoryMediaModel>? selectedStory}) async {
    if (pickedImage != null) {
      await uploadCoverImage();
    }else{
      await updateCoverImagePath('', selectedStory!);
    }

    EasyLoading.show(status: LocalizationString.loading);
    ApiController()
        .createHighlight(
            name: name,
            image: coverImageName,
        stories: selectedStory!
            .map((element) => element.id.toString())
            .toList()
            .join(','))
            // stories: selectedStoriesMedia
            //     .map((element) => element.id.toString())
            //     .toList()
            //     .join(','))
        .then((value) async {
      getHighlights(userId: _userProfileManager.user.value!.id);
      EasyLoading.dismiss();

      Get.close(3);
      // Get.offAll(const DashboardScreen(selectedTab: 4));
    });
  }

  Future uploadCoverImage() async {
    Uint8List compressedData = await pickedImage!.compress();
    File file = File.fromRawPath(compressedData);
    await ApiController()
        .uploadFile(file: file.path, type: UploadMediaType.storyOrHighlights)
        .then((response) async {
      coverImageName = response.postedMediaFileName!;
    });
  }

  deleteStoryFromHighlight() async {
    await ApiController()
        .deleteStoryFromHighlights(id: storyMediaModel.value!.id)
        .then((response) async {});
  }
}

import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/story_editor.dart';
import 'package:foap/screens/picked_image_editor.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:foap/manager/db_manager.dart';
import 'package:foap/apiHandler/api_controller.dart';
import 'package:foap/components/custom_gallery_picker.dart';
import 'package:foap/model/story_model.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/chat/media.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:path_provider/path_provider.dart';


import '../model/post_gallery.dart';

class AppStoryController extends GetxController {
  RxList<Media> mediaList = <Media>[].obs;
  // List<Media> mediaList = [];
  RxBool allowMultipleSelection = false.obs;
  RxInt numberOfItems = 0.obs;

  Rx<StoryMediaModel?> storyMediaModel = Rx<StoryMediaModel?>(null);
  bool isLoading = false;
  Future<Uint8List> fileToUint8List(File file) async {
    try {
      // Read the file as bytes
      List<int> fileBytes = await file.readAsBytes();

      // Convert the list of bytes to a Uint8List
      Uint8List uint8List = Uint8List.fromList(fileBytes);

      return uint8List;
    } catch (e) {
      // Handle any errors that may occur during the file reading process
      print("Error converting file to Uint8List: $e");
      return Uint8List(0); // Return an empty Uint8List in case of an error
    }
  }

  mediaSelected(List<Media> media, BuildContext context) async {

    if (media[0].mediaType == GalleryMediaType.photo) {
      Uint8List uint8List = await fileToUint8List(media[0].file!);
      print("mediaSelected got invoked");
      List<Media> editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PickedImageEditor(
                image: uint8List,
              ),
        ),
      );
      print('this is selected $editedImage');
      // replace with edited image
      if (editedImage != null) {

        // mediaList.addAll(im);
        update();
        mediaList.value = editedImage;
      }
  }else{
      update();
      mediaList.value = media;
    }

  }

  toggleMultiSelectionMode() {
    allowMultipleSelection.value = !allowMultipleSelection.value;
    update();
  }

  deleteStory(VoidCallback callback) async {
    await ApiController()
        .deleteStory(id: storyMediaModel.value!.id)
        .then((response) async {
      if (response.success) {
        callback();
        // AppUtil.showToast(
        //     context: Get.context!,
        //     message: LocalizationString.storyDeleteSuccessfully,
        //     isSuccess: true);
      }
    });
  }

  setCurrentStoryMedia(StoryMediaModel storyMedia) {
    storyMediaModel.value = storyMedia;
    getIt<DBManager>().storyViewed(storyMedia);
    update();
  }

  void uploadAllMedia(
      {required List<Media> items, required BuildContext context}) async {
    var responses =
        await Future.wait([for (Media media in items) uploadMedia(media)])
            .whenComplete(() {});

    publishAction(galleryItems: responses, isPosts: false);
  }

  Future<Map<String, String>> uploadMedia(Media media) async {
    Map<String, String> gallery = {};

    await AppUtil.checkInternet().then((value) async {
      if (value) {
        final tempDir = await getTemporaryDirectory();
        File mainFile;
        String? videoThumbnailPath;

        if (media.mediaType == GalleryMediaType.photo) {
          Uint8List mainFileData = await media.file!.compress();
          //image media
          mainFile =
              await File('${tempDir.path}/${media.id!.replaceAll('/', '')}.png')
                  .create();
          mainFile.writeAsBytesSync(mainFileData);
        } else {
          Uint8List mainFileData = media.file!.readAsBytesSync();
          // video
          mainFile =
              await File('${tempDir.path}/${media.id!.replaceAll('/', '')}.mp4')
                  .create();
          mainFile.writeAsBytesSync(mainFileData);

          File videoThumbnail = await File(
                  '${tempDir.path}/${media.id!.replaceAll('/', '')}_thumbnail.png')
              .create();

          videoThumbnail.writeAsBytesSync(media.thumbnail!);

          await ApiController()
              .uploadFile(
                  file: videoThumbnail.path,
                  type: UploadMediaType.storyOrHighlights)
              .then((response) async {
            videoThumbnailPath = response.postedMediaFileName!;
            await videoThumbnail.delete();
          });
        }

        EasyLoading.show(status: LocalizationString.loading);
        await ApiController()
            .uploadFile(
                file: mainFile.path, type: UploadMediaType.storyOrHighlights)
            .then((response) async {
          String mainFileUploadedPath = response.postedMediaFileName!;
          await mainFile.delete();
          gallery = {
            // 'image': media.mediaType == 1 ? mainFileUploadedPath : '',
            'image': media.mediaType == GalleryMediaType.photo
                ? mainFileUploadedPath
                : videoThumbnailPath!,
            'video': media.mediaType == GalleryMediaType.photo
                ? ''
                : mainFileUploadedPath,
            'type': media.mediaType == GalleryMediaType.photo ? '2' : '3',
            'description': '',
            'background_color': '',
          };
        });
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet, isSuccess: false);
      }
    });
    return gallery;
  }

  void publishAction({
    required List<Map<String, String>> galleryItems,
    List<Map<String, String>>? postItems,
    required bool isPosts
  }) {
    AppUtil.checkInternet().then((value) async {
      EasyLoading.dismiss();

      if (value) {
        print('story added success!!!');
        if(isPosts) {
          ApiController()
              .postStoryViaPost(
            gallery: postItems!,
          )
              .then((response) async {
            Get.offAll(const DashboardScreen());
          });
        }else{
          ApiController()
              .postStory(
            gallery: galleryItems,
          )
              .then((response) async {
            Get.offAll(const DashboardScreen());
          });
        }
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet, isSuccess: false);
      }
    });
  }

// isSelected(String id) {
//   return selectedItems.where((item) => item.id == id).isNotEmpty;
// }
//
// selectItem(int index) async {
//   var galleryImage = mediaList[index];
//
//   if (isSelected(galleryImage.id)) {
//     selectedItems.removeWhere((anItem) => anItem.id == galleryImage.id);
//     // if (selectedItems.isEmpty) {
//     //   print('4');
//     //
//     //   selectedItems.add(galleryImage);
//     // }
//   } else {
//     if (selectedItems.length < 10) {
//       selectedItems.add(galleryImage);
//     }
//   }
//
//   update();
// }
}

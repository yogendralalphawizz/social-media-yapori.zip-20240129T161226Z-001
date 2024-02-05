import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:foap/components/custom_camera/delegates/camera_picker_text_delegate.dart';
import 'package:foap/components/gallery_picker/gallery_media_picker.dart';
import 'package:foap/helper/file_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../screens/chat/media.dart';
import 'custom_camera/constants/config.dart';
import 'custom_camera/constants/constants.dart';
import 'custom_camera/widgets/camera_picker.dart';

extension FileCompressor on File {
  Future<Uint8List> compress(
      {int? byQuality, int? minWidth, int? minHeight}) async {
    var result = await FlutterImageCompress.compressWithFile(
      absolute.path,
      minWidth: minWidth ?? 1000,
      minHeight: minHeight ?? 1000,
      quality: byQuality ?? 60,
      rotate: 0,
    );

    return result!;
  }
}

extension PickedAssetModelExtension on PickedAssetModel {
  Media toMedia() {
    Media media = Media();
    media.id = id;
    media.file = file;
    media.thumbnail = thumbnail;
    media.size = size;
    media.creationTime = createDateTime;
    media.title = title;
    media.mediaType =
        type == 'image' ? GalleryMediaType.photo : GalleryMediaType.video;
    return media;
  }
}

class CustomGalleryPickerController extends GetxController {
  RxBool allowMultipleSelection = false.obs;

  toggleMultiSelectionMode() {
    allowMultipleSelection.value = !allowMultipleSelection.value;
    update();
  }
}

class CustomGalleryPicker extends StatefulWidget {
  final Function(List<Media>) mediaSelectionCompletion;
  final Function(Media) mediaCapturedCompletion;
  final PostMediaType? mediaType;
  final bool? hideMultiSelection;
  final bool? isClips;

  const CustomGalleryPicker({
    Key? key,
    required this.mediaSelectionCompletion,
    required this.mediaCapturedCompletion,
    this.mediaType,
    this.hideMultiSelection,
    this.isClips
  }) : super(key: key);

  @override
  State<CustomGalleryPicker> createState() => _CustomGalleryPickerState();
}

class _CustomGalleryPickerState extends State<CustomGalleryPicker> {
  final CustomGalleryPickerController _customGalleryPickerController =
      CustomGalleryPickerController();

  getFileSize(String filepath, int decimals) async {
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => GalleryMediaPicker(
          childAspectRatio: 1,
          crossAxisCount: 3,
          thumbnailQuality: 150,
          thumbnailBoxFix: BoxFit.cover,
          singlePick:
              !_customGalleryPickerController.allowMultipleSelection.value,
          gridViewBackgroundColor: AppColorConstants.backgroundColor,
          imageBackgroundColor: Colors.black,
          maxPickImages: 10,
          appBarHeight: 50,
          selectedBackgroundColor: AppColorConstants.backgroundColor,
          selectedCheckColor: Colors.black87,
          selectedCheckBackgroundColor: Colors.white10,
          onlyVideos: widget.mediaType == PostMediaType.video,
          onlyImages: widget.mediaType == PostMediaType.photo,
          pathList: (paths) {
            print('ac1');
            print(paths[0].file!.path);
            print(getFileSize(paths[0].file!.path, 1));
            print('----->>${paths[0].file!.length().toString()}');
            List<Media> medias = paths.map((e) => e.toMedia()).toList();
            widget.mediaSelectionCompletion(medias);
            // storyController.mediaSelected(paths);
          },
      appBarTextColor: AppColorConstants.whiteClr,
      // appBarColor: AppColorConstants.backgroundColor,
          appBarLeadingWidget: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                  padding: const EdgeInsets.only(right: 15, bottom: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.hideMultiSelection == true
                          ? Container()
                          : Container(
                              height: 30,
                              width: 30,
                              color: _customGalleryPickerController
                                          .allowMultipleSelection.value ==
                                      true
                                  ? AppColorConstants.themeColor
                                  : Colors.transparent,
                              child: const ThemeIconWidget(
                                ThemeIcon.selectionType,
                                color: Colors.white,
                                size: 18,
                              ),
                            ).circular.ripple(() {
                              _customGalleryPickerController
                                  .toggleMultiSelectionMode();
                            }),
                      const SizedBox(
                        width: 20,
                      ),
                      const ThemeIconWidget(
                        ThemeIcon.camera,
                        color: Colors.white,
                        size: 18,
                      ).circular.ripple(() {
                        handleCameraPress();
                      }),
                      // const SizedBox(
                      //   width: 20,
                      // ),
                    ],
                  ))
          ),
      isClips: widget.isClips
        ));
  }

  void handleCameraPress() async {
    final AssetEntity? entity = await CameraPicker.pickFromCamera(
      context,
      pickerConfig: const CameraPickerConfig(
          enableRecording: true,
          shouldAutoPreviewVideo: true,
          maximumRecordingDuration: Duration(seconds: 60),
          enablePinchToZoom: true,
          textDelegate: EnglishCameraPickerTextDelegate()),
    );

    if (entity != null) {
      Uint8List? thumbnailData = await entity.thumbnailData;
      // Uint8List? mediaByte = await entity.originBytes;
      File? file = await entity.originFile;

      Media media = Media();
      media.id = entity.id;
      media.file = file!;
      media.thumbnail = thumbnailData!;
      // media.size = size;
      media.creationTime = DateTime.now();
      media.title = '';
      media.mediaType = file.mediaType;

      widget.mediaCapturedCompletion(media);
    }
  }
}

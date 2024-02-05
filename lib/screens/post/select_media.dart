import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cross_file/src/types/interface.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/reel/create_reel_controller.dart';
import 'package:foap/screens/picked_image_editor.dart';
import 'package:foap/util/constant_util.dart';
import 'package:get/get.dart';
import 'package:image_editor_plus/data/image_item.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../components/custom_gallery_picker.dart';
import '../../components/video_widget.dart';
import '../../controllers/select_post_media_controller.dart';
import '../chat/media.dart';
import '../settings_menu/settings_controller.dart';
import 'add_post_screen.dart';

class SelectMedia extends StatefulWidget {
  final int? competitionId;
  final int? clubId;
  final PostMediaType? mediaType;
  final bool? isClips;

  const SelectMedia({Key? key, this.competitionId, this.mediaType, this.clubId, this.isClips})
      : super(key: key);

  @override
  State<SelectMedia> createState() => _SelectMediaState();
}

class _SelectMediaState extends State<SelectMedia> {
  final SelectPostMediaController _selectPostMediaController =
      SelectPostMediaController();
  final SettingsController _settingsController = Get.find();
  final CreateReelController _createReelController = Get.find();
  late PostMediaType mediaType;
  ScreenshotController screenshotController = ScreenshotController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectPostMediaController.clear();
    });
    mediaType = widget.mediaType ?? PostMediaType.all;

    if (_settingsController.setting.value!.enableImagePost &&
        _settingsController.setting.value!.enableVideoPost) {
      mediaType = widget.mediaType ?? PostMediaType.all;
    }
    else if (_settingsController.setting.value!.enableImagePost) {
      mediaType = widget.mediaType ?? PostMediaType.photo;
    }
    else if (_settingsController.setting.value!.enableVideoPost) {
      mediaType = widget.mediaType ?? PostMediaType.video;
    }

    super.initState();
  }

  File? farzi;
  Future<File> uint8ListToFile(Uint8List uint8List, String filePath) async {
    try {
      // Create a new file at the specified path
      File file = File(filePath);

      // Write the bytes from the Uint8List to the file
      await file.writeAsBytes(uint8List);

      return file;
    } catch (e) {
      // Handle any errors that may occur during the file writing process
      print("Error converting Uint8List to file: $e");
      return farzi!; // Return null in case of an error
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 55,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ThemeIconWidget(
                ThemeIcon.close,
                color: AppColorConstants.themeColor,
                size: 27,
              ).ripple(() {
                Navigator.pop(context);
              }),
              const Spacer(),
              // Image.asset(
              //   'assets/logo.png',
              //   width: 80,
              //   height: 25,
              // ),
              const Spacer(),
              ThemeIconWidget(
                ThemeIcon.nextArrow,
                color: AppColorConstants.themeColor,
                size: 27,
              ).ripple(() async {
                if (_selectPostMediaController.selectedMediaList.length == 1) {
                  if (_selectPostMediaController.selectedMediaList[0]
                      .mediaType == GalleryMediaType.video) {
                    // Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoFilterScreen()));

                    if(widget.isClips!) {
                      final file = File(_selectPostMediaController.selectedMediaList.first.file!.path.toString());
                      int sizeInBytes = file.lengthSync();
                      double sizeInMb = sizeInBytes / (1024 * 1024);
                      if (sizeInMb > 50){
                        AppUtil.showToast(message: 'File size exceeds the limit of 50 MB.', isSuccess: false);
                      }else {
                        Get.to(() =>
                            AddPostScreen(
                              items: _selectPostMediaController
                                  .selectedMediaList,
                              competitionId: widget.competitionId,
                              clubId: widget.clubId,
                              isReel: true,
                            ));
                      }
                    }else {
                      final file = File(_selectPostMediaController.selectedMediaList.first.file!.path.toString());
                      int sizeInBytes = file.lengthSync();
                      double sizeInMb = sizeInBytes / (1024 * 1024);
                      if (sizeInMb > 50){
                        AppUtil.showToast(message: 'File size exceeds the limit of 50 MB.', isSuccess: false);
                      }else {
                        // print('this is filesize ${_selectPostMediaController.selectedMediaList.first.fileSize}');
                        // if(_selectPostMediaController.selectedMediaList.first.fileSize! < 50) {
                        Get.to(() =>
                            AddPostScreen(
                              items: _selectPostMediaController
                                  .selectedMediaList,
                              competitionId: widget.competitionId,
                              clubId: widget.clubId,
                              isReel: false,
                            ));
                      }
                      // }else{
                      //   AppUtil.showToast(message: 'Video Size should not be more than 50 mbs', isSuccess: true);
                      // }
                      // _createReelController.createReel(
                      //     _createReelController.croppedAudioFile,
                      //     _selectPostMediaController.selectedMediaList,
                      //     widget.competitionId,
                      //     widget.clubId);

                    }
                  } else {
                    Uint8List uint8List = await fileToUint8List(
                        _selectPostMediaController.selectedMediaList[0].file!);
                    List<Media> editedImage = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PickedImageEditor(
                              image: uint8List,
                            ),
                      ),
                    );

                    // replace with edited image
                    if (editedImage != null) {
                      _selectPostMediaController.selectedMediaList.value = editedImage;
                      setState((){});
                      Get.to(() =>
                          AddPostScreen(
                            items: _selectPostMediaController.selectedMediaList,
                            competitionId: widget.competitionId,
                            clubId: widget.clubId,
                            isReel: false
                          ));
                  /*    Uint8List uint8List = Uint8List.fromList([65, 66, 67]); // Example Uint8List

                      final directory = (await getApplicationDocumentsDirectory())
                          .path;
                      String filePath = '$directory/${DateTime.now()}.png'; //
                      File file = await uint8ListToFile(uint8List, filePath);

                      if (file != null) {
                        Media med = Media();
                        List<Media> media = [];
                        med.id = randomId();
                        med.thumbnail = null;
                        med.size = null;
                        med.creationTime = DateTime.now();
                        med.title = null;
                        med.file = file;
                        med.mediaType = GalleryMediaType.photo;
                        media.add(med);

                        // imgFile.writeAsBytes(pngBytes!).then((value) {
                        // done: return imgFile
                        // Navigator.of(context).pop(media);
                        _selectPostMediaController.selectedMediaList.value = media;
                        print("File saved successfully: ${file.path}");
                      } else {
                        print("File conversion failed.");
                      }*/

                      ///
                      // final directory = (await getApplicationDocumentsDirectory())
                      //     .path;
                      // Uint8List? pngBytes = await screenshotController
                      //     .capture();
                      // print('captured: $pngBytes');

                      // File imgFile = File('$directory/${DateTime.now()}.png');
                      // Media med = Media();
                      // List<Media> media = [];
                      // med.id = randomId();
                      // med.thumbnail = null;
                      // med.size = null;
                      // med.creationTime = DateTime.now();
                      // med.title = null;
                      // med.file = editedImage;
                      // med.mediaType = GalleryMediaType.photo;
                      // media.add(med);
                      //
                      // // imgFile.writeAsBytes(pngBytes!).then((value) {
                      //   // done: return imgFile
                      //   // Navigator.of(context).pop(media);
                      //   _selectPostMediaController.selectedMediaList.value = media;
                      //   setState(() {});
                      // });
                    } else {
                      Get.to(() =>
                          AddPostScreen(
                            items: _selectPostMediaController.selectedMediaList,
                            competitionId: widget.competitionId,
                            clubId: widget.clubId,
                          ));
                    }
                  }
                }
                else {
                  Get.to(() =>
                      AddPostScreen(
                        items: _selectPostMediaController.selectedMediaList,
                        competitionId: widget.competitionId,
                        clubId: widget.clubId,
                      ));
                }
              }
      ),
            ],
          ).hp(20),
          const SizedBox(height: 20),
          Stack(
            children: [
              AspectRatio(
                  aspectRatio: 1.2,
                  child: Obx(() {
                    return CarouselSlider(
                      items: [
                        for (Media media
                            in _selectPostMediaController.selectedMediaList)
                          media.mediaType == GalleryMediaType.photo
                              ? Image.file(media.file!, fit: BoxFit.cover)
                              : VideoPostTile(
                                  url: media.file!.path,
                                  isLocalFile: true,
                                  play: true,
                                )
                      ],
                      options: CarouselOptions(
                        aspectRatio: 1,
                        enlargeCenterPage: false,
                        enableInfiniteScroll: false,
                        height: double.infinity,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) {
                          _selectPostMediaController.updateGallerySlider(index);
                        },
                      ),
                    );
                  })),
              Obx(() {
                return _selectPostMediaController.selectedMediaList.length > 1
                    ? Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Align(
                            alignment: Alignment.center,
                            child: DotsIndicator(
                              dotsCount: _selectPostMediaController
                                  .selectedMediaList.length,
                              position: _selectPostMediaController
                                  .currentIndex.value
                                  .toDouble(),
                              decorator: DotsDecorator(
                                  activeColor: AppColorConstants.themeColor),
                            )))
                    : Container();
              })
            ],
          ).p16,
          Expanded(
              child: CustomGalleryPicker(
            hideMultiSelection: widget.competitionId != null,
            mediaType: mediaType,
            mediaSelectionCompletion: (medias) {
              _selectPostMediaController.mediaSelected(medias);
            },
            mediaCapturedCompletion: (media) async{
              if (media.mediaType == GalleryMediaType.video) {
                // _createReelController.createReel(
                //     _createReelController.croppedAudioFile,
                //     _selectPostMediaController.selectedMediaList,
                //    widget.competitionId,
                //    widget.clubId,);

                Get.to(() => AddPostScreen(
                      items: _selectPostMediaController.selectedMediaList,
                     competitionId: widget.competitionId,
                      clubId: widget.clubId,
                    ));
              } else {
                Uint8List uint8List = await fileToUint8List(
                    media.file!);
                List<Media> editedImage = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PickedImageEditor(
                          image: uint8List,
                        ),
                  ),
                );
                if (editedImage != null) {
                  media = editedImage[0];
                  setState((){});
                  Get.to(() =>
                      AddPostScreen(
                        items: editedImage,
                        competitionId: widget.competitionId,
                        clubId: widget.clubId,
                      ));
                  /*    Uint8List uint8List = Uint8List.fromList([65, 66, 67]); // Example Uint8List

                      final directory = (await getApplicationDocumentsDirectory())
                          .path;
                      String filePath = '$directory/${DateTime.now()}.png'; //
                      File file = await uint8ListToFile(uint8List, filePath);

                      if (file != null) {
                        Media med = Media();
                        List<Media> media = [];
                        med.id = randomId();
                        med.thumbnail = null;
                        med.size = null;
                        med.creationTime = DateTime.now();
                        med.title = null;
                        med.file = file;
                        med.mediaType = GalleryMediaType.photo;
                        media.add(med);

                        // imgFile.writeAsBytes(pngBytes!).then((value) {
                        // done: return imgFile
                        // Navigator.of(context).pop(media);
                        _selectPostMediaController.selectedMediaList.value = media;
                        print("File saved successfully: ${file.path}");
                      } else {
                        print("File conversion failed.");
                      }*/

                  ///
                  // final directory = (await getApplicationDocumentsDirectory())
                  //     .path;
                  // Uint8List? pngBytes = await screenshotController
                  //     .capture();
                  // print('captured: $pngBytes');

                  // File imgFile = File('$directory/${DateTime.now()}.png');
                  // Media med = Media();
                  // List<Media> media = [];
                  // med.id = randomId();
                  // med.thumbnail = null;
                  // med.size = null;
                  // med.creationTime = DateTime.now();
                  // med.title = null;
                  // med.file = editedImage;
                  // med.mediaType = GalleryMediaType.photo;
                  // media.add(med);
                  //
                  // // imgFile.writeAsBytes(pngBytes!).then((value) {
                  //   // done: return imgFile
                  //   // Navigator.of(context).pop(media);
                  //   _selectPostMediaController.selectedMediaList.value = media;
                  //   setState(() {});
                  // });
                } else {
                  Get.to(() =>
                      AddPostScreen(
                        items: _selectPostMediaController.selectedMediaList,
                        competitionId: widget.competitionId,
                        clubId: widget.clubId,
                      ));
                }
              }

            //   Get.to(() => AddPostScreen(
            //         items: [media],
            //         competitionId: widget.competitionId,
            //         clubId: widget.clubId,
            //       ));
            },
                isClips: widget.isClips
          ))
        ],
      ),
    );
  }
}

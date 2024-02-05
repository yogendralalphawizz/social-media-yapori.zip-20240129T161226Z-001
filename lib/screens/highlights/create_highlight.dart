import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/highlights_imports.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/story_model.dart';

class CreateHighlight extends StatefulWidget {
  final String? coverImage;
  final List<StoryMediaModel>? post;
  const CreateHighlight({Key? key, this.coverImage, this.post}) : super(key: key);

  @override
  State<CreateHighlight> createState() => _CreateHighlightState();
}

class _CreateHighlightState extends State<CreateHighlight> {
  final HighlightsController _highlightsController = HighlightsController();
  TextEditingController nameText = TextEditingController();
  final picker = ImagePicker();



  @override
  void initState() {
    _highlightsController.updateCoverImagePath(widget.coverImage!, widget.post!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                size: 20,
              ).ripple(() {
                Get.back();
              }),
              // const Spacer(),
              // Heading6Text(LocalizationString.create,
              //         weight: TextWeight.medium,
              //         color: AppColorConstants.themeColor)
              //     .ripple(() {
              //   // create highlights
              //   if (nameText.text.isNotEmpty) {
              //     _highlightsController.createHighlights(name: nameText.text, selectedStory: widget.post);
              //   } else {
              //     AppUtil.showToast(
              //         message: LocalizationString.pleaseEnterTitle,
              //         isSuccess: false);
              //   }
              // }),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          addProfileView(),

          BodyLargeText(LocalizationString.chooseCoverImage,
                  weight: TextWeight.bold, color: AppColorConstants.themeColor)
              .ripple(() {
            openImagePickingPopup();
          }),
          const SizedBox(
            height: 25,
          ),
          Center(
            child: TextField(
              controller: nameText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: FontSizes.b3),
              maxLines: 5,
              onChanged: (text) {},
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(left: 10, right: 10),
                  counterText: "",
                  labelStyle: TextStyle(
                      fontSize: FontSizes.b2,
                      color: AppColorConstants.themeColor),
                  hintStyle: TextStyle(
                      fontSize: FontSizes.h5,
                      color: AppColorConstants.themeColor),
                  hintText: LocalizationString.enterHighlightName),
            ),
          )
        ],
      ).hP16,
    );
  }

  addProfileView() {
    return SizedBox(
      // height: 100,
      child: GetBuilder<HighlightsController>(
              init: _highlightsController,
              builder: (ctx) {
                return Container(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColorConstants.themeColor,
                    child: _highlightsController.pickedImage != null
                        ? Image.file(
                            _highlightsController.pickedImage!,
                            fit: BoxFit.cover,
                            height: 64,
                            width: 64,
                          ).circular
                        :
                    _highlightsController.model == null ||
                                _highlightsController.model?.picture == null
                            ? CachedNetworkImage(
                                imageUrl: widget.coverImage!,
                                // _highlightsController
                                //     .selectedStoriesMedia[0].image.toString(),
                                fit: BoxFit.cover,
                                height: 64,
                                width: 64,
                              ).circular
                            :
                   ClipRRect(
                                borderRadius: BorderRadius.circular(32.0),
                                child: CachedNetworkImage(
                                  imageUrl:
                                       _highlightsController.model!.picture!,
                                  fit: BoxFit.cover,
                                  height: 64.0,
                                  width: 64.0,
                                  placeholder: (context, url) =>
                                      AppUtil.addProgressIndicator(
                                          size:100),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    color: AppColorConstants.iconColor,
                                  ),
                                )),
                  ).p4,

                );
              })
          .borderWithRadius(
              value: 2,
              radius: 64,
              color: AppColorConstants.themeColor)
          .ripple(() {
        openImagePickingPopup();
      }).p8,
    );
  }

  void openImagePickingPopup() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 25),
                    child: BodyLargeText(
                      LocalizationString.addPhoto,
                    )),
                ListTile(
                    leading: const Icon(Icons.camera_alt_outlined,
                        color: Colors.black87),
                    title: BodyLargeText(
                      LocalizationString.takePhoto,
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        _highlightsController
                            .updateCoverImage(File(pickedFile.path));
                      } else {}
                    }),
                divider(context: context),
                ListTile(
                    leading: const Icon(Icons.wallpaper_outlined,
                        color: Colors.black87),
                    title: BodyLargeText(
                      LocalizationString.chooseFromGallery,
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        _highlightsController
                            .updateCoverImage(File(pickedFile.path));
                      } else {}
                    }),
                divider(context: context),
                ListTile(
                    leading: const Icon(Icons.close, color: Colors.black87),
                    title: BodyLargeText(LocalizationString.cancel),
                    onTap: () => Get.back()),
              ],
            ));
  }
}

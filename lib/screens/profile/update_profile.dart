import 'package:flutter_switch/flutter_switch.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/profile_imports.dart';
import 'package:foap/screens/login_sign_up/set_profile_category_type.dart';
import 'package:foap/screens/profile/change_profile_bio.dart';
import 'package:foap/screens/profile/change_profile_gender.dart';
import 'package:foap/screens/profile/change_profile_qualification.dart';
import 'package:foap/screens/profile/change_profile_website.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key? key}) : super(key: key);

  @override
  UpdateProfileState createState() => UpdateProfileState();
}

class UpdateProfileState extends State<UpdateProfile> {
  bool isLoading = true;
  final picker = ImagePicker();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
    reloadData();
  }

  reloadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.setUser(_userProfileManager.user.value!);
    });
    profileController.isPrivate = _userProfileManager.user.value!.isPrivate!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // const SizedBox(
          //   height: 50,
          // ),
          // backNavigationBar(
          //     context: context, title: LocalizationString.editProfile),
          // divider(context: context).vP8,
          addProfileView(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                    child: Row(
                      children: [
                        BodyLargeText(
                          LocalizationString.profileMode,
                          weight: TextWeight.medium,
                        ),
                        const Spacer(),
                        FlutterSwitch(
                          inactiveColor: AppColorConstants.disabledColor,
                          activeColor: AppColorConstants.themeColor,
                          width: 50.0,
                          height: 30.0,
                          valueFontSize: 15.0,
                          toggleSize: 20.0,
                          value: profileController.isPrivate,
                          borderRadius: 30.0,
                          padding: 8.0,
                          // showOnOff: true,
                          onToggle: (val) {
                            setState(() {
                              profileController.isPrivate = val;
                            });
                            profileController.changePublicPrivateMode(val);
                          },
                          // )
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 20,),
                  // Obx(() =>

                  Row(
                    children: [
                      BodyLargeText(
                        LocalizationString.userName,
                        weight: TextWeight.medium,
                      ),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                              profileController.user.value!.userName,
                            )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangeUserName())!.then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider(context: context).vP16,
                  Row(
                    children: [
                      BodyLargeText(
                        LocalizationString.profession,
                        weight: TextWeight.medium,
                      ),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                              profileController.user.value!.profileCategoryTypeName,
                            )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const SetProfileCategoryType(
                                  isFromSignup: false,
                                ))!
                            .then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider(context: context).vP16,
                  Row(
                    children: [
                      BodyLargeText(
                        LocalizationString.password,
                        weight: TextWeight.medium,
                      ),
                      const Spacer(),
                      const BodyMediumText(
                        '********',
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangePassword());
                      })
                    ],
                  ),
                  divider(context: context).vP16,
                  Row(
                    children: [
                      BodyLargeText(
                        LocalizationString.phoneNumber,
                        weight: TextWeight.medium,
                      ),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                              profileController.user.value!.phone ?? '',
                            )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangePhoneNumber())!.then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider(context: context).vP16,
                  Row(
                    children: [
                      BodyLargeText(LocalizationString.paymentDetail,
                          weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? Container(
                        width: MediaQuery.of(context).size.width/2.5,
                            child: BodyMediumText(
                                profileController.user.value!.paypalId ?? '',
                        maxLines: 2,
                              ),
                          )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangePaypalId())!.then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider(context: context).vP16,
                  Row(
                    children: [
                      BodyLargeText(LocalizationString.bioData,
                          weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? Container(
                        width: MediaQuery.of(context).size.width/2.5,
                            child: BodyMediumText(
                        profileController.user.value!.bio ?? '',
                              maxLines: 2,
                      ),
                          )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangeBioData())!.then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider(context: context).vP16,
                  Row(
                    children: [
                      BodyLargeText(LocalizationString.gender,
                          weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                        profileController.user.value!.gender == '0' ? "" :
                        profileController.user.value!.gender == '1' ? "Male" :
                        profileController.user.value!.gender == '2' ? "Female"
                            : "Other" ?? '',
                      )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangeGender())!.then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider(context: context).vP16,
                  Row(
                    children: [
                      BodyLargeText(LocalizationString.qualification,
                          weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                        profileController.user.value!.qualification ?? '',
                      )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangeProfileQualification())!.then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider(context: context).vP16,
                  Row(
                    children: [
                      BodyLargeText(LocalizationString.websiteLinks,
                          weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                        profileController.user.value!.website ?? '',
                      )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangeWebsiteLinks())!.then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider(context: context).vP16,
               /*   Row(
                    children: [
                      BodyLargeText(LocalizationString.location,
                          weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => BodyMediumText(
                            '${profileController.user.value?.country ?? ''} ${profileController.user.value?.city ?? ''}',
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangeLocation())!.then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider(context: context).vP16,*/
                ],
              ).hP16,
            ),
          ),
        ],
      ),
    );
  }

  addProfileView() {
    return GetBuilder<ProfileController>(
        init: profileController,
        builder: (ctx) {
          return Container(
            color: Colors.black.withOpacity(0.4),
            height: 270,
            child: profileController.user.value != null
                ? Stack(
              alignment: Alignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            child:
                                profileController.user.value!.coverImage != null
                                    ? CachedNetworkImage(
                                            width: Get.width,
                                            height: 250,
                                            fit: BoxFit.cover,
                                            imageUrl: profileController
                                                .user.value!.coverImage!)
                                        .overlay(Colors.black26)
                                        .bottomRounded(20)
                                    : Container(
                                        width: Get.width,
                                        height: 250,
                                        color: AppColorConstants.themeColor
                                            .withOpacity(0.2),
                                      ).bottomRounded(20),
                          ),
                          Positioned(
                              bottom: 10,
                              right: 16,
                              child: Container(
                                color: AppColorConstants.cardColor,
                                child: BodyLargeText(
                                        LocalizationString.editProfileCover, color: AppColorConstants.iconColor,)
                                    .setPadding(
                                        left: 10, right: 10, top: 8, bottom: 8),
                              ).circular.ripple(() {
                                openImagePickingPopup(isCoverImage: true);
                              }))
                        ],
                      ),
                      Column(
                          children: [
                        const SizedBox(
                          height: 50,
                        ),
                        UserAvatarView(
                                user: profileController.user.value!,
                                size: 65,
                                onTapHandler: () {})
                            .ripple(() {
                          openImagePickingPopup(isCoverImage: false);
                        }),
                        BodyMediumText(
                          LocalizationString.editProfilePicture,
                          color: AppColorConstants.whiteClr,
                        ).vP4.ripple(() {
                          openImagePickingPopup(isCoverImage: false);
                        }),
                        Heading5Text(
                          profileController.user.value!.userName,
                          weight: TextWeight.medium,
                          color: AppColorConstants.whiteClr,
                        ).setPadding(bottom: 4),
                        profileController.user.value?.email != null
                            ? BodyMediumText(
                                '${profileController.user.value!.email}',
                          color: AppColorConstants.whiteClr,
                              )
                            : Container(),
                        profileController.user.value?.country != null
                            ? BodyMediumText(
                                profileController.user.value?.country ?? '',
                          color: AppColorConstants.whiteClr,
                              ).vP4
                            : Container(),
                      ]).p8,
                      Positioned(
                          top: 50,
                          left: 0,
                          right: 0,
                          child: backNavigationBar(context: context, title: ''))
                    ],
                  )
                : Container(),
          );
        });
  }

  void openImagePickingPopup({required bool isCoverImage}) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              color: AppColorConstants.cardColor,
              child: Wrap(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 25),
                      child: Heading5Text(
                        LocalizationString.addPhoto,
                        weight: TextWeight.bold,
                      )),
                  ListTile(
                      leading: Icon(Icons.camera_alt_outlined,
                          color: AppColorConstants.iconColor),
                      title: BodyLargeText(LocalizationString.takePhoto),
                      onTap: () {
                        Get.back();
                        picker
                            .pickImage(source: ImageSource.camera)
                            .then((pickedFile) {
                          if (pickedFile != null) {
                            profileController.editProfileImageAction(
                                pickedFile, isCoverImage);
                          } else {}
                        });
                      }),
                  divider(context: context),
                  ListTile(
                      leading: Icon(Icons.wallpaper_outlined,
                          color: AppColorConstants.iconColor),
                      title:
                          BodyLargeText(LocalizationString.chooseFromGallery),
                      onTap: () async {
                        Get.back();
                        picker
                            .pickImage(source: ImageSource.gallery)
                            .then((pickedFile) {
                          if (pickedFile != null) {
                            profileController.editProfileImageAction(
                                pickedFile, isCoverImage);
                          } else {}
                        });
                      }),
                  divider(context: context),
                  ListTile(
                      leading:
                          Icon(Icons.close, color: AppColorConstants.iconColor),
                      title: BodyLargeText(LocalizationString.cancel),
                      onTap: () => Get.back()),
                ],
              ),
            ));
  }
}

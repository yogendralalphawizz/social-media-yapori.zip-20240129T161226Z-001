import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../universal_components/rounded_input_field.dart';

class ChangeGender extends StatefulWidget {
  const ChangeGender({Key? key}) : super(key: key);

  @override
  State<ChangeGender> createState() => _ChangeGenderState();
}

class _ChangeGenderState extends State<ChangeGender> {
  TextEditingController bioData = TextEditingController();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    if(_userProfileManager.user.value!.gender == '1' ){
      setState(() {
        selectedIndex = 1;
      }); } else  if(_userProfileManager.user.value!.gender == '2' ){
      setState(() {
        selectedIndex = 2;
      }); } else
    {
      setState(() {
        selectedIndex = 3;
      }); }
    super.initState();
  }
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          profileScreensNavigationBar(
              context: context,
              title: LocalizationString.bioData,
              rightBtnTitle: LocalizationString.done,
              completion: () {
                profileController.updateGender(
                    sex: selectedIndex.toString(), context: context);
              }),

          divider(context: context).vP8,
          const SizedBox(
            height: 20,
          ),
          Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Heading6Text(LocalizationString.gender,
                      weight: TextWeight.medium),
      const SizedBox(height: 20,),
      Row(
        children: [
          BodyLargeText(
            LocalizationString.male,
          ),
          const Spacer(),
          selectedIndex == 1
              // language['language_code']!
              ? ThemeIconWidget(
            ThemeIcon.checkMarkWithCircle,
            size: 20,
            color: AppColorConstants.themeColor,
          )
              : Container()
        ],
      ).hP16.ripple(() {
        setState(() {
          selectedIndex = 1 ;
        });

      }),
                  divider(context: context).p16,
                  Row(
                    children: [
                      BodyLargeText(
                        LocalizationString.female,
                      ),
                      const Spacer(),
                      selectedIndex == 2
                      // language['language_code']!
                          ? ThemeIconWidget(
                        ThemeIcon.checkMarkWithCircle,
                        size: 20,
                        color: AppColorConstants.themeColor,
                      )
                          : Container()
                    ],
                  ).hP16.ripple(() {
                    setState(() {
                      selectedIndex = 2 ;
                    });

                  }),
                  divider(context: context).p16,
                  Row(
                    children: [
                      BodyLargeText(
                        LocalizationString.other,
                      ),
                      const Spacer(),
                      selectedIndex == 3
                      // language['language_code']!
                          ? ThemeIconWidget(
                        ThemeIcon.checkMarkWithCircle,
                        size: 20,
                        color: AppColorConstants.themeColor,
                      )
                          : Container()
                    ],
                  ).hP16.ripple(() {
                    setState(() {
                      selectedIndex = 3 ;
                    });

                  })
                ],
              ).vP8,
            ],
          ).hP16,
        ],
      ),
    );
  }
}

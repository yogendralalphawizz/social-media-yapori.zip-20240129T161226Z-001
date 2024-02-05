import 'package:country_picker/country_picker.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../universal_components/rounded_input_field.dart';

class SetUserName extends StatefulWidget {
  const SetUserName({Key? key}) : super(key: key);

  @override
  State<SetUserName> createState() => _SetUserNameState();
}

class _SetUserNameState extends State<SetUserName> {
  TextEditingController userName = TextEditingController();
  TextEditingController countryName = TextEditingController();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
    userName.text = _userProfileManager.user.value!.userName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Heading3Text(LocalizationString.setUserName,
             weight: TextWeight.medium,),
          const SizedBox(
            height: 20,
          ),
          BodyLargeText(LocalizationString.setUserNameSubHeading,
              textAlign: TextAlign.center, weight: TextWeight.medium),
          const SizedBox(
            height: 50,
          ),
          Stack(
            children: [
              InputField(
                hintText: LocalizationString.setUserName,
                controller: userName,
                showDivider: true,
                onChanged: (value) {
                  if (value.length > 3) {
                    profileController.verifyUsername(userName: value);
                  }
                },
              ),
              Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                child: Center(
                  child:
                      Obx(() => profileController.userNameCheckStatus.value == 1
                          ? ThemeIconWidget(
                              ThemeIcon.checkMark,
                              color: AppColorConstants.themeColor,
                            )
                          : profileController.userNameCheckStatus.value == 0
                              ? ThemeIconWidget(
                                  ThemeIcon.close,
                                  color: AppColorConstants.red,
                                )
                              : Container()),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            color: Colors.transparent,
            height: 50,
            child: InputField(
                controller: countryName,
                showDivider: true,
                readOnly: true,
                hintText: LocalizationString.selectCountry,
                onTap: (){
                  showCountryPicker(
                    context: context,
                    showPhoneCode: false,
                    // optional. Shows phone code before the country name.
                    onSelect: (Country country) {
                      setState(() {
                        countryName.text = country.name;
                        // controller.countryName = country.name;
                      });
                    },
                  );}
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          AppThemeButton(
              text: LocalizationString.submit,
              onPress: () {
                profileController.updateUserName(
                    userName: userName.text,
                    isSigningUp: true,
                    context: context,
                country: countryName.text.toString());
              })
        ],
      ).hP16,
    );
  }
}

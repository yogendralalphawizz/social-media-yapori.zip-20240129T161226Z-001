import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../universal_components/rounded_input_field.dart';

class ChangeProfileQualification extends StatefulWidget {
  const ChangeProfileQualification({Key? key}) : super(key: key);

  @override
  State<ChangeProfileQualification> createState() => _ChangeProfileQualificationState();
}

class _ChangeProfileQualificationState extends State<ChangeProfileQualification> {
  TextEditingController qualification = TextEditingController();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    qualification.text = _userProfileManager.user.value!.qualification ?? '';
    super.initState();
  }

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
              title: LocalizationString.qualification,
              rightBtnTitle: LocalizationString.done,
              completion: () {
                profileController.updateQualification(
                    qualification: qualification.text, context: context);
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
                  Heading6Text(LocalizationString.qualification,
                      weight: TextWeight.medium),
                  Container(
                    color: Colors.transparent,
                    height: 50,
                    child: InputField(
                      controller: qualification,
                      showDivider: true,
                      // showBorder: true,
                      hintText: LocalizationString.qualification,
                    ),
                  ),
                ],
              ).vP8,
            ],
          ).hP16,
        ],
      ),
    );
  }
}

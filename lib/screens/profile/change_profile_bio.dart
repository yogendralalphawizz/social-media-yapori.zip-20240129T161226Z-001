import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../universal_components/rounded_input_field.dart';

class ChangeBioData extends StatefulWidget {
  const ChangeBioData({Key? key}) : super(key: key);

  @override
  State<ChangeBioData> createState() => _ChangeBioDataState();
}

class _ChangeBioDataState extends State<ChangeBioData> {
  TextEditingController bioData = TextEditingController();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    bioData.text = _userProfileManager.user.value!.bio ?? '';
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
              title: LocalizationString.bioData,
              rightBtnTitle: LocalizationString.done,
              completion: () async{
              await  profileController.updateBioData(
                    paypalId: bioData.text, context: context);
              // Future.delayed(const Duration(milliseconds: 1000), () {
              //   Get.back();
              // });
               // Get.back();
              // Navigator.pop(context);
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
                  Heading6Text(LocalizationString.bioData,
                      weight: TextWeight.medium),
                  Container(
                    color: Colors.transparent,
                    height: 50,
                    child: InputField(
                      controller: bioData,
                      showDivider: true,
                      // showBorder: true,
                      hintText: 'Bio Data',
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

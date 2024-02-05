import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../universal_components/rounded_input_field.dart';

class ChangeWebsiteLinks extends StatefulWidget {
  const ChangeWebsiteLinks({Key? key}) : super(key: key);

  @override
  State<ChangeWebsiteLinks> createState() => _ChangeWebsiteLinksState();
}

class _ChangeWebsiteLinksState extends State<ChangeWebsiteLinks> {
  TextEditingController websiteLinks = TextEditingController();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    websiteLinks.text = _userProfileManager.user.value!.website ?? '';
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
              title: LocalizationString.websiteLinks,
              rightBtnTitle: LocalizationString.done,
              completion: () {
                profileController.updateWebsiteLinks(
                    websites: websiteLinks.text, context: context);
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
                  Heading6Text(LocalizationString.websiteLinks,
                      weight: TextWeight.medium),
                  Container(
                    color: Colors.transparent,
                    height: 50,
                    child: InputField(
                      controller: websiteLinks,
                      showDivider: true,
                      // showBorder: true,
                      hintText: LocalizationString.websiteLinks,
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

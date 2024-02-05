import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:get/get.dart';

import '../dashboard/dashboard_screen.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({Key? key}) : super(key: key);

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  final SettingsController _settingsController = Get.find();

  @override
  void initState() {
    _settingsController.setCurrentSelectedLanguage();
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
          backNavigationBar(
              context: context, title: LocalizationString.changeLanguage),
          divider(context: context).tP8,
          Expanded(
              child: GetBuilder<SettingsController>(
                  init: _settingsController,
                  builder: (ctx) {
                    return ListView.separated(
                        padding: const EdgeInsets.only(top: 20),
                        itemBuilder: (ctx, index) {
                          Map<String, String> language =
                              _settingsController.languagesList[index];
                          return Row(
                            children: [
                              BodyLargeText(
                                language['language_name']!,
                              ),
                              const Spacer(),
                              _settingsController.currentLanguage.value ==
                                      language['language_code']!
                                  ? ThemeIconWidget(
                                      ThemeIcon.checkMarkWithCircle,
                                      size: 20,
                                      color: AppColorConstants.themeColor,
                                    )
                                  : Container()
                            ],
                          ).hP16.ripple(() {
                            // var locale = Locale(language['language_code']!,
                            //     language['country_code']!);
                            // context.setLocale(locale);
                            _settingsController.changeLanguage(language);
                          });
                        },
                        separatorBuilder: (ctx, index) {
                          return divider(context: context).vP16;
                        },
                        itemCount: _settingsController.languagesList.length);
                  }))
        ],
      ),
      bottomSheet: Container(
        color: AppColorConstants.backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                fixedSize: Size(150, 40),
                primary: AppColorConstants.themeColor
              ),
              onPressed: (){
                Get.offAll(() => const DashboardScreen());
              },
              child: Text("DONE"),

            ),
          ],
        ),
      ),
    );
  }
}

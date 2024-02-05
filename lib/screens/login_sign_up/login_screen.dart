import 'package:foap/controllers/post_controller.dart';
import 'package:foap/controllers/profile_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../universal_components/rounded_input_field.dart';
import '../../universal_components/rounded_password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final LoginController controller = Get.find();

  locationPermission()async{
    await Permission.location.isDenied.then((value) {
      if (value) {
        Permission.location.request();
      }
    });
    // await controller.getCurrentCountry();
  }

  @override
  void initState() {
    super.initState();
    // locationPermission();
    // getCurrentCountry();
    Future.delayed(const Duration(seconds: 1), (){
      controller.determinePosition();
    });

    Get.put(ProfileController());
    Get.put(PostController());
  }

  String? countryName, cityName;

  Future getCurrentCountry() async {
    await Permission.location.isDenied.then((value) {
      if (value) {
        Permission.location.request();
      }
    });
    // try {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      countryName = placemarks[0].country;
      cityName = placemarks[0].locality;

      // return countryName;
      print('this is my current country $countryName');
    } else {
      return 'Country not found';
    }
    // } catch (e) {
    //   return 'Error: $e';
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SingleChildScrollView(
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                    ),
                    // Heading3Text(LocalizationString.welcome,
                    //     weight: TextWeight.bold),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Image.asset('assets/applogo.jpeg', height: 120, width: 250,),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    InputField(
                      controller: email,
                      showDivider: true,
                      hintText: LocalizationString.emailOrUsername,
                      cornerRadius: 5,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    PasswordField(
                      onChanged: (value) {},
                      showDivider: true,
                      controller: password,
                      cornerRadius: 5,
                      hintText: LocalizationString.password,
                      showRevealPasswordIcon: true,
                      textStyle: TextStyle(
                          fontSize: FontSizes.h6,
                          color: AppColorConstants.themeColor),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    addLoginBtn(context),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => const ForgotPasswordScreen());
                      },
                      child: Center(
                        child: BodyMediumText(
                          LocalizationString.forgotPwd,
                          weight: TextWeight.bold,
                          color: AppColorConstants.themeColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width * 0.37,
                          color: AppColorConstants.themeColor,
                        ),
                        Heading6Text(
                          LocalizationString.or,
                        ),
                        Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width * 0.37,
                          color: AppColorConstants.themeColor,
                        )
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    const SocialLogin(hidePhoneLogin: false).setPadding(left: 65, right: 65),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Heading6Text(
                          LocalizationString.dontHaveAccount,
                        ),
                        Heading6Text(
                          LocalizationString.signUp,
                          weight: TextWeight.medium,
                          color: AppColorConstants.themeColor,
                        ).ripple(() {
                          Get.to(() => const SignUpScreen());
                        }),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    // bioMetricView(),
                    // const Spacer(),
                  ]),
            )).setPadding(left: 25, right: 25),
      ),
    );
  }

  Widget addLoginBtn(BuildContext context) {
    return AppThemeButton(
      onPress: () {
        controller.login(email.text.trim(), password.text.trim(), context);
      },
      text: LocalizationString.signIn,
    );
  }
}

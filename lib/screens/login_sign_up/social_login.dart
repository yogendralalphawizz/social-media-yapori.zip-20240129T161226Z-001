import 'dart:io';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/login_sign_up/phone_login.dart';
import 'package:foap/screens/login_sign_up/set_user_name.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../apiHandler/api_controller.dart';
import '../../manager/location_manager.dart';
import '../../manager/socket_manager.dart';
import '../../util/shared_prefs.dart';
import '../dashboard/dashboard_screen.dart';
import '../settings_menu/settings_controller.dart';

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class SocialLogin extends StatefulWidget {
  final bool hidePhoneLogin;

  const SocialLogin({Key? key, required this.hidePhoneLogin}) : super(key: key);

  @override
  State<SocialLogin> createState() => _SocialLoginState();
}

class _SocialLoginState extends State<SocialLogin> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      print('this is account ${account!.email}');
      if (account != null) {
        socialLogin(
            'google', account.id, account.displayName ?? '', account.email);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.hidePhoneLogin == false
            ? Container(
                height: 40,
                width: 40,
                color: AppColorConstants.themeColor.withOpacity(0.2),
                child: Center(
                    child: Image.asset(
                  'assets/phone.png',
                  height: 20,
                  width: 20,
                  color: Colors.white,
                ))).circular.ripple(() {
                Get.offAll(() => const PhoneLoginScreen());
              })
            : Container(
                height: 40,
                width: 40,
                color: AppColorConstants.themeColor.withOpacity(0.2),
                child: Center(
                    child: Image.asset(
                  'assets/email.png',
                  height: 20,
                  width: 20,
                  color: Colors.white,
                ))).circular.ripple(() {
                Get.offAll(() => const LoginScreen());
              }),
        const SizedBox(width: 15,),
        Container(
            height: 40,
            width: 40,
            color: AppColorConstants.themeColor.withOpacity(0.2),
            child: Center(
                child: Image.asset(
              'assets/google.png',
              height: 20,
              width: 20,
            ))).circular.ripple(() {
          signInWithGoogle();

        }),
        Platform.isIOS
            ? Container(
                height: 40,
                width: 40,
                color: AppColorConstants.themeColor.withOpacity(0.2),
                child: Center(
                    child: Image.asset(
                  'assets/apple.png',
                  height: 20,
                  width: 20,
                ))).circular.ripple(() {
                //signInWithGoogle();
                _handleAppleSignIn();
                // Get.to(() => const InstagramView());
              })
            : Container(),
        // Container(
        //     height: 40,
        //     width: 40,
        //     color: AppColorConstants.themeColor.withOpacity(0.2),
        //     child: Center(
        //         child: Image.asset(
        //       'assets/facebook.png',
        //       height: 20,
        //       width: 20,
        //     ))).circular.ripple(() {
        //   fbSignInAction();
        // }),
      ],
    );
  }

  void signInWithGoogle() async {
    try {
      var res = await _googleSignIn.signIn();
      print('this is social response ${res!.email}');
    } catch (error) {
      print('this is social response $error');
      AppUtil.showToast(
          message: error.toString(), isSuccess: false);
    }
  }

  void fbSignInAction() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final facebookLogin = FacebookLogin();
    facebookLogin.logOut();
    final result = await facebookLogin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    switch (result.status) {
      case FacebookLoginStatus.success:
        // Get profile data
        final profile = await facebookLogin.getUserProfile();
        String name = profile?.name ?? '';
        String socialId = profile?.userId ?? '';
        final email = await facebookLogin.getUserEmail();

        AppUtil.checkInternet().then((value) {
          if (value) {
            // EasyLoading.show(status: LocalizationString.loading);

            socialLogin('fb', socialId, name, email!);

            // ApiController()
            //     .socialLogin(name, 'fb', socialId, email!)
            //     .then((response) async {
            //   EasyLoading.dismiss();
            //   if (response.success) {
            //     SharedPrefs().setUserLoggedIn(true);
            //     _userProfileManager.refreshProfile();
            //     SharedPrefs().setAuthorizationKey(response.authKey!);
            //
            //     // ask for location
            //     getIt<LocationManager>().postLocation();
            //
            //     Get.offAll(() => const DashboardScreen());
            //     getIt<SocketManager>().connect();
            //   } else {
            //     AppUtil.showToast(
            //         context: context,
            //         message: response.message,
            //         isSuccess: false);
            //   }
            // });
          } else {
            AppUtil.showToast(
                message: LocalizationString.noInternet, isSuccess: false);
          }
        });

        break;
      case FacebookLoginStatus.cancel:
        AppUtil.showToast(
            message: LocalizationString.cancelledByUser, isSuccess: false);
        break;
      case FacebookLoginStatus.error:
        AppUtil.showToast(
            message: result.error!.localizedDescription!, isSuccess: false);
        break;
    }
  }

  void socialLogin(String type, String userId, String name, String email) {
    AppUtil.checkInternet().then((value) {
      if (value) {
        EasyLoading.show(status: LocalizationString.loading);
        ApiController()
            .socialLogin(name, type, userId, email)
            .then((response) async {
          EasyLoading.dismiss();
          if (response.success) {
            SharedPrefs().setUserLoggedIn(true);
            await SharedPrefs().setAuthorizationKey(response.authKey!);
            await _userProfileManager.refreshProfile();
            await _settingsController.getSettings();

            if (_userProfileManager.user.value != null) {
              if (_userProfileManager.user.value!.userName.isEmpty) {
                isLoginFirstTime = true;
                Get.offAll(() => const SetUserName());
              } else {
                // ask for location
                isLoginFirstTime = false;
                getIt<LocationManager>().postLocation();
                Get.offAll(() => const DashboardScreen());
              }
              getIt<SocketManager>().connect();
            }
          } else {
            AppUtil.showToast(message: response.message, isSuccess: false);
          }
        });
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet, isSuccess: false);
      }
    });
  }

  Future<void> _handleAppleSignIn() async {
    EasyLoading.show(status: 'loading...');

    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    if (appleCredential.userIdentifier != null) {
      AppUtil.checkInternet().then((value) {
        if (value) {
          socialLogin('apple', appleCredential.userIdentifier!, '',
              appleCredential.email ?? '');
        } else {
          AppUtil.showToast(
              message: LocalizationString.noInternet, isSuccess: false);
        }
      });
    }
  }
}

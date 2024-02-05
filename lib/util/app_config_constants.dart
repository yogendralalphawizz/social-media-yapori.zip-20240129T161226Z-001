import '../helper/imports/common_import.dart';
import 'constant_util.dart';

class AppConfigConstants {
  // Name of app
  static String appName = 'YaPori';
  static String currentVersion = '1';
  static const liveAppLink = 'https://www.google.com/';

  static String appTagline = 'Share your day activity with friends';
  static const googleMapApiKey = 'AIzaSyCTjoS7a179rMPeXIbGoUPbhUDekj2o2F8';
  static const razorpayKey = 'rzp_test_jDl2SjSKYlghAD';

  static const agoraApiKey = '52aa6d82f3f14aa3bd36b7a0fb6648f4';

  static const restApiBaseUrl =
      'https://yapori.in/api/web/v1/';

  static const socketApiBaseUrl = 'http://yapori.in:4000/';


  // Chat encryption key -- DO NOT CHANGE THIS
  static const encryptionKey = 'bbC2H19lkVbQDfakxcrtNMQdd0FloLyw';

  // enable encryption -- DO NOT CHANGE THIS
  static const int enableEncryption = 1;

  // chat version
  static const int chatVersion = 1;

  // is demo app
  static const bool isDemoApp = true;

  // parameters for delete chat
  static const secondsInADay = 86400;
  static const secondsInThreeDays = 259200;
  static const secondsInSevenDays = 604800;
}

class DesignConstants {
  static double horizontalPadding = 24;
}

class AppColorConstants {
  static Color themeColor = const Color(0xff367C88);

  static Color get backgroundColor =>
      isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;

  static Color get cardColor =>
      isDarkMode ? const Color(0xFF424242) : const Color(0xFFF9F9F9);

  static Color get dividerColor =>
      isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2);

  static Color get borderColor =>
      isDarkMode ? Colors.white.withOpacity(0.9) : Colors.grey.withOpacity(0.2);

  static Color get disabledColor =>
      isDarkMode ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.2);

  static Color get shadowColor => isDarkMode
      ? Colors.white.withOpacity(0.2)
      : Colors.black.withOpacity(0.2);

  static Color get inputFieldBackgroundColor =>
      isDarkMode ? const Color(0xFF212121) : const Color(0xFFdfe6e9);

  static Color get iconColor =>
      isDarkMode ? Colors.white : const Color(0xFF212121);

  static Color get inputFieldTextColor =>
      isDarkMode ? const Color(0xFFFAFAFA) : const Color(0xFF212121);

  static Color get inputFieldPlaceholderTextColor =>
      isDarkMode ? const Color(0xFF3F434E) : const Color(0xFF9E9E9E);

  static Color get red => isDarkMode ? Colors.red : Colors.red;
  static Color blueClr =  Colors.blue;
  static Color whiteClr =  Colors.white;
  static Color get green => isDarkMode ? Colors.green : Colors.green;

  // text colors

  static Color get grayscale900 =>
      isDarkMode ? const Color(0xFFFAFAFA) : const Color(0xFF212121);

  static Color get grayscale800 =>
      isDarkMode ? const Color(0xFFF5F5F5) : const Color(0xFF424242);

  static Color get grayscale700 =>
      isDarkMode ? const Color(0xFFEEEEEE) : const Color(0xFF616161);

  static Color get grayscale600 =>
      isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF757575);

  static Color get grayscale500 =>
      isDarkMode ? const Color(0xFFBDBDBD) : const Color(0xFF9E9E9E);

  static Color get reelIconsClr =>
      isDarkMode ? const Color(0xFFBDBDBD) : Colors.white;

  static Color get grayscale400 =>
      isDarkMode ? const Color(0xFF9E9E9E) : const Color(0xFFBDBDBD);

  static Color get grayscale300 =>
      isDarkMode ? const Color(0xFF757575) : const Color(0xFFE0E0E0);

  static Color get grayscale200 =>
      isDarkMode ? const Color(0xFF616161) : const Color(0xFFEEEEEE);

  static Color get grayscale100 =>
      isDarkMode ? const Color(0xFF424242) : const Color(0xFFF5F5F5);

}

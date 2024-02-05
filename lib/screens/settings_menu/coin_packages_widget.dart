import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../components/package_tile.dart';
import '../../controllers/subscription_packages_controller.dart';
import '../../model/package_model.dart';
import '../../util/constant_util.dart';

class CoinPackagesWidget extends StatefulWidget {
  const CoinPackagesWidget({Key? key}) : super(key: key);

  @override
  State<CoinPackagesWidget> createState() => _CoinPackagesWidgetState();
}

class _CoinPackagesWidgetState extends State<CoinPackagesWidget> {
  final SubscriptionPackageController packageController = Get.find();
  final SettingsController settingsController = Get.find();
  Razorpay? _razorpay;
  int? pricerazorpayy;

  void openCheckout(amount) async {
    double res = double.parse(amount.toString());
    pricerazorpayy= int.parse(res.toStringAsFixed(0)) * 100;
    print("checking razorpay price ${pricerazorpayy.toString()}");

    print("checking razorpay price ${pricerazorpayy.toString()}");
    // Navigator.of(context).pop();
    var options = {
      'key': rzrPayKey  ??'rzp_test_1DP5mmOlF5G5ag',
      'amount': "${pricerazorpayy}",
      'name': 'YaPori',
      'image':'assets/applogo.png',
      'description': 'YaPori Buy Package',
      'color-hex': "#595858"
    };
    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    packageController.subscribeToDummyPackage(context, randomId());

  }
  void _handlePaymentError(PaymentFailureResponse response) {
    AppUtil.showToast(
        message: 'Razorpay Payment Failed!',
        isSuccess: false);
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    AppUtil.showToast(
        message: 'Razorpay Wallet',
        isSuccess: true);
  }

  String? rzrPayKey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    settingsController.getSettings();
    rzrPayKey=  settingsController
        .setting.value!.razorPayKey
        .toString();
    print('this is rzpKey $rzrPayKey');
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.backgroundColor,
      child: GetBuilder<SubscriptionPackageController>(
          init: packageController,
          builder: (ctx) {
            return ListView.separated(
                padding: const EdgeInsets.only(top: 20,bottom: 70),
                itemBuilder: (ctx, index) {
                  return PackageTile(
                    package: packageController.packages[index],
                    index: index,
                    buyPackageHandler: () async {
                    await  buyPackage(packageController.packages[index]);
                    },
                  );
                },
                separatorBuilder: (ctx, index) {
                  return divider(context: context).vP16;
                },
                itemCount: packageController.packages.length);
          }).hP16,
    );
  }



  buyPackage(PackageModel package) async {
    openCheckout(package.price.toString());
    // if (packageController.isAvailable.value) {
    //   // packageController.selectedPackage.value = index;
    //   // For Real Time
    //   packageController.selectedPurchaseId.value = Platform.isIOS
    //       ? package.inAppPurchaseIdIOS
    //       : package.inAppPurchaseIdAndroid;
    //   List<ProductDetails> matchedProductArr = packageController.products
    //       .where((element) =>
    //   element.id == packageController.selectedPurchaseId.value)
    //       .toList();
    //   if (matchedProductArr.isNotEmpty) {
    //
    //     ProductDetails matchedProduct = matchedProductArr.first;
    //     PurchaseParam purchaseParam = PurchaseParam(
    //         productDetails: matchedProduct, applicationUserName: null);
    //     packageController.inAppPurchase.buyConsumable(
    //         purchaseParam: purchaseParam,
    //         autoConsume: packageController.kAutoConsume || Platform.isIOS);
    //   } else {
    //     AppUtil.showToast(
    //         message: LocalizationString.noProductAvailable,
    //         isSuccess: false);
    //   }
    // } else {
    //   AppUtil.showToast(
    //       message: LocalizationString.storeIsNotAvailable,
    //       isSuccess: false);
    // }

    // if (AppConfigConstants.isDemoApp) {
    //   AppUtil.showDemoAppConfirmationAlert(
    //       title: 'Demo app',
    //       subTitle:
    //           'This is demo app so you can not make payment to test it, but still you will get some coins',
    //       okHandler: () {
    //         packageController.subscribeToDummyPackage(context, randomId());
    //       });
    //   return;
    // }

  }
}

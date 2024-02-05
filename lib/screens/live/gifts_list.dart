import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../controllers/gift_controller.dart';
import '../../model/gift_model.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../settings_menu/coin_packages_widget.dart';

class GiftsPageView extends StatefulWidget {
  final Function(GiftModel) giftSelectedCompletion;

  const GiftsPageView({Key? key, required this.giftSelectedCompletion})
      : super(key: key);

  @override
  State<GiftsPageView> createState() => _GiftsPageViewState();
}

class _GiftsPageViewState extends State<GiftsPageView> {
  final UserProfileManager _userProfileManager = Get.find();

  int currentView = 0;
  List<Widget> pages = [];

  @override
  void initState() {
    pages = [
      GiftsListing(giftSelectedCompletion: widget.giftSelectedCompletion),
      coinPackages(),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.themeColor.darken(0.48),
      child: Column(
        children: [
          Container(
            height: 60,
            color: AppColorConstants.themeColor.darken(0.48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BodyLargeText(
                      '${LocalizationString.availableCoins} : ',
                        weight: TextWeight.medium
                    ),
                    ThemeIconWidget(
                      ThemeIcon.diamond,
                      size: 20,
                      color: AppColorConstants.themeColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      _userProfileManager.user.value!.coins.toString(),
                      style: TextStyle(
            fontSize: FontSizes.b2),
                    ),
                  ],
                ),
                currentView == 0
                    ? Container(
                            color: AppColorConstants.themeColor,
                            child: BodyLargeText(
                              LocalizationString.coins,
                                weight: TextWeight.semiBold
                            ).setPadding(left: 10, right: 10, top: 5, bottom: 5))
                        .round(20)
                        .ripple(() {
                        setState(() {
                          currentView = 1;
                        });
                      })
                    : const ThemeIconWidget(
                        ThemeIcon.close,
                        size: 20,
                      ).ripple(() {
                        setState(() {
                          currentView = 0;
                        });
                      }),
              ],
            ).p16,
          ).topRounded(20),
          Expanded(child: pages[currentView]),
        ],
      ),
    );
  }

  Widget coinPackages() {
    return const CoinPackagesWidget();
  }
}

class GiftsListing extends StatefulWidget {
  final Function(GiftModel) giftSelectedCompletion;

  const GiftsListing({Key? key, required this.giftSelectedCompletion})
      : super(key: key);

  @override
  State<GiftsListing> createState() => _GiftsListingState();
}

class _GiftsListingState extends State<GiftsListing> {
  final GiftController _giftController = GiftController();

  @override
  void initState() {
    _giftController.loadGiftCategories();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.backgroundColor.darken(),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Obx(() => HorizontalSegmentBar(
                onSegmentChange: (segment) {
                  _giftController.segmentChanged(segment);
                },
                adjustInMinimumWidth: true,
                hideHighlightIndicator: false,
                segments: _giftController.giftsCategories
                    .map((element) => element.name)
                    .toList(),
              )),
          Expanded(
            child: GetBuilder<GiftController>(
                init: _giftController,
                builder: (ctx) {
                  return GridView.builder(
                      padding: const EdgeInsets.only(top: 20, bottom: 25),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              childAspectRatio: 0.6,
                              crossAxisCount: 4),
                      itemCount: _giftController.gifts.length,
                      itemBuilder: (context, index) {
                        GiftModel gift = _giftController.gifts[index];
                        return giftBox(gift).ripple(() {
                          widget.giftSelectedCompletion(gift);
                        });
                      });
                }),
          ),
        ],
      ),
    );
  }

  Widget giftBox(GiftModel gift) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(
          gift.logo,
          height: 60,
          width: 60,
          fit: BoxFit.contain,
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ThemeIconWidget(
              ThemeIcon.diamond,
              size: 15,
              color: AppColorConstants.themeColor,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(gift.coins.toString()),
          ],
        )
      ],
    ).round(10);
  }
}

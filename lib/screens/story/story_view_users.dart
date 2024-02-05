// import 'package:foap/helper/imports/common_import.dart';
// import 'package:foap/helper/imports/story_imports.dart';
// import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
//
// import '../../components/user_card.dart';
//
// class StoryViewUsers extends StatelessWidget {
//   final AppStoryController storyController = Get.find();
//   final ScrollController scrollController = ScrollController();
//
//   StoryViewUsers({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColorConstants.cardColor,
//       child: Column(
//         children: [
//           const SizedBox(
//             height: 20,
//           ),
//           BodyLargeText(
//             viewsString.tr,
//             weight: TextWeight.bold,
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           divider(context: context),
//           Expanded(
//             child: Obx(() {
//               scrollController.addListener(() {
//                 if (scrollController.position.maxScrollExtent ==
//                     scrollController.position.pixels) {
//                   if (!storyController.storyViewerDataWrapper.isLoading.value) {
//                     storyController.loadStoryViewer();
//                   }
//                 }
//               });
//               return storyController.storyViewers.isNotEmpty
//                   ? ListView.separated(
//                       controller: scrollController,
//                       padding:
//                           EdgeInsets.all(DesignConstants.horizontalPadding),
//                       itemCount: storyController.storyViewers.length,
//                       itemBuilder: (ctx, index) {
//                         return StoryViewerTile(
//                           viewer: storyController.storyViewers[index],
//                         );
//                       },
//                       separatorBuilder: (ctx, index) {
//                         return const SizedBox(
//                           height: 10,
//                         );
//                       },
//                     )
//                   : Center(child: Heading5Text(noViewString.tr));
//             }),
//           ),
//         ],
//       ),
//     ).topRounded(40);
//   }
// }

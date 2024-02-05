import 'package:carousel_slider/carousel_slider.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/highlights/create_highlight.dart';
import 'package:get/get.dart';

import '../../components/live_tv_player.dart';
import '../../model/post_gallery.dart';
import '../../model/post_model.dart';
import '../../model/story_model.dart';

class HighlightFullScreen extends StatefulWidget {
  final StoryMediaModel? post;
  final List<StoryMediaModel>? storyList;
  final bool? show;
  // final int? startIndex;

  const HighlightFullScreen({Key? key, required this.post, this.storyList, this.show})
      : super(key: key);

  @override
  State<HighlightFullScreen> createState() => _HighlightFullScreenState();
}

class _HighlightFullScreenState extends State<HighlightFullScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Stack(
        children: [
           photoPostTile(widget.post!.image!),
          // CarouselSlider(
          //   items: mediaList(),
          //   options: CarouselOptions(
          //     aspectRatio: 1,
          //     initialPage: widget.startIndex ?? 0,
          //     enlargeCenterPage: false,
          //     enableInfiniteScroll: false,
          //     height: double.infinity,
          //     viewportFraction: 1,
          //     // onPageChanged: (index, reason) {
          //     //   postCardController.updateGallerySlider(index, widget.model.id);
          //     // },
          //   ),
          // ),
          appBar()
        ],
      ),
    );
  }

  // List<Widget> mediaList() {
  //   return widget.post.gallery.map((item) {
  //     if (item.isVideoPost == true) {
  //       return videoPostTile(item);
  //     } else {
  //       return photoPostTile(item);
  //     }
  //   }).toList();
  // }

  Widget videoPostTile(PostGallery media) {
    return Center(
      child: SocialifiedVideoPlayer(
        url: media.filePath,
        // isLocalFile: false,
        play: false,
        orientation: MediaQuery.of(context).orientation,
      ),
    );
  }

  Widget photoPostTile(String media) {
    return CachedNetworkImage(
      imageUrl: media,
      fit: BoxFit.contain,
      width: MediaQuery.of(context).size.width,
      placeholder: (context, url) => AppUtil.addProgressIndicator(size:100),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    ).addPinchAndZoom();
  }

  Widget appBar() {
    return Positioned(
      child: SizedBox(
        height: 150.0,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             ThemeIconWidget(
              ThemeIcon.backArrow,
              size: 20,
              color: AppColorConstants.themeColor,
            ).ripple(() {
              Get.back();
            }),
            const Spacer(),
            widget.show! ?
            ThemeIconWidget(
              ThemeIcon.nextArrow,
              color: AppColorConstants.themeColor,
              size: 27,
            ).ripple(() {
              // create highlights
              Get.to(() =>  CreateHighlight(coverImage: widget.post!.image!, post: widget.storyList,));
            })
            : const SizedBox.shrink(),
          ],
        ).hP16,
      ),
    );
  }
}

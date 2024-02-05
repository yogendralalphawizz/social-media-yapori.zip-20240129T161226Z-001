import 'package:foap/apiHandler/api_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/highlights/highlight_view_screen.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/highlights_imports.dart';

import '../../model/story_model.dart';

class ChooseStoryForHighlights extends StatefulWidget {
  final bool? show;
  const ChooseStoryForHighlights({Key? key, this.show}) : super(key: key);

  @override
  State<ChooseStoryForHighlights> createState() =>
      _ChooseStoryForHighlightsState();
}

class _ChooseStoryForHighlightsState extends State<ChooseStoryForHighlights> {
  final HighlightsController _highlightsController = HighlightsController();

  final _numberOfColumns = 3;
  getAllStories() async {
    setState(() {
      _highlightsController.isLoading = true;
    });

    await ApiController().getMyStories().then((response) {
      setState(() {
        _highlightsController.stories.value = response.myStories;
        _highlightsController.isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getAllStories();
    // WidgetsBinding.instance.addPostFrameCallback((_) async{
    //   await _highlightsController.getAllStories();
    // });

  }

  @override
  void dispose() {
    _highlightsController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 55,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ThemeIconWidget(
                ThemeIcon.close,
                color: AppColorConstants.themeColor,
                size: 27,
              ).ripple(() {
                Get.back();
              }),
              // const Spacer(),
              // Image.asset(
              //   'assets/logo.png',
              //   width: 80,
              //   height: 25,
              // ),
              // const Spacer(),
              // ThemeIconWidget(
              //   ThemeIcon.nextArrow,
              //   color: AppColorConstants.themeColor,
              //   size: 27,
              // ).ripple(() {
              //   // create highlights
              //   Get.to(() =>  CreateHighlight(coverImage: _highlightsController.selectedStoriesMedia.first.image.toString(), post: selectedStory,));
              // }),
            ],
          ).hp(20),
          const SizedBox(height: 20),
          Expanded(
            child: GetBuilder<HighlightsController>(
                init: _highlightsController,
                builder: (ctx) {
                  return
                    _highlightsController.isLoading
                      ? const StoriesShimmerWidget() :
                  _highlightsController.stories.isNotEmpty
                          ? GridView.builder(
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5,
                                      childAspectRatio: 0.6,
                                      crossAxisCount: _numberOfColumns),
                    itemCount: _highlightsController.stories
                        .where((story) => !story.isVideoPost())
                        .length,
                    itemBuilder: (context, index) {
                      final filteredStories = _highlightsController.stories
                          .where((story) => !story.isVideoPost())
                          .toList();
                      return _buildItem(index, filteredStories[index]);
                    },
                              // itemCount: _highlightsController.stories.length,
                              // itemBuilder: (context, index) {
                              //   if(_highlightsController.stories[index].isVideoPost() == true) {
                              //     return const SizedBox.shrink();
                              //   }
                              //     return
                              //     _buildItem(index);
                              //   // :const SizedBox.shrink();
                              // }
                              ).hP16
                          : emptyData(
                              title: LocalizationString.noStoryFound,
                              subTitle: LocalizationString.postSomeStories,
                            );
                }).hP4,
          )
        ],
      ),
    );
  }

  _isSelected(int id) {
    return _highlightsController.selectedStoriesMedia
        .where((item) => item.id == id)
        .isNotEmpty;
  }
  remove(int id) {
    return _highlightsController.selectedStoriesMedia
        .removeWhere((item) => item.id == id);

  }

  int selectIndex = 0 ;
  List<StoryMediaModel> selectedStory = [];

  _selectItem(int index) async {
    var highlight = _highlightsController.stories[index];
    print('this si highlight ${highlight.image}');
    setState(() {
      selectIndex = index;
      selectedStory.add(highlight);
      if (_isSelected(highlight.id)) {
        // _highlightsController.selectedStoriesMedia
        //     .removeWhere((anItem) => anItem.id == highlight.id);
        if (_highlightsController.selectedStoriesMedia.isEmpty) {
          _highlightsController.selectedStoriesMedia
              .add(highlight);

          setState(() {});

        }else{

          _highlightsController.selectedStoriesMedia
              .add(highlight);
          setState(() {});
        }


      } else {
        if (_highlightsController.selectedStoriesMedia.length < 10) {
          _highlightsController.selectedStoriesMedia.add(highlight);
          print('added ${_highlightsController.selectedStoriesMedia.length}');
        }
        // remove(index);

      }
    });
  }

  // Widget photoPostTile(PostGallery media) {
  //   return CachedNetworkImage(
  //     imageUrl: media.filePath,
  //     fit: BoxFit.contain,
  //     width: MediaQuery.of(context).size.width,
  //     placeholder: (context, url) => AppUtil.addProgressIndicator(size:100),
  //     errorWidget: (context, url, error) => const Icon(Icons.error),
  //   ).addPinchAndZoom();
  // }

  _buildItem(int index,StoryMediaModel finalHighlights) => GestureDetector(
      onTap: () async {
       await _selectItem(index);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                HighlightFullScreen(post: finalHighlights,
                storyList: selectedStory,show: widget.show,),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: finalHighlights.image!,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ).round(5),
                _highlightsController.stories[index].isVideoPost() == true
                    ? const Positioned(
                        top: 0,
                        right: 0,
                        left: 0,
                        bottom: 0,
                        child: ThemeIconWidget(
                          ThemeIcon.play,
                          size: 80,
                          color: Colors.white,
                        ))
                    : Container()
              ],
            ),
          ),
          _isSelected(_highlightsController.stories[index].id)
              ? Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    height: 20,
                    width: 20,
                    color: AppColorConstants.themeColor,
                    child:  ThemeIconWidget(ThemeIcon.checkMark, color: AppColorConstants.whiteClr,),
                  ).circular)
              : Container()
        ],
      ));
}

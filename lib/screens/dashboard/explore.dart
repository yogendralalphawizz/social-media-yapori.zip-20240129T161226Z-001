import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/dashboard/posts.dart';
import 'package:get/get.dart';
import '../../components/hashtag_tile.dart';
import '../../components/search_bar.dart' as SearchBar;
import '../../components/user_card.dart';
import '../../controllers/explore_controller.dart';
import '../../controllers/post_controller.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../home_feed/post_media_full_screen.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final ExploreController exploreController = ExploreController();
  final PostController postController = Get.find();

  @override
  void initState() {
    super.initState();
    exploreController.getSuggestedUsers();
  }

  @override
  void didUpdateWidget(covariant Explore oldWidget) {
    // TODO: implement didUpdateWidget
    exploreController.getSuggestedUsers();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    exploreController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: KeyboardDismissOnTap(
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    const ThemeIconWidget(
                      ThemeIcon.backArrow,
                      size: 25,
                    ).ripple(() {
                      Get.back();
                    }),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: SearchBar.SearchBar(
                          showSearchIcon: true,
                          iconColor: AppColorConstants.themeColor,
                          onSearchChanged: (value) {
                            exploreController.searchTextChanged(value);
                          },
                          onSearchStarted: () {
                            //controller.startSearch();
                          },
                          onSearchCompleted: (searchTerm) {}),
                    ),
                    Obx(() => exploreController.searchText.isNotEmpty
                        ? Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          color: AppColorConstants.themeColor,
                          child: ThemeIconWidget(
                            ThemeIcon.close,
                            color: AppColorConstants.backgroundColor,
                            size: 25,
                          ),
                        ).round(20).ripple(() {
                          exploreController.closeSearch();
                        }),
                      ],
                    )
                        : Container())
                  ],
                ).setPadding(left: 16, right: 16, top: 25, bottom: 20),
                GetBuilder<ExploreController>(
                    init: exploreController,
                    builder: (ctx) {
                      return exploreController.searchText.isNotEmpty
                          ? Expanded(
                        child: Column(
                          children: [
                            segmentView(),
                            divider(context: context, height: 0.2),
                            searchedResult(
                                segment: exploreController.selectedSegment),
                          ],
                        ),
                      )
                          : searchSuggestionView();
                    })
              ],
            )),
      ),
    );
  }

  Widget segmentView() {
    return HorizontalSegmentBar(
        width: MediaQuery.of(context).size.width,
        onSegmentChange: (segment) {
          exploreController.segmentChanged(segment);
        },
        segments: [
          LocalizationString.top,
          LocalizationString.account,
          LocalizationString.hashTags,
          // LocalizationString.locations,
        ]);
  }

  Widget searchSuggestionView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!exploreController.suggestUserIsLoading) {
          exploreController.getSuggestedUsers();
        }
      }
    });

    return exploreController.suggestUserIsLoading
        ? Expanded(child: const ShimmerUsers().hP16)
        : exploreController.suggestedUsers.isNotEmpty
        ? Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Heading3Text(LocalizationString.suggestedUsers,
              weight: TextWeight.bold),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.only(top: 20, bottom: 50),
                itemCount: exploreController.suggestedUsers.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return UserTile(
                    profile: exploreController.suggestedUsers[index],
                    followCallback: () {
                      exploreController.followUser(
                          exploreController.suggestedUsers[index]);
                    },
                    unFollowCallback: () {
                      exploreController.unFollowUser(
                          exploreController.suggestedUsers[index]);
                    },
                  );
                },
                separatorBuilder: (BuildContext ctx, int index) {
                  return const SizedBox(
                    height: 20,
                  );
                }),
          ),
        ],
      ).hP16,
    )
        : Container();
  }

  Widget searchedResult({required int segment}) {
    switch (segment) {
      case 0:
        return topPosts();
      case 1:
        return Expanded(child: usersView().hP16);
      case 2:
        return Expanded(child: hashTagView().hP16);
    // case 3:
    //   return Expanded(child: locationView()).hP16;
    }
    return usersView();
  }

  Widget usersView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!exploreController.accountsIsLoading) {
          exploreController.searchData();
        }
      }
    });

    return exploreController.accountsIsLoading
        ? const ShimmerUsers()
        : exploreController.searchedUsers.isNotEmpty
        ? ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.only(top: 20),
        itemCount: exploreController.searchedUsers.length,
        itemBuilder: (BuildContext ctx, int index) {
          return UserTile(
            profile: exploreController.searchedUsers[index],
            followCallback: () {
              exploreController
                  .followUser(exploreController.searchedUsers[index]);
            },
            unFollowCallback: () {
              exploreController
                  .unFollowUser(exploreController.searchedUsers[index]);
            },
          );
        },
        separatorBuilder: (BuildContext ctx, int index) {
          return const SizedBox(
            height: 20,
          );
        })
        : SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: emptyUser(
          title: LocalizationString.noUserFound,
          subTitle: ''),
    );
  }

  Widget hashTagView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!exploreController.hashtagsIsLoading) {
          exploreController.searchData();
        }
      }
    });

    return exploreController.hashtagsIsLoading
        ? const ShimmerHashtag()
        : exploreController.hashTags.isNotEmpty
        ? ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 20),
      itemCount: exploreController.hashTags.length,
      itemBuilder: (BuildContext ctx, int index) {
        return HashTagTile(
          hashtag: exploreController.hashTags[index],
          onItemCallback: () {
            Get.to(() => Posts(
              hashTag: exploreController.hashTags[index].name,
              source: PostSource.posts,
            ));
          },
        );
      },
    )
        : SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: emptyData(
          title: LocalizationString.noHashtagFound, subTitle: ''),
    );
  }

  // Widget locationView() {
  //   return ListView.builder(
  //     padding: const EdgeInsets.only(top: 20),
  //     itemCount: controller.locations.length,
  //     itemBuilder: (BuildContext ctx, int index) {
  //       return LocationTile(
  //         location: controller.locations[index],
  //         onItemCallback: () {
  //           Get.to(() => Posts(locationId: controller.locations[index].id));
  //         },
  //       );
  //     },
  //   );
  // }

  Widget topPosts() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!postController.isLoadingPosts) {
          exploreController.searchData();
        }
      }
    });

    return GetBuilder<PostController>(
        init: postController,
        builder: (ctx) {
          return Expanded(
              child: postController.isLoadingPosts
                  ? const PostBoxShimmer()
                  : postController.posts.isNotEmpty
                  ? GridView.builder(
                controller: scrollController,
                itemCount: postController.posts.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                // You won't see infinite size error
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    mainAxisExtent: 100),
                itemBuilder: (BuildContext context, int index) =>
                postController.posts[index].gallery.first
                    .isVideoPost ==
                    true
                    ? Stack(children: [
                  AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: postController
                            .posts[index]
                            .gallery
                            .first
                            .videoThumbnail!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            AppUtil.addProgressIndicator(
                                size: 100),
                        errorWidget:
                            (context, url, error) =>
                        const Icon(
                          Icons.error,
                        ),
                      ).round(10)),
                  const Positioned(
                    right: 5,
                    top: 5,
                    child: ThemeIconWidget(
                      ThemeIcon.play,
                      size: 50,
                      color: Colors.white,
                    ),
                  )
                ]).ripple(() {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1,
                          animation2) =>
                          PostMediaFullScreen(post: postController.posts[index]),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                  // Get.to(() => Posts(
                  //   posts:
                  //   List.from(postController.posts),
                  //   index: index,
                  //   source: PostSource.posts,
                  //   page:
                  //   postController.postsCurrentPage,
                  // ));
                })
                    : AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: postController
                          .posts[index]
                          .gallery
                          .first
                          .filePath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          AppUtil.addProgressIndicator(
                              size:100),
                      errorWidget:
                          (context, url, error) =>
                      const Icon(Icons.error),
                    ).round(10))
                    .ripple(() {
                  Get.to(() => Posts(
                    posts:
                    List.from(postController.posts),
                    index: index,
                    source: PostSource.posts,
                    page:
                    postController.postsCurrentPage,
                    totalPages:
                    postController.totalPages,
                  ));
                }),
              ).hP16
                  : SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: emptyPost(
                    title: LocalizationString.noPostFound,
                    subTitle: ''),
              ));
        });
  }
}
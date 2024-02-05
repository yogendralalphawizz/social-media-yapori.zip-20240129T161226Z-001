import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import '../../components/search_bar.dart' as SearchBar;
import '../../components/user_card.dart';



class SelectUserForGroupChat extends StatefulWidget {
  final ChatRoomModel? group;
  final VoidCallback? invitedUserCallback;

  const SelectUserForGroupChat({Key? key, this.group, this.invitedUserCallback})
      : super(key: key);

  @override
  SelectUserForGroupChatState createState() => SelectUserForGroupChatState();
}

class SelectUserForGroupChatState extends State<SelectUserForGroupChat> {
  final SelectUserForGroupChatController selectUserForGroupChatController =
      Get.find();

  @override
  void initState() {
    selectUserForGroupChatController.clear();
    selectUserForGroupChatController.getFriends();
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
          SizedBox(
            height: 40,
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ThemeIconWidget(
                      ThemeIcon.close,
                      size: 20,
                    ).ripple(() {
                      Navigator.of(context).pop();
                    }),
                    Heading6Text(
                            widget.group == null
                                ? LocalizationString.next
                                : LocalizationString.invite,
                            weight: TextWeight.medium)
                        .ripple(() {
                      if (widget.group == null) {
                        if (selectUserForGroupChatController
                            .selectedFriends.isNotEmpty) {
                          Get.to(() => const EnterGroupInfo());
                        } else {
                          AppUtil.showToast(
                              message: LocalizationString.pleaseSelectUsers,
                              isSuccess: false);
                        }
                      } else {
                        selectUserForGroupChatController
                            .addUsersToRoom(widget.group!);
                        widget.invitedUserCallback!();
                        Get.back();
                      }
                    }),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BodyLargeText(
                          widget.group == null
                              ? LocalizationString.createGroup
                              : LocalizationString.addParticipants,
                          weight: TextWeight.medium),
                      Obx(() => selectUserForGroupChatController
                              .selectedFriends.isNotEmpty
                          ? BodyLargeText(
                              '${selectUserForGroupChatController.selectedFriends.length} ${LocalizationString.friendsSelected}',
                              weight: TextWeight.bold)
                          : Container())
                    ],
                  ),
                )
              ],
            ),
          ).hP16,
          divider(context: context).tP8,
          GetBuilder<SelectUserForGroupChatController>(
            init: selectUserForGroupChatController,
            builder: (ctx) {
              List<UserModel> usersList =
                  selectUserForGroupChatController.selectedFriends;

              return usersList.isNotEmpty
                  ? SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(
                            top: 20, left: 16, right: 16, bottom: 10),
                        itemCount: usersList.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Column(
                                children: [
                                  UserAvatarView(
                                    user: usersList[index],
                                    size: 50,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  BodyLargeText(
                                    usersList[index].userName,
                                  )
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                    height: 25,
                                    width: 25,
                                    color: AppColorConstants.cardColor,
                                    child: const ThemeIconWidget(
                                      ThemeIcon.close,
                                      size: 20,
                                    )).circular.ripple(() {
                                  selectUserForGroupChatController
                                      .selectFriend(usersList[index]);
                                }),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            width: 15,
                          );
                        },
                      ))
                  : Container();
            },
          ),
          SearchBar.SearchBar(
                  showSearchIcon: true,
                  iconColor: AppColorConstants.themeColor,
                  onSearchChanged: (value) {
                    selectUserForGroupChatController.searchTextChanged(value);
                  },
                  onSearchStarted: () {
                    //controller.startSearch();
                  },
                  onSearchCompleted: (searchTerm) {})
              .p16,
          divider(context: context).tP16,
          Expanded(
            child: GetBuilder<SelectUserForGroupChatController>(
                init: selectUserForGroupChatController,
                builder: (ctx) {
                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.maxScrollExtent ==
                        scrollController.position.pixels) {
                      if (!selectUserForGroupChatController.isLoading) {
                        selectUserForGroupChatController.getFriends();
                      }
                    }
                  });

                  List<UserModel> usersList = [];

                  if (widget.group == null) {
                    usersList = selectUserForGroupChatController.friends;
                  } else {
                    usersList = selectUserForGroupChatController.friends
                        .where((element) =>
                            widget.group!.roomMembers
                                .map((e) => e.userDetail.id)
                                .toList()
                                .contains(element.id) ==
                            false)
                        .toList();
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 5.0,
                            mainAxisSpacing: 5.0,
                            childAspectRatio: 0.8),
                    padding: const EdgeInsets.only(top: 25, left: 8, right: 8),
                    itemCount: usersList.length,
                    itemBuilder: (context, index) {
                      return SelectableUserCard(
                        model: usersList[index],
                        isSelected: selectUserForGroupChatController
                            .selectedFriends
                            .contains(usersList[index]),
                        selectionHandler: () {
                          selectUserForGroupChatController
                              .selectFriend(usersList[index]);
                        },
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}

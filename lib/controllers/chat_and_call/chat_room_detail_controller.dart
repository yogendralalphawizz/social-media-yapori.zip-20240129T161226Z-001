import 'dart:io';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:share_plus/share_plus.dart';

import '../../manager/socket_manager.dart';
import 'package:path_provider/path_provider.dart';

class ChatRoomDetailController extends GetxController {
  RxList<ChatMessageModel> photos = <ChatMessageModel>[].obs;
  RxList<ChatMessageModel> videos = <ChatMessageModel>[].obs;
  RxList<ChatMessageModel> starredMessages = <ChatMessageModel>[].obs;
  final ChatDetailController _chatDetailController = Get.find();

  // Rx<ChatRoomModel?> room = Rx<ChatRoomModel?>(null);

  RxInt selectedSegment = 0.obs;

  makeUserAsAdmin(UserModel user, ChatRoomModel chatRoom) {
    getIt<SocketManager>().emit(SocketConstants.makeUserAdmin,
        {'room': chatRoom.id, 'userId': user.id});
    _chatDetailController.getUpdatedChatRoomDetail(
        room: chatRoom, callback: () {});
  }

  removeUserAsAdmin(UserModel user, ChatRoomModel chatRoom) {
    getIt<SocketManager>().emit(SocketConstants.removeUserAdmin,
        {'room': chatRoom.id, 'userId': user.id});
    _chatDetailController.getUpdatedChatRoomDetail(
        room: chatRoom, callback: () {});
  }

  removeUserFormGroup(UserModel user, ChatRoomModel chatRoom) {
    getIt<SocketManager>().emit(SocketConstants.removeUserFromGroupChat,
        {'room': chatRoom.id, 'userId': user.id});

    _chatDetailController.getUpdatedChatRoomDetail(
        room: chatRoom, callback: () {});
  }

  leaveGroup(ChatRoomModel chatRoom) {
    getIt<SocketManager>()
        .emit(SocketConstants.leaveGroupChat, {'room': chatRoom.id});
    _chatDetailController.getUpdatedChatRoomDetail(
        room: chatRoom,
        callback: () {
          Get.back();
        });
  }

  updateGroupAccess(int access) {
    getIt<SocketManager>().emit(SocketConstants.updateChatAccessGroup, {
      'room': _chatDetailController.chatRoom.value!.id,
      'chatAccessGroup': access
    });

    _chatDetailController.getUpdatedChatRoomDetail(
        room: _chatDetailController.chatRoom.value!, callback: () {});
  }

  deleteGroup(ChatRoomModel chatRoom) {
    getIt<DBManager>().deleteRooms([chatRoom]);
    _chatDetailController.getUpdatedChatRoomDetail(
        room: chatRoom,
        callback: () {
          Get.back();
        });
  }

  getStarredMessages(ChatRoomModel room) async {
    starredMessages.value =
        await getIt<DBManager>().getStarredMessages(roomId: room.id);
    update();
  }

  unStarMessages() {
    for (ChatMessageModel message in _chatDetailController.selectedMessages) {
      _chatDetailController.unStarMessage(message);

      starredMessages.remove(message);
      if (starredMessages.isEmpty) {
        Get.back();
      } else {
        starredMessages.refresh();
      }
    }
  }

  segmentChanged(int index, int roomId) {
    selectedSegment.value = index;

    if (selectedSegment.value == 0) {
      loadImageMessages(roomId);
    } else {
      loadVideoMessages(roomId);
    }

    update();
  }

  exportChat({required int roomId, required bool includeMedia}) async {
    String? mediaFolderPath;
    Directory chatMediaDirectory;
    final appDir = await getApplicationDocumentsDirectory();
    mediaFolderPath = '${appDir.path}/${roomId.toString()}';

    chatMediaDirectory = Directory(mediaFolderPath);

    if (chatMediaDirectory.existsSync() == false) {
      await Directory(mediaFolderPath).create();
    }
    List messages =
        await getIt<DBManager>().getAllMessages(roomId: roomId, offset: 0);

    File chatTextFile = File('${chatMediaDirectory.path}/chat.text');
    if (chatTextFile.existsSync()) {
      chatTextFile.delete();
      chatTextFile = File('${chatMediaDirectory.path}/chat.text');
    }

    String messagesString = '';
    for (ChatMessageModel message in messages) {
      if (message.messageContentType == MessageContentType.text &&
          message.isDateSeparator == false) {
        messagesString += '\n';
        messagesString +=
            '[${message.messageTime}] ${message.isMineMessage ? 'Me' : message.userName}: ${message.isDeleted == true ? LocalizationString.thisMessageIsDeleted : message.messageContent}';
      }
    }

    chatTextFile.writeAsString(messagesString);

    if (includeMedia) {
      try {
        final tempDir = await getTemporaryDirectory();
        File zipFile = File('${tempDir.path}/chat.zip');
        if (zipFile.existsSync()) {
          zipFile.delete();
          zipFile = File('${tempDir.path}/chat.zip');
        }

        ZipFile.createFromDirectory(
            sourceDir: chatMediaDirectory,
            zipFile: zipFile,
            recurseSubDirs: true);
        Share.shareXFiles([XFile(zipFile.path)]);
      } catch (e) {
        // print(e);
      }
    } else {
      Share.shareXFiles([XFile(chatTextFile.path)]);
    }
  }

  loadImageMessages(int roomId) async {
    photos.value = await getIt<DBManager>()
        .getMessages(roomId: roomId, contentType: MessageContentType.photo);
    update();
  }

  loadVideoMessages(int roomId) async {
    videos.value = await getIt<DBManager>()
        .getMessages(roomId: roomId, contentType: MessageContentType.video);
    update();
  }

  deleteRoomChat(ChatRoomModel chatRoom) {
    getIt<DBManager>().deleteMessagesInRoom(chatRoom);
  }
}

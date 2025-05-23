import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  String user = "";
  List media = [];
  bool isVisibility = false;
  bool isComments = false;
  int videoDuration = 15;
  int itemId = 0;
  List putItems = [];
  String commentBool = "Off";
  String currentUser = "";

  void setCurrentUsers(currentUsers) {
    currentUser = currentUsers;
    notifyListeners();
  }


  void setPutItems(itemSet) {
    putItems = itemSet;
    notifyListeners();
  }

  void setViduration(viduration) {
    videoDuration = viduration;
    notifyListeners();
  }

  void setCommentSwitch(commentSwitch) {
    commentBool = commentSwitch;
    notifyListeners();
  }

  void setItemId(itemIdV) {
    itemId = itemIdV;
    notifyListeners();
  }

  void addUser(userAvatar) {
    user = userAvatar;
    notifyListeners();
  }

  void addMedia(item) {
    media.add(item);
    notifyListeners();
  }

  void clearMedia() {
    media.clear();
    notifyListeners();
  }

  void setComments(comments) {
    isComments = comments;
    notifyListeners();
  }

  void setVisibility(visibility) {
    isVisibility = visibility;
    notifyListeners();
  }
}

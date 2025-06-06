import 'package:fluttertoast/fluttertoast.dart';
import 'package:mazo/BottomSheets/CommentEditBottomSheet.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:mazo/Widgets/Input_Widget.dart';
import 'package:mazo/provider/App_Provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showCommentsBottomSheet(BuildContext context) async {
  final scaffoldContext = context;
  TextEditingController commentController = TextEditingController();

  Future<Map<String, dynamic>> fetchInitialData(BuildContext context) async {
    final commentsResponse = await AppUtils.makeRequests(
      "fetch",
      "SELECT Users.Fullname, Users.urlAvatar, Comments.`id`, Comments.`comment` "
          "FROM Users RIGHT JOIN Comments ON Users.uid COLLATE utf8_unicode_ci = Comments.user_id COLLATE utf8_unicode_ci "
          "WHERE item_id = '${Provider.of<AppProvider>(context, listen: false).itemId.toString()}'",
    );

    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString("UID") ?? "";

    // تأكد إن الريسبونس List قبل إضافته
    final comments = commentsResponse is List ? commentsResponse : [];

    return {'comments': comments, 'uid': uid};
  }

  SharedPreferences prefx = await SharedPreferences.getInstance();

  String lang = prefx.getString("Lang")!;

  var results = await AppUtils.makeRequests(
    "fetch",
    "SELECT $lang FROM Languages ",
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Directionality(
        textDirection: lang == 'arb' ? TextDirection.rtl : TextDirection.ltr,
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchInitialData(context),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            List commentsList = snapshot.data!['comments'] as List;
            String uid = snapshot.data!['uid'] as String;

            String editingCommentId = "";
            String editingCommentText = "";

            return StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    height: 600,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              results[25][lang],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Iconsax.close_circle),
                            ),
                          ],
                        ),
                        Divider(),
                        SizedBox(height: 15),
                        Expanded(
                          child:
                              commentsList.isEmpty
                                  ? Provider.of<AppProvider>(
                                            context,
                                          ).commentBool ==
                                          "OFF"
                                      ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Iconsax.close_circle,
                                              size: 90,
                                              color: Colors.red,
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              results[110][lang],
                                              style: TextStyle(fontSize: 30),
                                            ),
                                          ],
                                        ),
                                      )
                                      : Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Iconsax.close_circle,
                                              size: 90,
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              results[47][lang],
                                              style: TextStyle(fontSize: 30),
                                            ),
                                          ],
                                        ),
                                      )
                                  : ListView.builder(
                                    itemCount: commentsList.length,
                                    itemBuilder: (context, index) {
                                      final comment = commentsList[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 20,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    backgroundImage:
                                                        comment["urlAvatar"] !=
                                                                null
                                                            ? NetworkImage(
                                                              "https://pos7d.site/MAZO/${comment["urlAvatar"]}",
                                                            )
                                                            : null,
                                                    child:
                                                        comment["urlAvatar"] ==
                                                                null
                                                            ? Icon(
                                                              Icons.person,
                                                              color:
                                                                  Colors.grey,
                                                            )
                                                            : null,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          comment["Fullname"] ??
                                                              "مستخدم غير معروف",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          comment["comment"],
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                var result =
                                                    await SimpleMoreComment.showItemComments(
                                                      context,
                                                      comment['id']
                                                    );
                                                if (result != null &&
                                                    result['deleted'] == true) {
                                                  // تم حذف التعليق.. نحدث القائمة
                                                  var comments = await AppUtils.makeRequests(
                                                    "fetch",
                                                    "SELECT Users.Fullname, Users.urlAvatar, Comments.`id`, Comments.`comment` "
                                                        "FROM Users RIGHT JOIN Comments ON Users.uid COLLATE utf8_unicode_ci = Comments.user_id COLLATE utf8_unicode_ci "
                                                        "WHERE item_id = '${Provider.of<AppProvider>(context, listen: false).itemId.toString()}'",
                                                  );
                                                  setState(() {
                                                    commentsList = comments;
                                                  });
                                                } else if (result != null &&
                                                    result is List &&
                                                    result.isNotEmpty) {
                                                  setState(() {
                                                    editingCommentText =
                                                        result[0]['comment'];
                                                    editingCommentId =
                                                        result[0]['id'];
                                                    commentController.text =
                                                        editingCommentText;
                                                  });
                                                }
                                              },
                                              icon: Icon(Iconsax.more_square),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                        ),
                        Visibility(
                          visible:
                              Provider.of<AppProvider>(context).commentBool !=
                              "OFF",
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              InputWidget(
                                isRead: uid == '',
                                icontroller: commentController,
                                iHint: results[48][lang],
                                isuffixIcon: Transform.flip(
                                  flipX: true,
                                  child: IconButton(
                                    onPressed: () async {
                                      if (uid == '') {
                                        context.go('/login');
                                        return;
                                      }

                                      if (commentController.text
                                          .trim()
                                          .isEmpty) {
                                        Fluttertoast.showToast(
                                          msg: results[111][lang],
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.TOP,
                                          backgroundColor: Colors.black54,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                        return;
                                      }

                                      if (editingCommentText.isNotEmpty) {
                                        await AppUtils.makeRequests(
                                          "query",
                                          "UPDATE Comments SET comment = '${commentController.text}' WHERE id = '$editingCommentId'",
                                        );
                                      } else {
                                        await AppUtils.makeRequests(
                                          "query",
                                          "INSERT INTO Comments VALUES(NULL, '${commentController.text}', '$uid', '${Provider.of<AppProvider>(context, listen: false).itemId}', '${DateTime.now()}')",
                                        );
                                      }

                                      commentController.clear();

                                      var updatedComments = await AppUtils.makeRequests(
                                        "fetch",
                                        "SELECT Users.Fullname, Users.urlAvatar, Comments.`id`, Comments.`comment` "
                                            "FROM Users RIGHT JOIN Comments ON Users.uid COLLATE utf8_unicode_ci = Comments.user_id COLLATE utf8_unicode_ci "
                                            "WHERE item_id = '${Provider.of<AppProvider>(context, listen: false).itemId}'",
                                      );

                                      setState(() {
                                        commentsList =
                                            updatedComments is List
                                                ? updatedComments
                                                : [];
                                        editingCommentText = "";
                                        editingCommentId = "";
                                      });
                                    },
                                    icon: Icon(Iconsax.send_1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );
}

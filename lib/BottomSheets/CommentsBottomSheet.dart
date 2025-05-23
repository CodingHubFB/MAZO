import 'package:MAZO/Core/Utils.dart';
import 'package:MAZO/Widgets/Input_Widget.dart';
import 'package:MAZO/provider/App_Provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showCommentsBottomSheet(BuildContext context) {
  TextEditingController commentController = TextEditingController();
  List commentsList = [];
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setState) {
            Future getComments() async {
              var comments = await AppUtils.makeRequests(
                "fetch",
                "SELECT Users.Fullname, Users.urlAvatar, Comments.`comment` FROM Users RIGHT JOIN Comments ON Users.uid COLLATE utf8_unicode_ci = Comments.user_id COLLATE utf8_unicode_ci WHERE item_id = '${Provider.of<AppProvider>(context, listen: false).itemId.toString()}'",
              );
              setState(() {
                commentsList = comments;
              });
            }

            setState(() {
              getComments();
            });
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
                          "التعليقات",
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
                              ? Provider.of<AppProvider>(context).commentBool ==
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
                                          "التعليقات غير مفعلة هنا",
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
                                        Icon(Iconsax.close_circle, size: 90),
                                        SizedBox(height: 20),
                                        Text(
                                          "لا يوجد تعليقات هنا",
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
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.grey[300],
                                          backgroundImage:
                                              comment["urlAvatar"] != null
                                                  ? NetworkImage(
                                                    "https://pos7d.site/MAZO/${comment["urlAvatar"]}",
                                                  )
                                                  : null,
                                          child:
                                              comment["urlAvatar"] == null
                                                  ? Icon(
                                                    Icons.person,
                                                    color: Colors.grey,
                                                  )
                                                  : null,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                comment["Fullname"] ??
                                                    "مستخدم غير معروف",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                comment["comment"],
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    ),
                    Visibility(
                      visible:
                          Provider.of<AppProvider>(context).commentBool == "OFF"
                              ? false
                              : true,
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          InputWidget(
                            icontroller: commentController,
                            iHint: "أضف تعليقاً",
                            isuffixIcon: Transform.flip(
                              flipX: true,
                              child: IconButton(
                                onPressed: () async {
                                  SharedPreferences prefx =
                                      await SharedPreferences.getInstance();

                                  await AppUtils.makeRequests(
                                    "query",
                                    "INSERT INTO Comments VALUES(NULL, '${commentController.text}', '${prefx.getString("UID")}', '${Provider.of<AppProvider>(context, listen: false).itemId.toString()}', '${DateTime.now()}')",
                                  );

                                  commentController.clear();
                                  getComments();
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
        ),
      );
    },
  );
}

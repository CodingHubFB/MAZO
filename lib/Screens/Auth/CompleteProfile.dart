import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mazo/BottomSheets/UserPickerBottomSheet.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:mazo/Widgets/Back_Button.dart';
import 'package:mazo/Widgets/Button_Widget.dart';
import 'package:mazo/Widgets/Input_Widget.dart';
import 'package:mazo/provider/App_Provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateUser extends StatefulWidget {
  final String? phonenumber;
  const CreateUser({super.key, this.phonenumber});

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final TextEditingController nameController = TextEditingController();
  bool isValid = false;
  String lang = "eng";
  List languages = [];

  Future getLang() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();

    setState(() {
      lang = prefx.getString("Lang")!;
      getLangDB();
    });
  }

  Future getLangDB() async {
    var results = await AppUtils.makeRequests(
      "fetch",
      "SELECT $lang FROM Languages ",
    );
    setState(() {
      languages = results;
    });
  }

  @override
  void initState() {
    getLang();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String userAvatar = Provider.of<AppProvider>(context).user;
    return Directionality(
      textDirection: lang == 'arb' ? TextDirection.rtl : TextDirection.ltr,
      child:
          languages.isEmpty
              ? Scaffold()
              : Scaffold(
                backgroundColor: Colors.white,
                body: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 50,
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 70),
                              Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      SimpleMediaPicker.showPicker(context);
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        userAvatar != ''
                                            ? FileImage(File(userAvatar))
                                            : null,
                                    child:
                                        userAvatar != ''
                                            ? null
                                            : Center(
                                              child: Icon(
                                                Iconsax.camera,
                                                size: 30,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                              Text(
                                languages[6][lang] ?? "",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              InputWidget(
                                ikeyboardType: TextInputType.name,
                                icontroller: nameController,
                                iHint: languages[7][lang] ?? "",
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                height: 50,
                                child: GestureDetector(
                                  onTap: () async {
                                    if (nameController.text.trim().isNotEmpty) {
                                      int uid = 1000 + Random().nextInt(9999);
                                      int oid = 1000 + Random().nextInt(9999);
                                      if (userAvatar.isNotEmpty) {
                                        AppUtils().uploadUsers(userAvatar, uid);
                                      }
                                      String? fcmToken =
                                          await FirebaseMessaging.instance
                                              .getToken();
                                      AppUtils.makeRequests(
                                        "query",
                                        "INSERT INTO Users VALUES(NULL, '${nameController.text}', '${widget.phonenumber}', '$uid','$oid', 'uploads/Users/$uid.webp', '$fcmToken','${DateTime.now().toString().split(' ')[0]}') ",
                                      );
                                      SharedPreferences prefx =
                                          await SharedPreferences.getInstance();
                                      prefx.setString("UID", uid.toString());
                                      prefx.setString("OID", oid.toString());
                                      context.go('/splash');
                                    } else {
                                      AppUtils.snackBarShowing(
                                        context,
                                        languages[109][lang] ?? "",
                                      );
                                    }
                                  },
                                  child: ButtonWidget(
                                    isDisabled: isValid,
                                    btnText: languages[8][lang] ?? "",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: lang == 'eng' ? 20 : null,
                      right: lang == 'arb' ? 20 : null,
                      child: InkWell(
                        onTap: () {
                          context.go('/home');
                        },
                        child: RectButtonWidget(
                          bicon:
                              lang == 'arb'
                                  ? Iconsax.arrow_circle_right
                                  : Iconsax.arrow_circle_left,
                          bsize: 35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

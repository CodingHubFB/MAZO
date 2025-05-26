import 'dart:io';
import 'dart:math';

import 'package:MAZO/BottomSheets/UserPickerBottomSheet.dart';
import 'package:MAZO/Core/Utils.dart';
import 'package:MAZO/Widgets/Back_Button.dart';
import 'package:MAZO/Widgets/Button_Widget.dart';
import 'package:MAZO/Widgets/Input_Widget.dart';
import 'package:MAZO/provider/App_Provider.dart';
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

  @override
  Widget build(BuildContext context) {
    String userAvatar = Provider.of<AppProvider>(context).user;
    print(userAvatar);
    return Scaffold(
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
                          child:
                              userAvatar != ''
                                  ? null
                                  : Center(
                                    child: Icon(Iconsax.camera, size: 30),
                                  ),
                          backgroundImage:
                              userAvatar != ''
                                  ? FileImage(File(userAvatar))
                                  : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Enter Merchant Name",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    InputWidget(
                      ikeyboardType: TextInputType.name,
                      icontroller: nameController,
                      iHint: "Full Name",
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: GestureDetector(
                        onTap: () async {
                          int uid = 1000 + Random().nextInt(9999);
                          int oid = 1000 + Random().nextInt(9999);
                          AppUtils().uploadUsers(userAvatar, uid);
                          AppUtils.makeRequests(
                            "query",
                            "INSERT INTO Users VALUES(NULL, '${nameController.text}', '${widget.phonenumber}', '$uid','$oid', 'uploads/Users/$uid.webp', '${DateTime.now().toString().split(' ')[0]}') ",
                          );
                          SharedPreferences prefx =
                              await SharedPreferences.getInstance();
                          prefx.setString("UID", uid.toString());
                          prefx.setString("OID", oid.toString());
                          context.go('/splash');
                        },
                        child: ButtonWidget(
                          isDisabled: isValid,
                          btnText: "Next",
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
            left: 20,
            child: InkWell(
              onTap: () {
                context.go('/home');
              },
              child: RectButtonWidget(
                bicon: Iconsax.arrow_circle_left,
                bsize: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

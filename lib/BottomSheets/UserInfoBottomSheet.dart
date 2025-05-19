import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Userinfobottomsheet {
  static void showMore(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.profile_circle),
                title: const Text('View Profile'),
                onTap: () async {},
              ),
              ListTile(
                leading: const Icon(Iconsax.logout),
                title: const Text('Logout'),
                onTap: () async {
                  SharedPreferences prefx =
                      await SharedPreferences.getInstance();
                  prefx.remove("UID");
                  context.go('/splash');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

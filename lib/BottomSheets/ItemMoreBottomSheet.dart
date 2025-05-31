import 'package:mazo/BottomSheets/ItemDetailsBottomSheet.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:mazo/provider/App_Provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleMoreItems {
  static void showItemDetails(BuildContext context) async {
    SharedPreferences prefx = await SharedPreferences.getInstance();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
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
                Visibility(
                  visible: prefx.getString("UID") != null ? true : false,
                  child: ListTile(
                    leading: const Icon(Iconsax.user_octagon),
                    title: const Text('عرض الملف الشخصي'),
                    onTap: () async {
                      SharedPreferences prefx =
                          await SharedPreferences.getInstance();
                      AppUtils.sNavigateToReplace(context, '/UserProfile', {
                        'userId': prefx.getString("UID")!,
                      });
                    },
                  ),
                ),
                Visibility(
                  visible: prefx.getString("OID") != null ? true : false,
                  child: ListTile(
                    leading: const Icon(Iconsax.shopping_cart),
                    title: const Text('عرض سلة التسوق'),
                    onTap: () async {
                      context.go('/cart');
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Iconsax.note),
                  title: const Text('الوصف'),
                  onTap: () async {
                    showItemDetailsBottomSheet(
                      context,
                      itemId:
                          Provider.of<AppProvider>(
                            context,
                            listen: false,
                          ).itemId.toString(),
                    );
                  },
                ),
                Visibility(
                  visible: prefx.getString("UID") != null ? true : false,
                  child: ListTile(
                    leading: const Icon(Iconsax.logout),
                    title: const Text('تسجيل الخروج'),
                    onTap: () async {
                      SharedPreferences prefx =
                          await SharedPreferences.getInstance();
                      prefx.remove("UID");
                      context.go('/splash');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

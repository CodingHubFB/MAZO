import 'package:MAZO/BottomSheets/ItemDetailsBottomSheet.dart';
import 'package:MAZO/provider/App_Provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleMoreItems {
  static void showItemDetails(BuildContext context) {
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
                ListTile(
                  leading: const Icon(Iconsax.user_octagon),
                  title: const Text('عرض الملف الشخصي'),
                  onTap: () async {},
                ),
                ListTile(
                  leading: const Icon(Iconsax.note),
                  title: const Text('الوصف'),
                  onTap: () async {
                    showItemDetailsBottomSheet(
                      context,
                      title:
                          Provider.of<AppProvider>(
                            context,
                            listen: false,
                          ).putItems[Provider.of<AppProvider>(
                            context,
                            listen: false,
                          ).itemId]['name'],
                      description:
                          Provider.of<AppProvider>(
                            context,
                            listen: false,
                          ).putItems[Provider.of<AppProvider>(
                            context,
                            listen: false,
                          ).itemId]['description'],
                      likes: 120, // عدّل على حسب بياناتك
                      views: 4500,
                      publishDate: DateTime.parse(
                        '2024-01-15',
                      ), // عدّل حسب تاريخ النشر الحقيقي
                    );
                    print(
                      Provider.of<AppProvider>(
                        context,
                        listen: false,
                      ).putItems[Provider.of<AppProvider>(
                        context,
                        listen: false,
                      ).itemId],
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Iconsax.logout),
                  title: const Text('تسجيل الخروج'),
                  onTap: () async {
                    SharedPreferences prefx =
                        await SharedPreferences.getInstance();
                    prefx.remove("UID");
                    context.go('/splash');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

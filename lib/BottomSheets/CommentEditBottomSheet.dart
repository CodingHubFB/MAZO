import 'package:MAZO/Core/Utils.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SimpleMoreComment {
  static Future<dynamic> showItemComments(
    BuildContext context,
    commentId,
  ) async {
    return await showModalBottomSheet(
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
                  leading: const Icon(Iconsax.edit),
                  title: const Text('تعديل'),
                  onTap: () async {
                    var currentComment = await AppUtils.makeRequests(
                      "fetch",
                      "SELECT id, comment FROM Comments WHERE id = '$commentId'",
                    );
                    Navigator.pop(context, currentComment);
                  },
                ),
                ListTile(
                  leading: const Icon(Iconsax.trash),
                  title: const Text('حذف'),
                  onTap: () async {
                    await AppUtils.makeRequests(
                      "query",
                      "DELETE FROM Comments WHERE id = '$commentId'",
                    );
                    Navigator.pop(context);
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

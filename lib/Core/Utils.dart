import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppUtils {
  static sNavigateTo(context, routeName) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => routeName));
  }

  static sNavigateToReplace(
    BuildContext context,
    String routeName,
    Map<String, String> queryParams,
  ) {
    GoRouter.of(context).go(routeName, extra: queryParams);
  }

  static snackBarShowing(context, snackTitle) {
    return ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(snackTitle)));
  }

  static makeRequests(type, query) async {
    final response = await Dio().get(
      "https://pos7d.site/MAZO/Requests.php?$type=$query&k=${DateTime.now().millisecondsSinceEpoch}",
    );
    return json.decode(response.data);
  }

  Future uploadUsers(pathFile, uid) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        pathFile,
        filename: pathFile.split('/').last,
      ),
      "uid": uid,
      "k": DateTime.now().millisecondsSinceEpoch,
    });
    final response = await Dio().post(
      'https://pos7d.site/MAZO/UploadUsers.php',
      data: formData,
      onSendProgress: (int sent, int total) {},
    );
    if (response.statusCode == 200) {
      print('Image uploaded successfully: ${response.data}');
    }
  }

  Future uploadItems(pathFile, itemId) async {
      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(pathFile, filename: pathFile.split('/').last),
        "itemId": itemId,
        "k": DateTime.now().millisecondsSinceEpoch
      });
      final response = await Dio().post('https://pos7d.site/MAZO/Upload.php', data: formData, onSendProgress: (int sent, int total) {
      });
      if (response.statusCode == 200) {
        print('Image uploaded successfully: ${response.data}');
      }
  }
}

import 'package:MAZO/Core/Utils.dart';
import 'package:MAZO/Routes/App_Router.dart' as MyApp;
import 'package:MAZO/provider/App_Provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MediaPickerBottomSheet {
  static final ImagePicker _picker = ImagePicker();
  // Method to open Camera for Image or Video
  static Future<XFile?> openCamera(BuildContext context, bool isVideo) async {
    XFile? file;
    print("📸 فتح الكاميرا عشان ${isVideo ? 'فيديو' : 'صورة'}");

    if (isVideo) {
      file = await _picker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxDuration: Duration(
          seconds:
              Provider.of<AppProvider>(context, listen: false).videoDuration,
        ),
      );
    } else {
      file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );
    }
    return file;
  }

  static Future<XFile?> openGallery(BuildContext context, bool isVideo) async {
    XFile? file;
    if (isVideo) {
      file = await _picker.pickVideo(
        source: ImageSource.gallery,
        preferredCameraDevice: CameraDevice.rear,
        maxDuration: Duration(
          seconds:
              Provider.of<AppProvider>(context, listen: false).videoDuration,
        ),
      );
    } else {
      file = await _picker.pickImage(
        source: ImageSource.gallery,
        preferredCameraDevice: CameraDevice.rear,
      );
    }
    return file;
  }

  static void showPrimaryOptions(BuildContext context, navigate) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
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
                leading: const Icon(Iconsax.camera),
                title: const Text('التقاط صورة'),
                onTap: () {
                  Navigator.pop(context);
                  showSecondaryOptions(
                    context,
                    isVideo: false,
                    navigate: navigate,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.video),
                title: const Text('إلتقاط فيديو'),
                trailing: GestureDetector(
                  onTap: () {
                    if (Provider.of<AppProvider>(
                          context,
                          listen: false,
                        ).videoDuration ==
                        180) {
                      Provider.of<AppProvider>(
                        context,
                        listen: false,
                      ).setViduration(15);
                    } else {
                      Provider.of<AppProvider>(
                        context,
                        listen: false,
                      ).setViduration(180);
                    }
                  },
                  child: Text(
                    Provider.of<AppProvider>(context).videoDuration == 180
                        ? '3m'
                        : '15s',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showSecondaryOptions(
                    context,
                    isVideo: true,
                    navigate: navigate,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void showSecondaryOptions(
    BuildContext context, {
    required bool isVideo,
    bool navigate = true,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
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
                leading: const Icon(Iconsax.camera),
                title: Text(
                  isVideo
                      ? 'تسجيل فيديو من الكاميرا'
                      : 'التقاط صورة من الكاميرا',
                ),
                onTap: () {
                  Navigator.pop(context);
                  openCamera(context, isVideo).then((value) {
                    if (value != null) {
                      Provider.of<AppProvider>(
                        MyApp.navigatorKey.currentContext!,
                        listen: false,
                      ).addMedia(value.path);

                      if (navigate) {
                        setItemData();
                        MyApp.navigatorKey.currentContext!.go('/addDetails');
                      }
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.gallery),
                title: Text(
                  isVideo ? 'تسجيل فيديو من المعرض' : 'اختيار صورة من المعرض',
                ),
                onTap: () {
                  Navigator.pop(context);

                  openGallery(context, isVideo).then((value) async {
                    if (value != null) {
                      Provider.of<AppProvider>(
                        MyApp.navigatorKey.currentContext!,
                        listen: false,
                      ).addMedia(value.path);

                      if (navigate) {
                        setItemData();
                        MyApp.navigatorKey.currentContext!.go('/addDetails');
                      }
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

setItemData() async {
  final response = await AppUtils.makeRequests(
    "query",
    "INSERT INTO Items (id) VALUES (NULL)",
  );

  if (response.containsKey('id')) {
    final itemId = response['id'];
    print("آخر ID تم إدخاله هو: $itemId");

    final currentContext = MyApp.navigatorKey.currentContext;
    if (currentContext != null && currentContext.mounted) {
      Provider.of<AppProvider>(currentContext, listen: false).setItemId(itemId);
    } else {
      print("Navigator Context مش موجود أو مش شغال دلوقتي.");
    }
  } else {
    print("في مشكلة حصلت: ${response['error']}");
  }
}

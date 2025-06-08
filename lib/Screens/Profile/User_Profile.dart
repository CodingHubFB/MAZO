import 'dart:io';

import 'package:google_fonts/google_fonts.dart';
import 'package:mazo/BottomSheets/UserMoreBottomSheet.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mazo/provider/App_Provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UserProfile extends StatefulWidget {
  final String userId;
  const UserProfile({super.key, required this.userId});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  List allMerchantItems = [];
  List merchantItems = [];
  List merchantUsers = [];
  List languages = [];
  int currentIndex = 0;
  String lang = "eng";
  Map<String, Future<String?>> thumbnailFutures = {};

  String totalItems = "";
  String ordered = "";
  String uid = '';

  Future getLang() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();

    setState(() {
      lang = prefx.getString("Lang")!;
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

  Future getMerchantItems() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();
    var merchantItemsAll = await AppUtils.makeRequests(
      "fetch",
      "SELECT Users.Fullname, Users.urlAvatar, Items.`id`,Items.`name`,Items.`price`, Items.media, Items.created_at, Items.Views, Items.uid FROM Users LEFT JOIN Items ON Users.uid = Items.uid WHERE Items.uid = '${widget.userId}' ORDER BY Items.created_at DESC ",
    );
    setState(() {
      allMerchantItems = merchantItemsAll;
      merchantItems = List.from(allMerchantItems);
      uid = prefx.getString("UID")!;
    });
  }

  Future getMerchant() async {
    var merchantUser = await AppUtils.makeRequests(
      "fetch",
      "SELECT Fullname, urlAvatar FROM Users WHERE uid = '${widget.userId}' ",
    );
    setState(() {
      merchantUsers = merchantUser;
    });
  }

  Future getCountItenswithUser() async {
    var countItems = await AppUtils.makeRequests(
      "fetch",
      "SELECT COUNT(Items.id) as count_items FROM Users LEFT JOIN Items ON Users.uid = Items.uid WHERE Items.uid = '${widget.userId}'",
    );
    setState(() {
      totalItems = countItems[0]['count_items'];
    });
  }

  void orderData(String orderx) {
    setState(() {
      switch (orderx) {
        case "Latest":
          merchantItems.sort(
            (a, b) => DateTime.parse(
              b['created_at'],
            ).compareTo(DateTime.parse(a['created_at'])),
          );
          break;
        case "Popular":
          merchantItems.sort(
            (a, b) => int.parse(
              b['Views'].toString(),
            ).compareTo(int.parse(a['Views'].toString())),
          );
          break;
        case "Oldest":
          merchantItems.sort(
            (a, b) => DateTime.parse(
              a['created_at'],
            ).compareTo(DateTime.parse(b['created_at'])),
          );
          break;
      }
    });
  }

  Future<String?> generateVideoThumbnail(String videoUrl) async {
    print(videoUrl);

    final tempDir = await getTemporaryDirectory();

    // اسم فريد بناءً على الفيديو
    final fileName = Uri.parse(videoUrl).pathSegments.last;
    final thumbnailPath = '${tempDir.path}/$fileName.jpg';

    // لو الصورة موجودة بالفعل، رجعها
    if (File(thumbnailPath).existsSync()) {
      return thumbnailPath;
    }
    print(thumbnailPath);

    // لو مش موجودة، تولدها مرة واحدة
    return await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: thumbnailPath,
      imageFormat: ImageFormat.WEBP,
      maxHeight: 300,
      quality: 75,
    );
  }

  @override
  void initState() {
    getLang();

    getMerchantItems();
    getCountItenswithUser();
    getMerchant();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getLangDB();
    return Directionality(
      textDirection: lang == 'arb' ? TextDirection.rtl : TextDirection.ltr,
      child:
          languages.isEmpty
              ? Scaffold()
              : Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  leading: IconButton(
                    onPressed: () {
                      context.go('/home');
                    },
                    icon: Icon(
                      lang == 'arb'
                          ? Iconsax.arrow_circle_right
                          : Iconsax.arrow_circle_left,
                    ),
                  ),
                  forceMaterialTransparency: true,
                  backgroundColor: Colors.transparent,
                  title: Text(
                    languages[36][lang] ?? "",
                    style: TextStyle(color: Colors.black),
                  ),
                  centerTitle: true,
                  elevation: 0,
                  actions: [
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences prefx =
                            await SharedPreferences.getInstance();
                        if (prefx.getString("Lang") == 'arb') {
                          prefx.setString("Lang", "eng");
                        } else {
                          prefx.setString("Lang", "arb");
                        }
                        getLang();
                        Provider.of<AppProvider>(
                          context,
                          listen: false,
                        ).setLang(lang);
                        setState(() {});
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Image.asset("assets/img/$lang.png", width: 30),
                      ),
                    ),
                  ],
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        height: 170,
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                merchantUsers.isNotEmpty
                                    ? "https://pos7d.site/MAZO/${merchantUsers[0]['urlAvatar']}"
                                    : "",
                              ),
                            ),
                            SizedBox(width: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 180,
                                  child: Text(
                                    "${merchantUsers.isNotEmpty ? merchantUsers[0]['Fullname'] : ""}",
                                    style: TextStyle(fontSize: 27),
                                  ),
                                ),
                                Text(
                                  "$totalItems ${int.parse(totalItems) > 2 && int.parse(totalItems) < 11 ? languages[112][lang] ?? "" : languages[113][lang] ?? ""}",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Visibility(
                        visible:
                            merchantItems.isEmpty && allMerchantItems.isEmpty
                                ? false
                                : true,
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                orderData("Latest");
                                setState(() {
                                  currentIndex = 0;
                                });
                              },
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  chipTheme: ChipThemeData.fromDefaults(
                                    secondaryColor: Colors.grey.shade100,
                                    brightness: Brightness.light,
                                    labelStyle: TextStyle(),
                                  ).copyWith(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    side: BorderSide.none,
                                  ),
                                ),
                                child: Chip(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 11,
                                  ),
                                  backgroundColor:
                                      currentIndex == 0
                                          ? Colors.black
                                          : Colors.grey.shade100,
                                  label: Text(
                                    languages[37][lang] ?? "",
                                    style: TextStyle(
                                      color:
                                          currentIndex == 0
                                              ? Colors.white
                                              : Colors.black,
                                      fontFamily:
                                          GoogleFonts.tajawal().fontFamily,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                orderData("Popular");
                                setState(() {
                                  currentIndex = 1;
                                });
                              },
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  chipTheme: ChipThemeData.fromDefaults(
                                    secondaryColor: Colors.grey.shade100,
                                    brightness: Brightness.light,
                                    labelStyle: TextStyle(),
                                  ).copyWith(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    side: BorderSide.none,
                                  ),
                                ),
                                child: Chip(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 11,
                                  ),
                                  backgroundColor:
                                      currentIndex == 1
                                          ? Colors.black
                                          : Colors.grey.shade100,
                                  label: Text(
                                    languages[38][lang] ?? "",
                                    style: TextStyle(
                                      color:
                                          currentIndex == 1
                                              ? Colors.white
                                              : Colors.black,
                                      fontFamily:
                                          GoogleFonts.tajawal().fontFamily,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                orderData("Oldest");
                                setState(() {
                                  currentIndex = 2;
                                });
                              },
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  chipTheme: ChipThemeData.fromDefaults(
                                    secondaryColor: Colors.grey.shade100,
                                    brightness: Brightness.light,
                                    labelStyle: TextStyle(),
                                  ).copyWith(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    side: BorderSide.none,
                                  ),
                                ),
                                child: Chip(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 11,
                                  ),
                                  backgroundColor:
                                      currentIndex == 2
                                          ? Colors.black
                                          : Colors.grey.shade100,
                                  label: Text(
                                    languages[39][lang] ?? "",
                                    style: TextStyle(
                                      color:
                                          currentIndex == 2
                                              ? Colors.white
                                              : Colors.black,
                                      fontFamily:
                                          GoogleFonts.tajawal().fontFamily,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child:
                            merchantItems.isEmpty && allMerchantItems.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Iconsax.close_circle,
                                        color: Colors.red,
                                        size: 80,
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        "No Items Found",
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : RefreshIndicator(
                                  onRefresh: () => getMerchantItems(),
                                  child: MasonryGridView.builder(
                                    gridDelegate:
                                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                        ),
                                    itemCount: merchantItems.length,
                                    itemBuilder: (context, index) {
                                      // جلب أول ميديا
                                      // جلب أول ميديا
                                      String firstMedia =
                                          merchantItems[index]['media']
                                              .toString()
                                              .split(',')[0]
                                              .trim();

                                      // استخراج الامتداد بشكل دقيق
                                      String fileExtension =
                                          Uri.parse(
                                            firstMedia,
                                          ).path.split('.').last.toLowerCase();

                                      // رابط الميديا
                                      String mediaUrl =
                                          "https://pos7d.site/MAZO/uploads/Items/${merchantItems[index]['id']}/$firstMedia";

                                      thumbnailFutures[mediaUrl] ??=
                                          generateVideoThumbnail(mediaUrl);
                                      print(thumbnailFutures[mediaUrl]);
                                      return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          AppUtils.sNavigateToReplace(
                                            context,
                                            '/UserProfileHome',
                                            {
                                              'userProfileId': widget.userId,
                                              'item_id':
                                                  merchantItems[index]['id'],
                                            },
                                          );
                                        },
                                        child: Container(
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                          ),
                                          child: Stack(
                                            children: [
                                              // الصورة أو الفيديو
                                              ClipRRect(
                                                child:
                                                    fileExtension == 'mp4'
                                                        ? FutureBuilder(
                                                          future:
                                                              thumbnailFutures[mediaUrl],
                                                          builder: (
                                                            context,
                                                            snapshot,
                                                          ) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return Container(
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade200,
                                                              );
                                                            }
                                                            if (snapshot
                                                                .hasData) {
                                                              return AbsorbPointer(
                                                                absorbing: true,
                                                                child: Image.file(
                                                                  File(
                                                                    snapshot
                                                                        .data!,
                                                                  ),
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                  width:
                                                                      double
                                                                          .infinity,
                                                                  height:
                                                                      double
                                                                          .infinity,
                                                                ),
                                                              );
                                                            }
                                                            return Icon(
                                                              Icons.error,
                                                            );
                                                          },
                                                        )
                                                        : Image.network(
                                                          mediaUrl,
                                                          fit: BoxFit.cover,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                        ),
                                              ),

                                              // الـ Gradient من الأسفل
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                height: 50,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin:
                                                          Alignment
                                                              .bottomCenter,
                                                      end: Alignment.topCenter,
                                                      colors: [
                                                        Colors.black
                                                            .withOpacity(0.7),
                                                        Colors.transparent,
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        const BorderRadius.vertical(
                                                          bottom:
                                                              Radius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                  ),
                                                ),
                                              ),

                                              // مثال على كتابة اسم فوق الجريدينت
                                              Positioned(
                                                bottom: 8,
                                                left: lang == 'eng' ? 5 : null,
                                                right: lang == 'arb' ? 5 : null,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 140,
                                                      child: Text(
                                                        merchantItems[index]['name'],
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "${merchantItems[index]['price']} ${languages[53][lang]}",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: 3,
                                                right: 3,
                                                child: Visibility(
                                                  visible:
                                                      uid ==
                                                              merchantItems[index]['uid']
                                                          ? true
                                                          : false,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.4),
                                                          blurRadius: 6,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        SimpleUserMore.showUserMore(
                                                          context,
                                                          merchantItems[index]['id'],
                                                        ).then((val) {
                                                          if (val != null) {
                                                            setState(() {
                                                              getMerchantItems();
                                                              getCountItenswithUser();
                                                            });
                                                            print("Done");
                                                          }
                                                        });
                                                      },
                                                      icon: Icon(
                                                        Iconsax.more,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

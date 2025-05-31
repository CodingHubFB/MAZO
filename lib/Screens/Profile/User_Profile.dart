import 'package:mazo/BottomSheets/UserMoreBottomSheet.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int currentIndex = 0;

  String totalItems = "";
  String ordered = "";
  String uid = '';

  Future getMerchantItems() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();
    var merchantItemsAll = await AppUtils.makeRequests(
      "fetch",
      "SELECT Users.Fullname, Users.urlAvatar, Items.`id`,Items.`name`,Items.`price`, Items.media, Items.created_at, Items.Views, Items.uid FROM Users LEFT JOIN Items ON Users.uid = Items.uid WHERE Items.uid = '${widget.userId}' ",
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

  @override
  void initState() {
    getMerchantItems();
    getCountItenswithUser();
    getMerchant();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go('/home');
          },
          icon: Icon(Iconsax.arrow_circle_left),
        ),
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        title: Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
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
                        "$totalItems Items",
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
                          "Latest",
                          style: TextStyle(
                            color:
                                currentIndex == 0 ? Colors.white : Colors.black,
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
                          "Popular",
                          style: TextStyle(
                            color:
                                currentIndex == 1 ? Colors.white : Colors.black,
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
                          "Oldest",
                          style: TextStyle(
                            color:
                                currentIndex == 2 ? Colors.white : Colors.black,
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
                        child: MasonryGridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
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

                            return GestureDetector(
                              onTap: () {
                                AppUtils.sNavigateToReplace(
                                  context,
                                  '/UserProfileHome',
                                  {
                                    'userProfileId': widget.userId,
                                    'item_id': merchantItems[index]['id'],
                                  },
                                );
                              },
                              child: Container(
                                width: double.infinity,
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
                                              ? BetterPlayer.network(
                                                mediaUrl,
                                                betterPlayerConfiguration:
                                                    BetterPlayerConfiguration(
                                                      autoPlay: false,
                                                      looping: false,
                                                      aspectRatio: 9 / 16,
                                                      controlsConfiguration:
                                                          BetterPlayerControlsConfiguration(
                                                            enableMute: false,
                                                            showControls: false,
                                                          ),
                                                    ),
                                              )
                                              : Image.network(
                                                mediaUrl,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
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
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.7),
                                              Colors.transparent,
                                            ],
                                          ),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                bottom: Radius.circular(8),
                                              ),
                                        ),
                                      ),
                                    ),

                                    // مثال على كتابة اسم فوق الجريدينت
                                    Positioned(
                                      bottom: 8,
                                      left: 5,
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
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "${merchantItems[index]['price']}",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
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
                                            uid == merchantItems[index]['uid']
                                                ? true
                                                : false,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.4,
                                                ),
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
    );
  }
}

import 'dart:async';

import 'package:mazo/BottomSheets/CommentsBottomSheet.dart';
import 'package:mazo/BottomSheets/ItemMoreBottomSheet.dart';
import 'package:mazo/BottomSheets/MediaPickerBottomSheet.dart';
import 'package:mazo/BottomSheets/CartBottomSheet.dart';
import 'package:mazo/Core/Theme.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:mazo/Screens/SearchScreen.dart';
import 'package:mazo/provider/App_Provider.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final Map<int, Map<int, BetterPlayerController>> videoControllers = {};
  bool showCenterIcon = false;
  IconData centerIcon = Iconsax.play;
  bool showCenterIconLikes = false;
  IconData centerIconLikes = Iconsax.like_1;
  Duration? videoDuration;
  Duration? videoPosition;
  int activeItemIndex = 0;
  int activeMediaIndex = 0;
  VoidCallback? videoListener;
  final Map<String, Duration> watchedDurations = {};
  final Map<String, Timer> watchTimers = {};
  String qtt = "";

  Future getCartQtt(itemId) async {
    SharedPreferences prefx = await SharedPreferences.getInstance();
    var cartQTT = await AppUtils.makeRequests(
      "fetch",
      "SELECT qtt FROM Cart WHERE user_id = '${prefx.getString("UID")}' AND item_id = '$itemId' AND order_id = '${prefx.getString("OID")}' ",
    );

    setState(() {
      if (cartQTT != null &&
          cartQTT.isNotEmpty &&
          cartQTT[0] != null &&
          cartQTT[0]['qtt'] != null) {
        qtt = cartQTT[0]['qtt'].toString();
      } else {
        qtt = "0";
      }
    });
  }

  void playVideo(int itemIndex, int mediaIndex) {
    // أوقف كل الفيديوهات التانية
    videoControllers.forEach((outerIndex, innerMap) {
      innerMap.forEach((innerIndex, controller) {
        if (!(outerIndex == itemIndex && innerIndex == mediaIndex)) {
          controller.pause();
        }
      });
    });

    // شغّل الفيديو الحالي
    final newController = videoControllers[itemIndex]?[mediaIndex];
    if (newController != null) {
      newController.play();
    }

    activeItemIndex = itemIndex;
    activeMediaIndex = mediaIndex;
  }

  void togglePlayPause(BetterPlayerController? controller) {
    if (controller == null) return;

    final isPlaying =
        controller.videoPlayerController?.value.isPlaying ?? false;

    setState(() {
      showCenterIcon = true;
      centerIcon = isPlaying ? Iconsax.pause : Iconsax.play;
    });

    if (isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    // إخفاء الأيقونة بعد 800ms
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          showCenterIcon = false;
        });
      }
    });
  }

  void toggleLikeUnlikes() {
    setState(() {
      showCenterIconLikes = true;
      centerIconLikes = Iconsax.like_1;
    });

    // إخفاء الأيقونة بعد 800ms
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          showCenterIconLikes = false;
        });
      }
    });
  }

  int _currentIndex = 0;
  int currentJndex = 0;
  List currentUsers = [];

  final List<String> videoUrls = [];

  List items = [];
  String countLikes = "";
  String userLIkes = "";

  bool isVideo(String url) {
    return url.toLowerCase().endsWith(".mp4") ||
        url.toLowerCase().endsWith(".mov") ||
        url.toLowerCase().endsWith(".avi") ||
        url.toLowerCase().endsWith(".webm");
  }

  void openSearch() async {
    final selectedItemId = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen()),
    );

    if (selectedItemId != null) {
      setState(() {
        activeItemIndex = items.indexWhere(
          (item) => item['id'] == selectedItemId,
        );
        activeMediaIndex = 0;
        _pageController.jumpToPage(activeItemIndex);
      });
    }
  }

  Future getCountLikes(itmid) async {
    var itemCount = await AppUtils.makeRequests(
      "fetch",
      "SELECT COUNT(id) as likes FROM Likes WHERE item_id = '$itmid'",
    );
    setState(() {
      countLikes = itemCount[0]['likes'];
    });
  }

  Future getCurrentMerchant(userId) async {
    var currentUser = await AppUtils.makeRequests(
      "fetch",
      "SELECT id, Fullname, urlAvatar, uid FROM Users WHERE uid = '$userId'",
    );

    setState(() {
      currentUsers = currentUser;
    });
  }

  Future getUserLike(itmid) async {
    SharedPreferences prefx = await SharedPreferences.getInstance();
    var itemCount = await AppUtils.makeRequests(
      "fetch",
      "SELECT COUNT(id) as likes FROM Likes WHERE user_id = '${prefx.getString("UID")}' AND item_id = '$itmid'",
    );
    setState(() {
      userLIkes = itemCount[0]['likes'];
    });
  }

  Future getItems() async {
    var itemsx = await AppUtils.makeRequests(
      "fetch",
      "SELECT * FROM Items WHERE visibility = 'Public'",
    );

    // getCurrentMerchant();

    if (itemsx != null && itemsx.isNotEmpty && itemsx is List) {
      itemsx.shuffle();
      if (mounted) {
        setState(() {
          items.addAll(itemsx);
        });
      }

      final firstItem = itemsx.first;

      final mediaList =
          firstItem['media']
              .toString()
              .split(',')
              .map((e) => e.trim())
              .toList();

      // نتحقق إذا أول media فعليًا هو فيديو
      final firstMedia = mediaList[0];
      if (firstMedia.endsWith('.mp4')) {
        // ✅ أول media هو فيديو، نهيّئ ونشغّل
        initializeVideoController(
          "https://pos7d.site/MAZO/uploads/Items/${firstItem['id']}/$firstMedia",
          0,
          0,
        );
        playVideo(0, 0);
      } else {
        // ❌ أول media مش فيديو، ما تعملش حاجة
        print("⛔ أول ميديا مش فيديو، مش هيشتغل تلقائي.");
      }
      Provider.of<AppProvider>(context, listen: false).setPutItems(items);
      Provider.of<AppProvider>(context, listen: false).setCurrentId("0");
      Provider.of<AppProvider>(
        context,
        listen: false,
      ).setItemId(int.parse(firstItem['id']));
      Provider.of<AppProvider>(
        context,
        listen: false,
      ).setCurrentUsers(firstItem['uid']);
      getCurrentMerchant(
        Provider.of<AppProvider>(context, listen: false).currentUser,
      );
      getCartQtt(firstItem['id']);
      getCountLikes(firstItem['id']);
      getUserLike(firstItem['id']);
    }
  }

  @override
  void initState() {
    super.initState();
    getItems();
  }

  void initializeVideoController(
    String path,
    int itemIndex,
    int mediaIndex,
  ) async {
    videoControllers[itemIndex] ??= {};

    if (videoControllers[itemIndex]!.containsKey(mediaIndex)) {
      videoControllers[itemIndex]![mediaIndex]?.dispose();
      videoControllers[itemIndex]!.remove(mediaIndex);
    }

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      path,
    );

    final controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        looping: true,
        eventListener: (event) {
          print("EventWool: ${event.betterPlayerEventType.name}");
          if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
            final controller = videoControllers[itemIndex]?[mediaIndex];
            controller?.seekTo(Duration.zero);
            controller?.play();
          }
        },
        aspectRatio: 9 / 16,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableMute: false,
          showControls: false,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );

    videoListener = () {
      final controllerState = controller.videoPlayerController?.value;

      if (!mounted ||
          controllerState == null ||
          controllerState.duration == null ||
          controllerState.position == 0)
        return;

      setState(() {
        videoDuration = controllerState.duration;
        videoPosition = controllerState.position;
      });
    };

    controller.videoPlayerController?.addListener(videoListener!);

    videoControllers[itemIndex]![mediaIndex] = controller;
  }

  void disposeVideoController(int itemIndex, int mediaIndex) async {
    if (videoControllers.containsKey(itemIndex) &&
        videoControllers[itemIndex]!.containsKey(mediaIndex)) {
      final controller = videoControllers[itemIndex]![mediaIndex];

      try {
        controller?.videoPlayerController?.removeListener(
          () {},
        ); // نظف أي listener
        await controller?.pause();
      } catch (_) {}

      await Future.delayed(Duration(milliseconds: 200));
      controller?.dispose();
      videoControllers[itemIndex]!.remove(mediaIndex);
    }
  }

  @override
  void dispose() {
    // videoControllers.forEach((key, controller) => controller.dispose());
    videoControllers.clear();
    _pageController.dispose();
    for (final timer in watchTimers.values) {
      timer.cancel();
    }
    for (final controllerMap in videoControllers.values) {
      for (final controller in controllerMap.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentController =
        videoControllers[activeItemIndex]?[activeMediaIndex];
    final videoDuration =
        currentController?.videoPlayerController?.value.duration;
    final videoPosition =
        currentController?.videoPlayerController?.value.position;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        title: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Iconsax.add_circle, color: Colors.white, size: 25),
            onPressed: () async {
              SharedPreferences prefx = await SharedPreferences.getInstance();
              if (prefx.getString("UID") != null) {
                MediaPickerBottomSheet.showPrimaryOptions(context, true);
              } else {
                context.go('/login');
              }
            },
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Iconsax.search_normal,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () {
                openSearch();
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Iconsax.more_circle,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () {
                SimpleMoreItems.showItemDetails(context);
              },
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: items.length,
        onPageChanged: (index) async {
          SharedPreferences prefx = await SharedPreferences.getInstance();

          // وقف الفيديو اللي فات
          disposeVideoController(_currentIndex, currentJndex);
          if (activeItemIndex != 0 || activeMediaIndex != 0) {
            videoControllers[activeItemIndex]?[activeMediaIndex]?.pause();
          }

          // حدث المؤشرات
          setState(() {
            activeItemIndex = index;
            activeMediaIndex = 0;
            _currentIndex = index;
            currentJndex = 0;
          });

          // لو وصلنا لنهاية القائمة، هات بيانات تانية
          if (index >= items.length - 1) {
            await getItems();
          }

          final item = items[index];
          final mediaList =
              item['media'].toString().split(',').map((e) => e.trim()).toList();
          final firstMedia = mediaList[0];

          // شغل الفيديو الأول لو كان فيديو
          if (firstMedia.endsWith('.mp4')) {
            initializeVideoController(
              "https://pos7d.site/MAZO/uploads/Items/${item['id']}/$firstMedia",
              index,
              0,
            );
            playVideo(index, 0);
          }

          // باقي الطلبات
          Provider.of<AppProvider>(context, listen: false).setPutItems(items);
          Provider.of<AppProvider>(
            context,
            listen: false,
          ).setItemId(int.parse(item['id']));
          Provider.of<AppProvider>(
            context,
            listen: false,
          ).setCurrentId(index.toString());
          Provider.of<AppProvider>(
            context,
            listen: false,
          ).setCommentSwitch(item['comments']);
          Provider.of<AppProvider>(
            context,
            listen: false,
          ).setCurrentUsers(item['uid']);

          await AppUtils.makeRequestsViews(
            "query",
            "UPDATE Items SET Views = Views + 1 WHERE id = '${item['id']}'",
          );

          getCartQtt(item['id']);
          getCountLikes(item['id']);
          getUserLike(item['id']);
          getCurrentMerchant(item['uid']);
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items[index]['media'].toString().split(',').length,
                onPageChanged: (mediaIndex) async {
                  // وقف الفيديو اللي فات
                  disposeVideoController(index, currentJndex);
                  videoControllers[activeItemIndex]?[activeMediaIndex]?.pause();

                  final mediaList =
                      items[index]['media']
                          .toString()
                          .split(',')
                          .map((e) => e.trim())
                          .toList();
                  final currentMedia = mediaList[mediaIndex];

                  setState(() {
                    activeMediaIndex = mediaIndex;
                    currentJndex = mediaIndex;
                  });

                  if (currentMedia.endsWith('.mp4')) {
                    initializeVideoController(
                      "https://pos7d.site/MAZO/uploads/Items/${items[index]['id']}/$currentMedia",
                      index,
                      mediaIndex,
                    );
                    playVideo(index, mediaIndex);
                  }
                },
                itemBuilder: (context, mediaIndex) {
                  final mediaList =
                      items[index]['media']
                          .toString()
                          .split(',')
                          .map((e) => e.trim())
                          .toList();
                  final mediaUrl = mediaList[mediaIndex];
                  final isVideo = mediaUrl.endsWith('.mp4');
                  final isActive =
                      index == activeItemIndex &&
                      mediaIndex == activeMediaIndex;

                  if (isVideo && isActive) {
                    final controller = videoControllers[index]?[mediaIndex];

                    if (controller == null ||
                        !controller.isVideoInitialized()!) {
                      return Center(
                        child: SpinKitChasingDots(
                          color: AppTheme.backgroundColor,
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        if (controller.isPlaying()!) {
                          controller.pause();
                          setState(() {
                            showCenterIcon = true;
                            centerIcon = Iconsax.pause_circle;
                          });
                        } else {
                          controller.play();
                          setState(() {
                            showCenterIcon = true;
                            centerIcon = Iconsax.play_circle;
                          });
                        }

                        // اختفي بعد ثواني
                        Future.delayed(Duration(seconds: 1), () {
                          setState(() {
                            showCenterIcon = false;
                          });
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          BetterPlayer(controller: controller),
                          if (showCenterIcon)
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: showCenterIcon ? 1.0 : 0.0,
                              child: AnimatedScale(
                                duration: Duration(milliseconds: 300),
                                scale: showCenterIcon ? 1.5 : 0.0,
                                curve: Curves.easeOutBack,
                                child: Icon(
                                  centerIcon,
                                  size: 60,
                                  color: Colors.white.withOpacity(0.9),
                                  shadows: [
                                    Shadow(
                                      blurRadius: 12,
                                      color: Colors.black87,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  } else if (isVideo) {
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    return Image.network(
                      "https://pos7d.site/MAZO/uploads/Items/${items[index]['id']}/$mediaUrl",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    );
                  }
                },
              ),
              Positioned(
                left: 0,
                bottom: videoDuration != null && videoPosition != null ? 30 : 0,
                right: 0, // عشان العرض ما يبقاش محدود
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      currentUsers.isNotEmpty
                          ? GestureDetector(
                            onTap: () {
                              AppUtils.sNavigateToReplace(
                                context,
                                '/UserProfile',
                                {'userId': currentUsers[0]['uid']},
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    "https://pos7d.site/MAZO/${currentUsers[0]['urlAvatar']}",
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  currentUsers[0]['Fullname'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : Container(),
                      SizedBox(height: 8),
                      Text(
                        items[index]['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "${items[index]['price']} QAR",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        items[index]['description'],
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),

              // أزرار التفاعل
              Positioned(
                right: 16,
                bottom: 130,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          userLIkes != "0" ? Iconsax.like_15 : Iconsax.like_1,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () async {
                          toggleLikeUnlikes();
                          SharedPreferences prefx =
                              await SharedPreferences.getInstance();
                          if (prefx.getString("UID") != null) {
                            var likes = await AppUtils.makeRequests(
                              "fetch",
                              "SELECT * FROM Likes WHERE user_id = '${prefx.getString("UID")}' AND item_id = '${items[index]['id']}' ",
                            );
                            if (likes[0] != null) {
                              await AppUtils.makeRequests(
                                "query",
                                "DELETE FROM Likes WHERE user_id = '${prefx.getString("UID")}' AND item_id = '${items[index]['id']}'",
                              );
                            } else {
                              await AppUtils.makeRequests(
                                "query",
                                "INSERT INTO Likes VALUES(NULL, '${prefx.getString("UID")}', '${items[index]['id']}', '${DateTime.now()}')",
                              );
                            }
                            getCountLikes(items[index]['id']);
                            getUserLike(items[index]['id']);
                          } else {
                            context.go('/login');
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      countLikes,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 10,
                            color: Colors.black, // ظل خفيف وناعم
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Iconsax.message_text_1,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {
                          showCommentsBottomSheet(context);
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "0",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 10,
                            color: Colors.black, // ظل خفيف وناعم
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Iconsax.share,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {
                          var currentMedia =
                              items[index]['media']
                                  .toString()
                                  .split(',')
                                  .map((e) => e.trim())
                                  .toList()[index];
                          String mediaUrl =
                              "https://pos7d.site/MAZO/uploads/Items/${items[index]['id']}/$currentMedia";
                          String shareMessage =
                              "شوف المنتج ده على MAZO 👇\n$mediaUrl";
                          SharePlus.instance.share(
                            ShareParams(text: shareMessage),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "0",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 10,
                            color: Colors.black, // ظل خفيف وناعم
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          qtt != "0"
                              ? Iconsax.shopping_cart5
                              : Iconsax.shopping_cart,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () async {
                          SharedPreferences prefx =
                              await SharedPreferences.getInstance();
                          if (prefx.getString("OID") != null) {
                            var notCartAdded = await AppUtils.makeRequests(
                              "fetch",
                              "SELECT * FROM Cart WHERE user_id = '${prefx.getString("UID")}' AND item_id = '${items[index]['id']}' AND order_id = '${prefx.getString("OID")}' ",
                            );
                            if (notCartAdded[0] == null) {
                              AppUtils.makeRequests(
                                "query",
                                "INSERT INTO Cart VALUES (NULL, '${prefx.getString("UID")}', '${items[index]['id']}', '0','${prefx.getString("OID")}')",
                              );
                              getCartQtt(items[index]['id']);
                            }

                            CartBottomSheet.showCart(
                              context,
                              notCartAdded[0]['id'],
                              int.parse(qtt),
                              (newQtt) {
                                if (newQtt == 0) {
                                  AppUtils.makeRequests(
                                    "query",
                                    "DELETE FROM Cart WHERE id = '${notCartAdded[0]['id']}'",
                                  );
                                }
                                getCartQtt(items[index]['id']);
                              },
                            );
                          } else {
                            context.go('/login');
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      qtt,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 10,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),

              if (videoDuration != null && videoPosition != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Slider(
                    value:
                        videoPosition.inMilliseconds
                            .clamp(0, videoDuration.inMilliseconds)
                            .toDouble(),
                    min: 0,
                    max: videoDuration.inMilliseconds.toDouble(),
                    thumbColor: Colors.white,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white38,
                    onChanged: (value) {
                      final newPosition = Duration(milliseconds: value.toInt());
                      currentController?.videoPlayerController?.seekTo(
                        newPosition,
                      );
                      setState(() {});
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

//                   return Stack(
//                     children: [
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height,
//                         width: MediaQuery.of(context).size.width,
//                         child:
//                             isVideoFile
//                                 ? (videoControllers[index] != null &&
//                                         videoControllers[index]![jndex] != null
//                                     ? GestureDetector(
//                                       onTap: () {
//                                         final controller =
//                                             videoControllers[index]?[jndex];
//                                         togglePlayPause(controller);
//                                       },
//                                       child: Stack(
//                                         alignment: Alignment.center,
//                                         children: [
//                                           BetterPlayer(
//                                             controller:
//                                                 videoControllers[index]![jndex]!,
//                                           ),

//                                           // Likes
//                                           AnimatedOpacity(
//                                             duration: Duration(
//                                               milliseconds: 300,
//                                             ),
//                                             opacity:
//                                                 showCenterIconLikes ? 1.0 : 0.0,
//                                             child: AnimatedScale(
//                                               duration: Duration(
//                                                 milliseconds: 300,
//                                               ),
//                                               scale:
//                                                   showCenterIconLikes
//                                                       ? 1.5
//                                                       : 0.0,
//                                               curve: Curves.easeOutBack,
//                                               child: Icon(
//                                                 centerIconLikes,
//                                                 size: 60,
//                                                 color: Colors.white.withOpacity(
//                                                   0.9,
//                                                 ),
//                                                 shadows: [
//                                                   Shadow(
//                                                     blurRadius: 12,
//                                                     color: Colors.black87,
//                                                     offset: Offset(0, 2),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                     : const Center(
//                                       child: SpinKitCircle(color: Colors.white),
//                                     ))
//                                 : Image.network(
//                                   "https://pos7d.site/MAZO/uploads/Items/${items[index]['id']}/$mediaUrl",
//                                   fit: BoxFit.cover,
//                                 ),
//                       ),
//                     ],
//                   );
//                 },
//               ),

//               // محتوى الفيديو فوق (مثلاً اسم المستخدم والوصف)

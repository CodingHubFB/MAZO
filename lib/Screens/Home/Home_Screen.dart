import 'package:MAZO/BottomSheets/MediaPickerBottomSheet.dart';
import 'package:MAZO/BottomSheets/UserInfoBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  BetterPlayerController? _betterPlayerController;
  int _currentIndex = 0;

  final List<String> videoUrls = [
    'https://homy-design.com/shortshop/1.mp4',
    'https://homy-design.com/shortshop/1.mp4',
    'https://homy-design.com/shortshop/1.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _initializePlayer(videoUrls[0]);
  }

  void _initializePlayer(String url) {
    // تخلص من الكونترولر القديم لو موجود
    _betterPlayerController?.dispose();

    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
    );

    _betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        autoPlay: true,
        looping: true,
        aspectRatio: 9 / 16,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ),
        subtitlesConfiguration: BetterPlayerSubtitlesConfiguration(
          outlineEnabled: false, // تعطيل الترجمة لو موجودة
        ),
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );

    // بعد إنشاء الكونترولر الجديد، حدث الواجهة لو الودجت مازال موجود
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {},
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
                Userinfobottomsheet.showMore(context);
              },
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: videoUrls.length,
        onPageChanged: (index) {
          _currentIndex = index;
          _initializePlayer(videoUrls[index]);
        },
        itemBuilder: (context, index) {
          if (_currentIndex != index) {
            // عشان ميتشغلش فيديو إلا الصفحة الحالية
            return Container(color: Colors.black);
          }
          return Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height, // ارتفاع الشاشة كله
                width: MediaQuery.of(context).size.width,
                child:
                    _betterPlayerController != null
                        ? BetterPlayer(controller: _betterPlayerController!)
                        : const Center(child: CircularProgressIndicator()),
              ),
              // محتوى الفيديو فوق (مثلاً اسم المستخدم والوصف)
              Positioned(
                left: 0,
                bottom: 80,
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
                      Text(
                        'Username',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Description of the video goes here',
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
                        icon: const Icon(
                          Iconsax.like_1,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {},
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
                          Iconsax.message_text_1,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {},
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
                        onPressed: () {},
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
                          Iconsax.shopping_cart,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {},
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
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

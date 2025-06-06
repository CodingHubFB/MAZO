import 'package:mazo/Core/Theme.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:mazo/Widgets/Button_Widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List cartOrders = [];
  double totalPrices = 0.00;

  Future getCartOrders() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();
    var orders = await AppUtils.makeRequests(
      "fetch",
      "SELECT Cart.id AS id, Items.`name`, Items.id AS itmid,Items.price, Items.media,Items.uid, Cart.qtt FROM Cart LEFT JOIN Items ON Cart.item_id = Items.id WHERE Cart.order_id = '${prefx.getString("OID")}'",
    );

    setState(() {
      cartOrders = orders;
      totalPrices = 0.0; // لازم تصفره قبل التكرار
      for (var cartOrder in cartOrders) {
        totalPrices +=
            double.parse(cartOrder['price'].toString()) *
            double.parse(cartOrder['qtt'].toString());
      }
    });
  }

  void calculateTotalPrices() {
    double newTotal = 0.0;
    for (var cartOrder in cartOrders) {
      newTotal +=
          double.parse(cartOrder['price'].toString()) *
          double.parse(cartOrder['qtt'].toString());
    }
    setState(() {
      totalPrices = newTotal;
    });
  }

  @override
  void initState() {
    getCartOrders();
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
        centerTitle: true,
        title: Text("My Cart", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body:
          cartOrders.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.shopping_bag, size: 130),
                    SizedBox(height: 20),
                    Text(
                      "No Cart Items",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    ...List.generate(cartOrders.length, (i) {
                      // خالص الوسائط مفصولة
                      List<String> mediaList = cartOrders[i]['media']
                          .toString()
                          .split(',');

                      // ابحث عن أول صورة (مش فيديو)
                      String? firstImage;
                      for (var media in mediaList) {
                        media = media.trim();
                        if (!media.endsWith('.mp4') &&
                            !media.endsWith('.mov') &&
                            !media.endsWith('.avi')) {
                          firstImage = media;
                          break;
                        }
                      }

                      return ListTile(
                        onTap: () {
                          AppUtils.sNavigateToReplace(
                            context,
                            '/UserProfileHome',
                            {
                              'userProfileId': cartOrders[i]['uid'],
                              'item_id': cartOrders[i]['itmid'],
                            },
                          );
                        },
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        leading: CircleAvatar(
                          radius: 29,
                          backgroundImage:
                              firstImage != null
                                  ? NetworkImage(
                                    "https://pos7d.site/MAZO/uploads/Items/${cartOrders[i]['itmid']}/$firstImage",
                                  )
                                  : null,
                          backgroundColor: Colors.grey[300],
                        ),
                        title: Text(cartOrders[i]['name'], maxLines: 1),
                        subtitle: Text(cartOrders[i]['price']),
                        trailing: Container(
                          alignment: Alignment.center,
                          width: 100,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    int currentQtt = int.parse(
                                      cartOrders[i]['qtt'].toString(),
                                    );

                                    if (currentQtt > 1) {
                                      currentQtt = currentQtt - 1;

                                      setState(() {
                                        cartOrders[i]['qtt'] =
                                            currentQtt.toString();
                                      });

                                      await AppUtils.makeRequestsViews(
                                        "query",
                                        "UPDATE Cart SET qtt = $currentQtt WHERE id = '${cartOrders[i]['id']}' ",
                                      );
                                      calculateTotalPrices();
                                    } else {
                                      // حذف العنصر لو الكمية وصلت للصفر
                                      await AppUtils.makeRequestsViews(
                                        "query",
                                        "DELETE FROM Cart WHERE id = '${cartOrders[i]['id']}' ",
                                      );

                                      setState(() {
                                        cartOrders.removeAt(i);
                                      });
                                    }
                                  },

                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .primaryContainer,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Icon(Iconsax.minus),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: 30,
                                height: 30,
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  "${cartOrders[i]['qtt']}",
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    int currentQtt = int.parse(
                                      cartOrders[i]['qtt'].toString(),
                                    );
                                    currentQtt = currentQtt + 1;

                                    setState(() {
                                      cartOrders[i]['qtt'] =
                                          currentQtt.toString();
                                    });

                                    AppUtils.makeRequestsViews(
                                      "query",
                                      "UPDATE Cart SET qtt = $currentQtt WHERE id = '${cartOrders[i]['id']}' ",
                                    );
                                    calculateTotalPrices();
                                  },

                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .primaryContainer,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Icon(Iconsax.add),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 80),
                  ],
                ),
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Visibility(
        visible: cartOrders.isEmpty ? false : true,
        child: GestureDetector(
          onTap: () {
            context.go('/CheckoutSummary');
          },
          child: SizedBox(
            height: 60,
            child: ButtonWidget(btnText: "Go To Checkout $totalPrices QAR"),
          ),
        ),
      ),
    );
  }
}

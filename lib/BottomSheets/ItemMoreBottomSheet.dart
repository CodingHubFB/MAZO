import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mazo/BottomSheets/ItemDetailsBottomSheet.dart';
import 'package:mazo/Core/Theme.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:mazo/provider/App_Provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class moreBottomSheet extends StatefulWidget {
  const moreBottomSheet({super.key});

  @override
  State<moreBottomSheet> createState() => moreBottomSheetState();
}

class moreBottomSheetState extends State<moreBottomSheet> {
  late Future<Map<String, dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    getLang();
    futureData = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString("UID");
    final oid = prefs.getString("OID");

    final results = await AppUtils.makeRequests(
      "fetch",
      "SELECT uid FROM Items WHERE uid = '$uid'",
    );

    final ordersResult = await AppUtils.makeRequests(
      "fetch",
      "SELECT cust_id FROM Orders WHERE cust_id = '$uid'",
    );
    print(results);
    return {
      'UID': uid,
      'OID': oid,
      'hasItems': results[0],
      'hasOrders': ordersResult[0],
    };
  }

  String lang = "eng";
  List languages = [];

  Future getLang() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();

    setState(() {
      lang = prefx.getString("Lang")!;
      getLangDB();
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: lang == 'arb' ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Map<String, dynamic>>(
          future: futureData,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: SpinKitDoubleBounce(
                  color: AppTheme.primaryColor,
                  size: 30.0,
                ),
              );
            }

            final data = snapshot.data!;
            final uid = data['UID'];
            final oid = data['OID'];
            final hasItems = data['hasItems'];
            final hasOrders = data['hasOrders'];

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (uid != null)
                  ListTile(
                    leading: const Icon(Iconsax.user_octagon),
                    title: Text(languages[30][lang]),
                    onTap: () {
                      AppUtils.sNavigateToReplace(context, '/UserProfile', {
                        'userId': uid,
                      });
                    },
                  ),
                // طلبات العملاء: لما يكون مسجل وعنده أصناف
                if (uid != null && hasItems != null)
                  ListTile(
                    leading: const Icon(Iconsax.task_square),
                    title: Text(languages[31][lang]),
                    onTap: () {
                      context.go('/customersOrders');
                    },
                  ),

                // طلباتي: لما يكون مسجل وعنده طلبات
                if (uid != null && hasOrders != null)
                  ListTile(
                    leading: const Icon(Iconsax.receipt),
                    title: Text(languages[32][lang]),
                    onTap: () {
                      AppUtils.sNavigateToReplace(context, '/customersOrders', {
                        'custId': uid,
                      });
                    },
                  ),

                if (uid != null && oid != null)
                  ListTile(
                    leading: const Icon(Iconsax.shopping_cart),
                    title: Text(languages[33][lang]),
                    onTap: () {
                      context.go('/cart');
                    },
                  ),
                ListTile(
                  leading: const Icon(Iconsax.note),
                  title: Text(languages[34][lang]),
                  onTap: () {
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
                if (uid != null)
                  ListTile(
                    leading: const Icon(Iconsax.logout),
                    title: Text(languages[35][lang]),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.remove("UID");
                      context.go('/splash');
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

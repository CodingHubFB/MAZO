import 'package:MAZO/Core/Utils.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  TextEditingController searchController = TextEditingController();

  Future fetchItems() async {
    var itemsx = await AppUtils.makeRequests(
      "fetch",
      "SELECT id, name FROM Items WHERE visibility = 'Public'",
    );

    if (itemsx != null && itemsx is List) {
      setState(() {
        allItems = List<Map<String, dynamic>>.from(itemsx);
        filteredItems = allItems; // في البداية كلها ظاهرة
      });
    }
  }

  void filterItems(String query) {
    final results =
        query.isEmpty
            ? allItems
            : allItems
                .where(
                  (item) => item['name'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();

    setState(() {
      filteredItems = results;
    });
  }

  


  @override
  void initState() {
    super.initState();
    fetchItems();
    searchController.addListener(() {
      filterItems(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Iconsax.arrow_circle_right),
            onPressed: () => Navigator.pop(context),
          ),
          title: TextFormField(
            controller: searchController,
            onChanged: (value) {
              final query = value.toLowerCase();

              setState(() {
                filteredItems =
                    allItems.where((item) {
                      final itemName = item['name'].toString().toLowerCase();
                      return itemName.contains(query);
                    }).toList();
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              hintText: "البحث في مازو",
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children:
                filteredItems.map((item) {
                  return ListTile(
                    onTap: () {
                      Navigator.pop(context, item['id']);
                    },
                    title: Text(item['name']),
                    trailing: Icon(Iconsax.search_normal),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}

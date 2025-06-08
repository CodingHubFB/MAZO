import 'package:mazo/Core/Utils.dart';
import 'package:mazo/Widgets/Button_Widget.dart';
import 'package:mazo/Widgets/DropdownFormField.dart';
import 'package:mazo/Widgets/Input_Widget.dart';
import 'package:mazo/provider/App_Provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShippingOrders extends StatefulWidget {
  const ShippingOrders({super.key});

  @override
  State<ShippingOrders> createState() => _ShippingOrdersState();
}

class _ShippingOrdersState extends State<ShippingOrders> {
  TextEditingController fullName = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController zoneNo = TextEditingController();
  TextEditingController streetNo = TextEditingController();
  TextEditingController buildNo = TextEditingController();
  String? selectedCountry;
  String? selectedCity;
  bool saveAddress = false;
  bool openAddressForm = false;
  int isActive = -1;

  List<String> arabCountries = [
    "Algeria",
    "Bahrain",
    "Comoros",
    "Djibouti",
    "Egypt",
    "Iraq",
    "Jordan",
    "Kuwait",
    "Lebanon",
    "Libya",
    "Mauritania",
    "Morocco",
    "Oman",
    "Palestine",
    "Qatar",
    "Saudi Arabia",
    "Somalia",
    "Sudan",
    "Syria",
    "Tunisia",
    "United Arab Emirates",
    "Yemen",
  ];

  List arabCities = [];
  List addressesList = [];

  Future getCurrentUser() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();
    var user = await AppUtils.makeRequests(
      "fetch",
      "SELECT Fullname, PhoneNumber FROM Users WHERE uid = '${prefx.getString("UID")}' ",
    );
    setState(() {
      fullName.text = user[0]['Fullname'];
      mobileNumber.text = user[0]['PhoneNumber'];
    });
  }

  Future getShippingAddresses() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();
    var addresses = await AppUtils.makeRequests(
      "fetch",
      "SELECT * FROM Shipping_Orders WHERE uid = '${prefx.getString("UID")}' ",
    );
    setState(() {
      addressesList = addresses;
    });
  }

  Future getArabCities() async {
    var request = await Dio().get(
      "https://countriesnow.space/api/v0.1/countries",
    );
    var response = request.data;
    for (var i = 0; i < response['data'].length; i++) {
      if (response['data'][i]['country'] == selectedCountry) {
        setState(() {
          arabCities = response['data'][i]['cities'];
        });
      }
    }
  }

  @override
  void initState() {
    getCurrentUser();
    getShippingAddresses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getArabCities();
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go('/CheckoutSummary');
          },
          icon: Icon(Iconsax.arrow_circle_left),
        ),
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text("Shipping Details", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ...List.generate(addressesList.length, (i) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          isActive = i;
                          Provider.of<AppProvider>(
                            context,
                            listen: false,
                          ).setSelectedAddress(addressesList[i]);
                          Provider.of<AppProvider>(
                            context,
                            listen: false,
                          ).setShipId(addressesList[i]['id']);
                          print(
                            Provider.of<AppProvider>(
                              context,
                              listen: false,
                            ).shipId,
                          );
                        });
                      },
                      child: SizedBox(
                        width: double.maxFinite,
                        height: 80,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side:
                                isActive == i
                                    ? BorderSide(color: Colors.black, width: 2)
                                    : BorderSide.none,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          color: Colors.grey.shade100,
                          elevation: 0,
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Icon(Iconsax.location),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${addressesList[i]['City']}, ${addressesList[i]['Country']}",
                                    ),
                                    Text(
                                      "Zone: ${addressesList[i]['Zone Number']}, Street: ${addressesList[i]['Street Number']}, Building: ${addressesList[i]['Building Number']}",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        openAddressForm = !openAddressForm;
                      });
                    },
                    child: ButtonWidget(
                      btnText:
                          openAddressForm ? "Close Form" : "Add New Address",
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),

          if (openAddressForm)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    InputWidget(icontroller: fullName, iHint: "Full Name"),
                    SizedBox(height: 15),
                    InputWidget(
                      icontroller: mobileNumber,
                      iHint: "Mobile Number",
                      ikeyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),
                    InputWidget(icontroller: email, iHint: "Email"),
                    SizedBox(height: 15),
                    DropdownFormMenuField(
                      iHint: "Country / Region",
                      dItems:
                          arabCountries.map((country) {
                            return DropdownMenuItem<String>(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCountry = val!;
                          getArabCities();
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    DropdownFormMenuField(
                      iHint: "City",
                      dItems:
                          arabCities.map((city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCity = val!;
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: InputWidget(
                            icontroller: zoneNo,
                            iHint: "Zone Number",
                            ikeyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: InputWidget(
                            icontroller: streetNo,
                            iHint: "Street Number",
                            ikeyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    InputWidget(
                      icontroller: buildNo,
                      iHint: "Building Number",
                      ikeyboardType: TextInputType.number,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: saveAddress,
                            onChanged: (value) {
                              setState(() {
                                saveAddress = value!;
                                isActive = 0;
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Save This Address",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 70),
                  ],
                ),
              ),
            ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          isKeyboardOpen
              ? null
              : GestureDetector(
                onTap: () async {
                  if (isActive != -1) {
                    SharedPreferences prefx =
                        await SharedPreferences.getInstance();

                    if (saveAddress == true) {
                      // 1. Add the record
                      await AppUtils.makeRequests(
                        "query",
                        "INSERT INTO Shipping_Orders VALUES(NULL, '${fullName.text}', '${mobileNumber.text}', '${email.text}', '$selectedCountry', '$selectedCity', '${zoneNo.text}', '${streetNo.text}', '${buildNo.text}', '${prefx.getString("UID")}','${prefx.getString("OID")}')",
                      );

                      // 2. Get the latest inserted record for this user and order
                      var latestAddress = await AppUtils.makeRequests(
                        "fetch",
                        "SELECT * FROM Shipping_Orders WHERE uid = '${prefx.getString("UID")}' AND oid = '${prefx.getString("OID")}' ORDER BY id DESC LIMIT 1",
                      );

                      print("Latest address added:");
                      Provider.of<AppProvider>(
                        context,
                        listen: false,
                      ).setSelectedAddress(latestAddress[0]);
                      Provider.of<AppProvider>(
                        context,
                        listen: false,
                      ).setShipId(latestAddress[0]['id']);
                    }
                    context.go('/checkout');
                  } else {
                    AppUtils.snackBarShowing(
                      context,
                      "Please Choose The Address.",
                    );
                  }
                },

                child: SizedBox(
                  height: 60,
                  child: ButtonWidget(btnText: "Checkout"),
                ),
              ),
    );
  }
}

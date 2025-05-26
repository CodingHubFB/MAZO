import 'package:MAZO/Core/Utils.dart';
import 'package:MAZO/Widgets/Button_Widget.dart';
import 'package:MAZO/Widgets/DropdownFormField.dart';
import 'package:MAZO/Widgets/Input_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
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
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              ...List.generate(addressesList.length, (i) {
                return SizedBox(
                  width: double.maxFinite,
                  height: 80,
                  child: Card(
                    color: Colors.grey.shade100,
                    elevation: 0,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Icon(Iconsax.location),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${addressesList[i]['City']}, ${addressesList[i]['Country']}",
                            ),
                            Text(
                              "Zone No: ${addressesList[i]['Zone Number']}, Street No: ${addressesList[i]['Street Number']}, Building No: ${addressesList[i]['Building Number']}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    openAddressForm = true;
                  });
                },
                child: ButtonWidget(btnText: "Add New Address"),
              ),
              SizedBox(height: 20),
              Expanded(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          isKeyboardOpen
              ? null
              : GestureDetector(
                onTap: () async {
                  SharedPreferences prefx =
                      await SharedPreferences.getInstance();
                  if (saveAddress == true) {
                    AppUtils.makeRequests(
                      "query",
                      "INSERT INTO Shipping_Orders VALUES(NULL, '${fullName.text}', '${mobileNumber.text}', '${email.text}', '$selectedCountry', '$selectedCity', '${zoneNo.text}', '${streetNo.text}', '${buildNo.text}', '${prefx.getString("UID")}','${prefx.getString("OID")}')",
                    );
                  }
                  context.go('/checkout');
                },
                child: SizedBox(
                  height: 60,
                  child: ButtonWidget(btnText: "Pay"),
                ),
              ),
    );
  }
}

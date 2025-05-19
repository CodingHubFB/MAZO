import 'package:flutter/material.dart';

class MyLoadingDialog extends StatelessWidget {
  final String? text;
  const MyLoadingDialog({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 200,
              child: Text(text!, style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),)),
            CircularProgressIndicator(color: Theme.of(context).primaryColor,)
          ],
        ),
      ),
    );
  }
}
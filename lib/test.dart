import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              final box = context.findRenderObject() as RenderBox?;
              await SharePlus.instance.share(
                ShareParams(
                  text: 'Check this out!',
                  sharePositionOrigin:
                      box!.localToGlobal(Offset.zero) & box.size,
                ),
              );
            } catch (e) {
              print("Share Error: $e");
            }
          },
          child: Text("Test Share on iOS"),
        ),
      ),
    );
  }
}

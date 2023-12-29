import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ailink/ailink.dart';

extension Uint8ListExtension on Uint8List {
  String toHex() {
    return map((byte) => '0x${(byte.toRadixString(16).padLeft(2, '0')).toUpperCase()}').join(',');
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _ailinkPlugin = Ailink();
  Uint8List? _decryptedPayload;


  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    Uint8List? decryptedPayload;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _ailinkPlugin.getPlatformVersion() ?? 'Unknown platform version';
      final payload = [0x01, 0x1c, 0x01, 0x2c, 0x12, 0x01, 0x01, 0xba, 0x01, 0x42, 0xc6, 0x93, 0xe5, 0x6d, 0xa2, 0xd0, 0x22, 0x05, 0xff, 0xff];
      decryptedPayload = await _ailinkPlugin.decryptBroadcast(Uint8List.fromList(payload));
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    setState(() {
      _decryptedPayload = decryptedPayload;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Running on: $_platformVersion\n'),
            Text('Decrypted Payload: ${_decryptedPayload?.toHex()}\n'),
          ],
        ),
      ),
    );
  }
}

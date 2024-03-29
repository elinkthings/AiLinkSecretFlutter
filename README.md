# ailink

##[中文](README_CN.md)

AiLink broadcast scale data decryption and body fat algorithm Flutter library.

## Necessary condition

1. Acquired AILink Bluetooth communication protocol
2. Have smart devices that support AILink Bluetooth module
3. Have knowledge of Flutter development and debugging

## Android

1. Add ```maven { url 'https://jitpack.io' }``` in android/build.gradle file
```
    allprojects {
        repositories {
            google()
            mavenCentral()
            //add
            maven { url 'https://jitpack.io' }
        }
    }
```

2. Modify ```minSdkVersion 21``` in the android/app/build.gradle file
```
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId "com.example.ailink_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-gradle-build-configuration.
        minSdkVersion 21 //flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
```

3. To use the flutter_blue_plus library, you need to add the required permissions to android/app/src/main/AndroidManifest.xml
```
    <manifest xmlns:android="http://schemas.android.com/apk/res/android">
        <uses-permission android:name="android.permission.BLUETOOTH" />
        <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
        <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <manifest xmlns:android="http://schemas.android.com/apk/res/android">
```

## iOS
1. When using the flutter_blue_plus library, you need to add the required permissions to ios/Runner/Info.plist
```
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
        <dict>
            <key>NSBluetoothAlwaysUsageDescription</key>
            <string>Need BLE permission</string>
            <key>NSBluetoothPeripheralUsageDescription</key>
            <string>Need BLE permission</string>
            <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
            <string>Need Location permission</string>
            <key>NSLocationAlwaysUsageDescription</key>
            <string>Need Location permission</string>
            <key>NSLocationWhenInUseUsageDescription</key>
            <string>Need Location permission</string>
        </dict>
    </plist>
```

## Flutter

```mermaid
graph TD
  A[Scan] -->|Filter by Guid F0A0 and FFE0| B(Scan results)
  B --> C{Process scan results}
  C -->|Broadcast Device| D[Parse broadcast data]
  C -->|Connect Device| E[Start connecting]
  E --> |Connection successful|F[Discover BluetoothService]
  E --> |Connection failed|G[Reconnect] --> E
  F --> H[Get BluetoothCharacteristic]
  H --> I[Set notify]
  I --> J[Write instructions via Guid FFE3 and start handshake processing at the same time]
  J --> K[Process the received instructions and perform two-way handshake processing at the same time]
```

1. import AiLink plugin
```
    import 'package:ailink/ailink.dart';
```

2. Plug-in initialization
```
    final _ailinkPlugin = Ailink();
```

### Broadcast Data Encryption and Decryption, and Retrieval of Body Fat Data

1. Decrypt data
```
    _ailinkPlugin.decryptBroadcast(Uint8List)
```

2. Get body fat data
```
    _ailinkPlugin.getBodyFatData(ParamBodyFatData().toJson())
```

3. Get standard weight, weight control, fat mass, lean body mass, muscle mass, protein mass and obesity level.
```dart
    import 'package:ailink/utils/body_data_utils.dart';
    const sex = 1; ///1: male; Others: Female
    const height = 170.0; ///cm
    const weight = 69.20; ///kg
    const bfr = 19.5; ///body fat rate
    const rom = 50.4; ///muscle rate
    const pp = 17.2;  ///protein rate
    final standardWeight = BodyDataUtils.getStandardWeight(sex, height);
    final weightControl = BodyDataUtils.getWeightControl(weight, sex, height);
    final fatMass = BodyDataUtils.getFatMass(weight, bfr);
    final leanBodyMass = BodyDataUtils.getLeanBodyMass(weight, bfr);
    final muscleMass = BodyDataUtils.getMuscleMass(weight, rom);
    final proteinMass = BodyDataUtils.getProteinMass(weight, pp);
    final level = BodyDataUtils.getObesityLevel(weight, sex, height);
```

### Bluetooth Handshake Command Encryption and Decryption

After connecting to the device, two handshakes are required
First call  ```final firstHandShakeData = _ailinkPlugin.initHandShake()``` to obtain handshake instructions
And call ```characteristic.write(firstHandShakeData.toList(), withoutResponse: true)``` to send to the device

After writing, the set handshake instruction ```setHandShakeData``` returned by the device is received.
The second call ```final secondHandShakeData = _ailinkPlugin.getHandShakeEncryptData(Uint8List.fromList(setHandShakeData))```
And call ```characteristic.write(secondHandShakeData.toList(), withoutResponse: true)``` to send to the device
That completes the handshake

1. The app sends this A6 data to actively start handshake with ble, and the return byte[] needs to be sent to ble actively
```
    _ailinkPlugin.initHandShake()
```

2. This method encrypts the A6 data of the ble test app and sends the app to the device, otherwise the device will disconnect the app and return byte[] and need to actively send it to ble
```
    _ailinkPlugin.getHandShakeEncryptData(Uint8List.fromList(data))
```

### Broadcasting Data Parsing: ElinkBleData(cid,vid,pid,mac)
1. Determine whether the device is a broadcast device or a connected device, based on the UUIDs obtained from the broadcast data.
```dart
    final isBroadcastDevice = ElinkBleCommonUtils.isBroadcastDevice(uuids);
```
2. Use the getElinkBleData() method provided in ElinkBroadcastDataUtils to obtain ElinkBleData by passing the broadcast data. Since broadcast device and connected device broadcast data are different, the isBroadcastDevice flag needs to be passed.
```dart
  final isBroadcastDevice = ElinkBleCommonUtils.isBroadcastDevice(uuids);
  final elinkBleData = ElinkBroadcastDataUtils.getElinkBleData(manufacturerData, isBroadcastDevice: isBroadcastDevice);
```

### Elink A7 Data Encryption and Decryption
1. For encryption, pass elinkBleData.macArr, cidArr, and the payload data to be decrypted.
```dart
    final _alink = Ailink();
    final encrypted = await _alink.mcuEncrypt(Uint8List.fromList(elinkbleData.cidArr), Uint8List.fromList(elinkBleData.macArr), Uint8List.fromList(payload));
```
2. For decryption, pass elinkBleData.macArr and the data to be encrypted.
```dart
    final _alink = Ailink();
    final decrypted = await _alink.mcuDecrypt(Uint8List.fromList(elinkBleData.macArr), Uint8List.fromList());
```

### Connected Device Protocol Command Handling
1. Use getElinkA6Data and getElinkA7Data methods in ElinkCmdUtils to obtain A6 and A7 protocol commands.
```dart
    import 'package:ailink/utils/elink_cmd_utils.dart';
    final a6Data = ElinkCmdUtils.getElinkA6Data(payload);
    final a7Data = ElinkCmdUtils.getElinkA7Data(cid, _mac, payload);
```
2. ElinkCmdUtils also provides some commonly used byte manipulation methods.


For specific usage, please see example

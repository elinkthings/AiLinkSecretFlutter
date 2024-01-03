# ailink

A new Flutter plugin project supporting AiLink broadcast scale data analysis.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

1、import AiLink plugin
import 'package:ailink/ailink.dart';

2、Plug-in initialization
final _ailinkPlugin = Ailink();

3、Decrypt data
_ailinkPlugin.decryptBroadcast(Uint8List)

4、Get body fat data
_ailinkPlugin.getBodyFatData(ParamBodyFatData().toJson())

For specific usage, please see example

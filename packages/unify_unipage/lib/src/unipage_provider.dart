import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:unify_unipage/src/costants.dart';

class UniPageProvider extends StatefulWidget {
  const UniPageProvider({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<UniPageProvider> createState() => _UniPageProviderState();
}

class _UniPageProviderState extends State<UniPageProvider> {
  final MethodChannel channel = const MethodChannel(kUniPageChannel);

  @override
  void initState() {
    super.initState();
    channel.setMethodCallHandler((call) async {
      Map<String, dynamic> arguments =
          Map<String, dynamic>.from(call.arguments);
      switch (call.method) {
        case kChannelRoutePushNamed:
          String path = call.arguments[kChannelParamsPath];
          Map<String, dynamic> params =
              Map<String, dynamic>.from(arguments[kChannelParamsPrams]);
          Navigator.of(context).pushNamed(path, arguments: params);
          return true;
        case kChannelRoutePop:
          Map<String, dynamic> params = arguments[kChannelParamsPrams];
          Navigator.of(context).pop(params);
          return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

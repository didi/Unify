const String kUniPageChannel = 'com.didi.unify.uni_page';
const String kChannelRoutePushNamed = 'pushNamed';
const String kChannelRoutePop = 'pop';
const String kChannelInvoke = 'invoke';

const String kChannelParamsPath = 'path';
const String kChannelParamsPrams = 'params';

const String kChannelViewType = 'viewType';
const String kChannelViewId = 'viewId';
const String kChannelMethodName = 'methodName';

String createChannelName(String viewType, int viewId) {
  return '$kUniPageChannel.$viewType.$viewId';
}

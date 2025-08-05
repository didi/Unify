import 'package:unify_flutter/generator/common.dart';
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/extension/string_extension.dart';

const objcPrivateStaticUniDispatchCache =
    'static NSMutableDictionary<NSString *, id> *UniCallbackCache;';

String objcDispatcherClassMethed(String suffix) => '''
+ (void)init:(NSObject<FlutterBinaryMessenger>* _Nonnull)binaryMessenger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UniCallbackCache = NSMutableDictionary.new;
        
        FlutterBasicMessageChannel *channel = [FlutterBasicMessageChannel messageChannelWithName:@"$channelPrefix.UniCallbackManager.callback_channel.dispose$suffix" binaryMessenger: binaryMessenger];
        [channel setMessageHandler:^(id  _Nullable message, FlutterReply  _Nonnull callback) {
            NSString *uniCallbackName = [message objectForKey:@"callback"];
            id subscriber = UniCallbackCache[uniCallbackName];
            if ([subscriber delegate] != NULL && [[subscriber delegate] respondsToSelector:@selector(disposeCallback:)]) {
                [[subscriber delegate] disposeCallback:uniCallbackName];
                [UniCallbackCache removeObjectForKey:uniCallbackName];
            }
        }];
    });
}

+ (void)registe:(NSString * _Nonnull)name callback:(id _Nonnull)subscriber {
    [UniCallbackCache setObject:subscriber forKey:name];
}
''';

String javaDispatcherClassContent(String prefix) => '''
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;

public class $prefix$typeCallbackDispatcher {
    public static Map<String, ${prefix}UniCallback> uniCallbackCache = new HashMap<>();

    private static boolean isInit = false;

    public static void init(BinaryMessenger binaryMessenger) {
        if (!isInit) {
            BasicMessageChannel<Object> channel =
                    new BasicMessageChannel<>(binaryMessenger, "$channelPrefix.UniCallbackManager.callback_channel.dispose${prefix.suffix()}", new StandardMessageCodec());

            channel.setMessageHandler((message, reply) -> {
                Map<String, Object> msg = (Map<String, Object>) message;
                String uniCallbackName = (String) msg.get("callback");
                ${prefix}UniCallback uniCallback = uniCallbackCache.get(uniCallbackName);
                uniCallback.disposeDelegate.disposeCallback(uniCallback);
                uniCallbackCache.remove(uniCallbackName);
            });
            isInit = true;
        }
    }

    public static void registerCallback(String name, ${prefix}UniCallback uniCallback) {
        uniCallbackCache.put(name, uniCallback);
    }
}
''';

String javaUniCallbackDisposeContent(String prefix) => '''
public interface $prefix$typeUniCallbackDispose {
    void disposeCallback(${prefix}UniCallback uniCallback);
}
''';

String javaUniCallbackContent(String prefix) => '''
public class ${prefix}UniCallback {
    public String callbackName;
    public $prefix$typeUniCallbackDispose disposeDelegate;

    public ${prefix}UniCallback(String callbackName, ${prefix}UniCallbackDispose disposeDelegate) {
        this.callbackName = callbackName;
        this.disposeDelegate = disposeDelegate;
    }
}
''';

// =================================================
// Autogenerated from Unify 3.0.0, do not edit directly.
// =================================================

package com.example.unifluttermodule_demo;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import android.util.Log;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import com.example.unifluttermodule_demo.UFUniAPI;
import static com.example.unifluttermodule_demo.uniapi.UniModel.map;
import com.example.unifluttermodule_demo.LocationInfoModel;

public class UniCallbackTestServiceRegister {

    private static List<Object> listClone(List list) {
      List newList = new ArrayList<>();
      for (Object value: list) {
          newList.add(
            value instanceof Map ? mapClone((Map<String, Object>) value) :
            value instanceof List ? listClone((List<Object>) value) :
            value instanceof LocationInfoModel ? ((LocationInfoModel) value).toMap() :
            value
          );
      }
      return newList;
    }
    
    private static  Map<String, Object> mapClone(Map<String, Object> map) {
      Map<String, Object> newDic = new HashMap<String, Object>();
      for(Map.Entry<String, Object> entry : map.entrySet()) {
          Object value = entry.getValue();
          String key = entry.getKey();
          newDic.put(key,
          value instanceof Map ? mapClone((Map<String, Object>) value):
          value instanceof List? listClone((List<Object>) value) :
          value instanceof LocationInfoModel ? ((LocationInfoModel) value).toMap() :
          value);
      }
      return newDic;
    }
    
    private static List listConvert(List list, String[] generics, int depth) {
      List newList = new ArrayList<>();
      for (Object value : list) {
          newList.add(
              generics[depth] == "List" ? listConvert((List<Object>)value, generics, depth+1) :
              generics[depth] == "Map" ? mapConvert((Map<String, Object>)value, generics, depth+1) :
              generics[depth] == "LocationInfoModel" ? LocationInfoModel.fromMap((Map<String, Object>)value) :
              value);
      }
    
      return newList;
    }

    private static Map<String, Object> mapConvert(Map<String, Object> map, String[] generics, int depth) {
      Map<String, Object> newDic = new HashMap<String, Object>();
      for(Map.Entry<String, Object> entry : map.entrySet()) {
          Object value = entry.getValue();
          String key = entry.getKey();
          newDic.put(key,
          generics[depth] == "List" ? listConvert((List<Object>)value, generics, depth+1) :
          generics[depth] == "Map" ? mapConvert((Map<String, Object>)value, generics, depth+1) :
          generics[depth] == "LocationInfoModel" ? LocationInfoModel.fromMap((Map<String, Object>)value) :
          value);
      }
      return  newDic;
    }
    
    public static void setup(BinaryMessenger binaryMessenger, UniCallbackTestService impl) {
        {
            BasicMessageChannel<Object> channel =
                    new BasicMessageChannel<>(binaryMessenger, "com.didi.flutter.uni_api.UniCallbackTestService.doCallbackAction0", new StandardMessageCodec());
            if (impl != null) {
                UFUniAPI.registerModule(impl);
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        Map<String, Object> params = (Map<String, Object>) message;
                        UniCallbackTestService.OnDoCallbackAction0Callback callback = new UniCallbackTestService.OnDoCallbackAction0Callback(binaryMessenger, (String) params.get("callback"));
                        impl.doCallbackAction0(callback);
                        wrapped.put("result", null);
                    } catch (Error | RuntimeException exception) {
                        wrapped.put("error", wrapError(exception));
                        Log.d("flutter", "error: " + exception);
                    } finally {
                        reply.reply(wrapped);
                    }
                });
            } else {
                channel.setMessageHandler((message, reply) -> {});
            }
        }
        {
            BasicMessageChannel<Object> channel =
                    new BasicMessageChannel<>(binaryMessenger, "com.didi.flutter.uni_api.UniCallbackTestService.doCallbackAction1", new StandardMessageCodec());
            if (impl != null) {
                UFUniAPI.registerModule(impl);
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        Map<String, Object> params = (Map<String, Object>) message;
                        UniCallbackTestService.OnDoCallbackAction1Callback callback = new UniCallbackTestService.OnDoCallbackAction1Callback(binaryMessenger, (String) params.get("callback"));
                        impl.doCallbackAction1(callback);
                        wrapped.put("result", null);
                    } catch (Error | RuntimeException exception) {
                        wrapped.put("error", wrapError(exception));
                        Log.d("flutter", "error: " + exception);
                    } finally {
                        reply.reply(wrapped);
                    }
                });
            } else {
                channel.setMessageHandler((message, reply) -> {});
            }
        }
    }

    private static Map<String, Object> wrapError(Throwable exception) {
        Map<String, Object> errorMap = new HashMap<>();
        errorMap.put("message", exception.toString());
        errorMap.put("code", exception.getClass().getSimpleName());
        errorMap.put("details", null);
        return errorMap;
    }
}
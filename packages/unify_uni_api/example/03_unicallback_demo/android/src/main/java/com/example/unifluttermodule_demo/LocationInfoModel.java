// =================================================
// Autogenerated from Unify 3.0.0, do not edit directly.
// =================================================

package com.example.unifluttermodule_demo;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import com.example.unifluttermodule_demo.uniapi.UniModel;

/*
  定位经纬度信息 实体类
*/
public class LocationInfoModel extends UniModel {
    private double lat; // 纬度
    private double lng; // 经度

    public double getLat() { return lat; }

    public void setLat(double lat) { this.lat = lat; }

    public double getLng() { return lng; }

    public void setLng(double lng) { this.lng = lng; }


    @Override
    public Map<String, Object> toMap() {
        Map<String, Object> result = new HashMap<>();
        result.put("lat", lat);
        result.put("lng", lng);
        return result;
    }

    public static LocationInfoModel fromMap(Map<String, Object> map) {
        LocationInfoModel result = new LocationInfoModel();
        result.lat = map.containsKey("lat") && map.get("lat") != null ? (Double) map.get("lat") : 0.0;
        result.lng = map.containsKey("lng") && map.get("lng") != null ? (Double) map.get("lng") : 0.0;
        return result;
    }

}
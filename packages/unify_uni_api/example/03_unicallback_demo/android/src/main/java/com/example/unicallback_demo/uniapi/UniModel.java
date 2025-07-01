package com.example.unicallback_demo.uniapi;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public abstract class UniModel {
  public abstract Map<String, Object> toMap();
  
  public interface Lambda<From, To> {
    To run(From from);
  }

  public static <From, To> List<To> map(List<From> oldList, Lambda<From, To> lambda) {
    List<To> ret = new ArrayList<>();

    if (oldList == null || oldList.isEmpty()) {
      return ret;
    }

    for (From item : oldList) {
      ret.add(lambda.run(item));
    }

    return ret;
  }
}

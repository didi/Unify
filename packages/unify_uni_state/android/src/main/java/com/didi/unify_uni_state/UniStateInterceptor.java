package com.didi.unify_uni_state;

public interface UniStateInterceptor {
    void set(String stateKey, Object stateValue);

    Object get(String stateKey);
}

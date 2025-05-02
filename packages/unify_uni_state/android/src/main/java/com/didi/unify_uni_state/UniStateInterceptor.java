package com.didi.unify_uni_state;

public abstract class UniStateInterceptor {
    public void set(String stateKey, Object stateValue) {}

    public abstract Object get(String stateKey);
}

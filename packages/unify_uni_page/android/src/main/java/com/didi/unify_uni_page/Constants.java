package com.didi.unify_uni_page;

public class Constants {
    public static final String UNI_PAGE_CHANNEL = "com.didi.unify.uni_page";
    public static final String UNI_PAGE_ROUTE_PUSH_NAMED = "pushNamed";
    public static final String UNI_PAGE_ROUTE_POP = "pop";
    public static final String UNI_PAGE_CHANNEL_PARAMS_PATH = "path";
    public static final String UNI_PAGE_CHANNEL_PARAMS_PARAMS = "params";
    public static final String UNI_PAGE_CHANNEL_INVOKE = "invoke";
    public static final String UNI_PAGE_CHANNEL_VIEW_TYPE = "viewType";
    public static final String UNI_PAGE_CHANNEL_VIEW_ID = "viewId";
    public static final String UNI_PAGE_CHANNEL_METHOD_NAME = "methodName";

    public static String createChannelName(String viewType, int viewId) {
        StringBuilder sb = new StringBuilder();
        sb.append(UNI_PAGE_CHANNEL);
        sb.append(".");
        sb.append(viewType);
        sb.append(".");
        sb.append(viewId);
        return sb.toString();
    }
}

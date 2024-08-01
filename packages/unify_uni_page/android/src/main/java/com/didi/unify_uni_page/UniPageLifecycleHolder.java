package com.didi.unify_uni_page;

import android.app.Activity;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Singleton holding current Activity and lifecycle callbacks.
 *
 * @see UniPageLifecycleCallbacks
 */
public final class UniPageLifecycleHolder {
    private static UniPageLifecycleHolder instance;
    private UniPageLifecycleHolder() {

    }
    @NonNull
    public static UniPageLifecycleHolder getInstance() {
        UniPageLifecycleHolder result = instance;
        if (result == null) {
            instance = result = new UniPageLifecycleHolder();
            instance.mUniPageMap = new HashMap<>();
        }
        return result;
    }

    private Activity mCurrentActivity;
    private Map<Activity, List<UniPage>> mUniPageMap;

    public void bindUniPageToCurrentActivity(@NonNull UniPage uniPage) {
        List<UniPage> pageList = mUniPageMap.get(mCurrentActivity);
        if (pageList == null) {
            pageList = new ArrayList<>();
            mUniPageMap.put(mCurrentActivity, pageList);
        }
        if (!pageList.contains(uniPage)) {
            pageList.add(uniPage);
        }
    }

    public void unbindUniPageFromActivity(@NonNull UniPage uniPage) {
        for (List<UniPage> pageList: mUniPageMap.values()) {
            if (pageList.contains(uniPage)) {
                pageList.remove(uniPage);
                return;
            }
        }
    }

    public void unbindActivity(@NonNull Activity activity) {
        mUniPageMap.remove(activity);
        if (mCurrentActivity == activity) {
            mCurrentActivity = null;
        }
    }

    public void notifyOnForeground(@NonNull Activity activity) {
        mCurrentActivity = activity;
        List<UniPage> pageList = mUniPageMap.get(activity);
        if (pageList != null) {
            for (UniPage page : pageList) {
                page.onForeground();
            }
        }
    }

    public void notifyOnBackground(@NonNull Activity activity) {
        List<UniPage> pageList = mUniPageMap.get(activity);
        if (pageList != null) {
            for (UniPage page : pageList) {
                page.onBackground();
            }
        }
    }
}

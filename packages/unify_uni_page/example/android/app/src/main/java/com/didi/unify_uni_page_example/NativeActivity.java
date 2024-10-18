package com.didi.unify_uni_page_example;

import android.app.Activity;
import android.os.Bundle;

import androidx.annotation.Nullable;

public class NativeActivity extends Activity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.uni_page_demo);
    }
}

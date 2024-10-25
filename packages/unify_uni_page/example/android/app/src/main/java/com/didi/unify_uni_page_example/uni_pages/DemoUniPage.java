package com.didi.unify_uni_page_example.uni_pages;

import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.didi.unify_uni_page.UniPage;
import com.didi.unify_uni_page_example.R;

public class DemoUniPage extends UniPage {
    @Override
    public View onCreate() {
        LayoutInflater inflater = LayoutInflater.from(getContext());
        FrameLayout demoLayout = (FrameLayout) inflater.inflate(R.layout.uni_page_demo, null, false);
        TextView demoText = demoLayout.findViewById(R.id.demo_text);
        demoText.setText((String) getCreationParams().get("demoText"));
        return demoLayout;
    }

    @Override
    public void onDispose() {

    }
}

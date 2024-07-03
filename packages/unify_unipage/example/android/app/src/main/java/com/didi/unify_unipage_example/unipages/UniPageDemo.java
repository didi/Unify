package com.didi.unify_unipage_example.unipages;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.didi.unify_unipage.UniPage;

import java.util.HashMap;
import java.util.Map;

public class UniPageDemo extends UniPage {
    public UniPageDemo() {
        Log.d("Maxiee", "UniPageDemo()");
    }

    @Override
    public View onCreate() {
        Log.d("Maxiee", "onCreate()");
        LinearLayout ll = new LinearLayout(getContext());
        ll.setOrientation(LinearLayout.VERTICAL);

        TextView tvTitle = new TextView(getContext());
        tvTitle.setText("I'm a Android Native UniPage");
        ll.addView(tvTitle);

        TextView tvCreateParamsTitle = new TextView(getContext());
        tvCreateParamsTitle.setText("I received following creationParams:");
        ll.addView(tvCreateParamsTitle);

        String words = (String) getCreationParams().get("words");
        TextView tvCreateParamsParams = new TextView(getContext());
        tvCreateParamsParams.setText(words);
        ll.addView(tvCreateParamsParams);

        Button btnPush = new Button(getContext());
        btnPush.setText("Push to Flutter Page with params");
        btnPush.setOnClickListener(v -> {
            Map<String, Object> params = new HashMap<>();
            params.put("hello", "this value is passed from Native UniPage");
            pushNamed("/hello", params);
        });
        ll.addView(btnPush);

        Button btnPop = new Button(getContext());
        btnPop.setText("Pop to previous Flutter page with result");
        btnPop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Map<String, Object> params = new HashMap<>();
                params.put("hello", "this value is passed from Native UniPage");
                pop(params);
            }
        });
        ll.addView(btnPop);

        return ll;
    }

    @Override
    public void onDispose() {
        Log.d("Maxiee", "onDispose()");
    }
}

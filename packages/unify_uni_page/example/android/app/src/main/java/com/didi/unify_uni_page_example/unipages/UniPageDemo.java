package com.didi.unify_uni_page_example.uni_pages;

import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.didi.unify_uni_page.UniPage;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class UniPageDemo extends UniPage {
    TextView tvFlutterUpdate;

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
        btnPop.setOnClickListener(v -> {
            Map<String, Object> params = new HashMap<>();
            params.put("hello", "this value is passed from Native UniPage");
            pop(params);
        });
        ll.addView(btnPop);

        Button btnUpdateTitleBar = new Button(getContext());
        btnUpdateTitleBar.setText("update Flutter titlebar");
        btnUpdateTitleBar.setOnClickListener(view -> {
            HashMap<String, Object> params = new HashMap<>();
            params.put("title", "Updated from native UniPage!");
            invoke("updateTitleBar", params);
        });
        ll.addView(btnUpdateTitleBar);

        tvFlutterUpdate = new TextView(getContext());
        tvFlutterUpdate.setText("");
        ll.addView(tvFlutterUpdate);

        // update Flutter Titlebar directly when onCreate
        HashMap<String, Object> params = new HashMap<>();
        params.put("title", "Updated tilebar na UniPage onCreate");
        invoke("updateTitleBar", params);


        return ll;
    }

    @Override
    public void onMethodCall(String methodName, Map<String, Object> params, MethodChannel.Result result) {
        switch (methodName) {
            case "flutterUpdateTextView":
                String text = (String) params.get("text");
                tvFlutterUpdate.setText(text);
                result.success(true);
                break;
        }
    }

    @Override
    public void onDispose() {
        Log.d("Maxiee", "onDispose()");
    }
}

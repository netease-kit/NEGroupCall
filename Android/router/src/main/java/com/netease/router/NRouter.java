package com.netease.router;

import android.content.Context;
import android.content.Intent;
import android.widget.Toast;

import java.util.HashMap;
import java.util.Map;

public class NRouter {
    private static NRouter instance;

    Map<String, String> router;

    RouterMap routerMap;

    public static NRouter getInstance() {
        if (instance == null) {
            instance = new NRouter();
        }
        return instance;
    }

    private NRouter() {
        router = new HashMap<>();
        routerMap = new RouterMap();

    }

    public void routerTo(Context context, String path) {
        if (router.size() <= 0) {
            router.putAll(routerMap.collectMap(context));
        }
        String toActivity = router.get(path);
        if (toActivity != null) {
            Intent intent = new Intent();
            intent.setClassName(context, toActivity);
            context.startActivity(intent);
        } else {
            Toast.makeText(context, "lib not installed", Toast.LENGTH_SHORT).show();
        }
    }
}

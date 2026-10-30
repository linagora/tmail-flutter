package com.linagora.android.tmail;

import android.app.Activity;
import android.os.Bundle;
import android.os.Looper;
import android.os.SystemClock;
import android.util.Log;
import androidx.test.runner.lifecycle.ActivityLifecycleMonitorRegistry;
import androidx.test.runner.lifecycle.Stage;
import java.util.ArrayList;
import java.util.List;
import pl.leancode.patrol.PatrolJUnitRunner;

// Destroys the activities before the instrumentation ends, so the orchestrator's
// package clear never defers a task kill that hits the next test's process.
public class ActivityDrainingPatrolJUnitRunner extends PatrolJUnitRunner {
    private static final String TAG = "ActivityDrainingRunner";
    private static final long DESTROY_TIMEOUT_MS = 5000;
    private static final long POLL_MS = 50;
    private static final Stage[] ALIVE_STAGES = {
        Stage.PRE_ON_CREATE, Stage.CREATED, Stage.STARTED, Stage.RESUMED,
        Stage.PAUSED, Stage.STOPPED, Stage.RESTARTED,
    };

    @Override
    public void finish(int resultCode, Bundle results) {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            try {
                destroyActivities();
            } catch (RuntimeException e) {
                Log.w(TAG, "Could not destroy activities before finish", e);
            }
        }
        super.finish(resultCode, results);
    }

    private void destroyActivities() {
        final long deadline = SystemClock.uptimeMillis() + DESTROY_TIMEOUT_MS;
        int alive = finishAliveActivities();
        while (alive > 0 && SystemClock.uptimeMillis() < deadline) {
            SystemClock.sleep(POLL_MS);
            alive = finishAliveActivities();
        }
        if (alive == 0) {
            Log.i(TAG, "Activities destroyed before finish");
        } else {
            Log.w(TAG, alive + " activities still alive after " + DESTROY_TIMEOUT_MS + " ms");
        }
    }

    // Returns how many activities were not yet destroyed when this pass started.
    private int finishAliveActivities() {
        final List<Activity> alive = new ArrayList<>();
        runOnMainSync(() -> {
            for (Stage stage : ALIVE_STAGES) {
                alive.addAll(ActivityLifecycleMonitorRegistry.getInstance().getActivitiesInStage(stage));
            }
            for (Activity activity : alive) {
                finishOnce(activity);
            }
        });
        return alive.size();
    }

    private static void finishOnce(Activity activity) {
        if (!activity.isFinishing()) activity.finish();
    }
}

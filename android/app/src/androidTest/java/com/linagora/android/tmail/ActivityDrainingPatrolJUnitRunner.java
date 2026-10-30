package com.linagora.android.tmail;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.util.Log;
import androidx.test.runner.lifecycle.ActivityLifecycleMonitorRegistry;
import androidx.test.runner.lifecycle.Stage;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import pl.leancode.patrol.PatrolJUnitRunner;

// Destroys the activities before the instrumentation ends, so the orchestrator's
// package clear never defers a task kill that hits the next test's process.
public class ActivityDrainingPatrolJUnitRunner extends PatrolJUnitRunner {
    private static final String TAG = "ActivityDrainingRunner";
    private static final long DESTROY_TIMEOUT_MS = 5000;
    private static final long POLL_MS = 50;
    private static final int UNKNOWN = -1;
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
        int alive = finishAliveActivities(deadline);
        while (alive != 0 && SystemClock.uptimeMillis() < deadline) {
            SystemClock.sleep(POLL_MS);
            alive = finishAliveActivities(deadline);
        }
        if (alive == 0) {
            Log.i(TAG, "Activities destroyed before finish");
        } else {
            Log.w(TAG, "Activities still alive or main thread busy after " + DESTROY_TIMEOUT_MS + " ms");
        }
    }

    // Returns how many activities were not yet destroyed when this pass started,
    // or UNKNOWN when the main thread did not run the pass before the deadline.
    private int finishAliveActivities(long deadline) {
        final List<Activity> alive = new ArrayList<>();
        final CountDownLatch done = new CountDownLatch(1);
        new Handler(Looper.getMainLooper()).post(() -> {
            try {
                collectAndFinish(alive);
            } finally {
                done.countDown();
            }
        });
        return awaitPass(done, deadline) ? alive.size() : UNKNOWN;
    }

    private void collectAndFinish(List<Activity> alive) {
        for (Stage stage : ALIVE_STAGES) {
            alive.addAll(ActivityLifecycleMonitorRegistry.getInstance().getActivitiesInStage(stage));
        }
        for (Activity activity : alive) {
            finishOnce(activity);
        }
    }

    private static boolean awaitPass(CountDownLatch done, long deadline) {
        try {
            return done.await(Math.max(deadline - SystemClock.uptimeMillis(), 0), TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return false;
        }
    }

    private static void finishOnce(Activity activity) {
        if (!activity.isFinishing()) activity.finish();
    }
}

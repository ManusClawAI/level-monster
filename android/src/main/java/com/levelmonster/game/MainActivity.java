package com.levelmonster.game;

import org.haxe.lime.GameActivity;
import android.os.Bundle;
import android.view.WindowManager;

/**
 * Main Android Activity for Level Monster.
 * Extends Lime's GameActivity which handles the OpenFL rendering surface.
 */
public class MainActivity extends GameActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Keep screen on during gameplay
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    @Override
    public void onBackPressed() {
        // Forward back button to the engine for handling
        // The engine will handle pause/menu navigation
        super.onBackPressed();
    }
}

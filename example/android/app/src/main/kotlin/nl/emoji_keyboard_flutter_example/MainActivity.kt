package nl.emoji_keyboard_flutter_example

import android.graphics.Paint
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val CHANNEL = "nl.brocast.emoji/available"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method.equals("isAvailable")) {
                val paint = Paint()
                val emojisAvailable: List<String>? = call.argument<List<String>>("emojis")
                val available: MutableList<String> = mutableListOf()
                for (item: String in emojisAvailable!!) {
                    if (paint.hasGlyph(item)) {
                        available.add(item)
                    }
                }
                result.success(available)
            }
        }
    }
}

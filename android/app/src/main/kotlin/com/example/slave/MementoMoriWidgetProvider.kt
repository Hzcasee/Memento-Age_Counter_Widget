package com.example.slave

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Calendar

class MementoMoriWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.memento_widget_layout)

            // Saved from Dart as a String (see _pushToHomeScreenWidget in
            // main.dart) because home_widget's platform channel rejects
            // large 64-bit Long values directly.
            val birthMillis = widgetData.getString("birth_date_millis", null)?.toLongOrNull()

            if (birthMillis == null) {
                views.setTextViewText(R.id.widget_value, "--.--.--")
            } else {
                views.setTextViewText(R.id.widget_value, formatAge(birthMillis))
            }

            // Tapping anywhere on the widget opens the app.
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    /**
     * Calendar-accurate Years.Months.Days between the stored birthdate and
     * now. Mirrors the logic in the Flutter app's _calculateAge, minus the
     * time-of-day component (not shown on the home screen widget).
     */
    private fun formatAge(birthMillis: Long): String {
        val birth = Calendar.getInstance().apply { timeInMillis = birthMillis }
        val now = Calendar.getInstance()

        var years = now.get(Calendar.YEAR) - birth.get(Calendar.YEAR)
        var months = now.get(Calendar.MONTH) - birth.get(Calendar.MONTH)
        var days = now.get(Calendar.DAY_OF_MONTH) - birth.get(Calendar.DAY_OF_MONTH)

        if (days < 0) {
            val prevMonth = Calendar.getInstance().apply {
                timeInMillis = now.timeInMillis
                add(Calendar.MONTH, -1)
            }
            days += prevMonth.getActualMaximum(Calendar.DAY_OF_MONTH)
            months--
        }
        if (months < 0) {
            months += 12
            years--
        }

        return "$years.$months.$days"
    }
}
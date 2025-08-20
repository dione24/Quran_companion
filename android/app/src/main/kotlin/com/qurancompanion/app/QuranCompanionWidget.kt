package com.qurancompanion.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.Intent
import android.app.PendingIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class QuranCompanionWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.quran_companion_widget).apply {
                
                val arabicText = widgetData.getString("arabic_text", "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                val translation = widgetData.getString("translation", "Au nom d'Allah, le Tout Miséricordieux, le Très Miséricordieux")
                val reference = widgetData.getString("reference", "Al-Fatiha 1")
                
                setTextViewText(R.id.arabic_text, arabicText)
                setTextViewText(R.id.translation_text, translation)
                setTextViewText(R.id.reference_text, reference)
                
                // Set click intent to open app
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
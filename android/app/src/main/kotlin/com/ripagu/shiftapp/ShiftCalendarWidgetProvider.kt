package com.ripagu.shiftapp

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.text.TextPaint
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import kotlin.math.max

class ShiftCalendarWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) {
            renderWidget(context, appWidgetManager, id)
        }
    }

    private fun renderWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
    ) {
        val payload = loadPayload(context)
        val bitmap = drawWidgetBitmap(payload)

        val views = RemoteViews(context.packageName, R.layout.shift_calendar_widget)
        views.setImageViewBitmap(R.id.widget_canvas, bitmap)

        // 위젯 탭 시 앱 실행.
        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
        if (launchIntent != null) {
            val pi = PendingIntent.getActivity(
                context, 0, launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_canvas, pi)
        }

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun loadPayload(context: Context): WidgetPayload? {
        // home_widget 플러그인이 사용하는 SharedPreferences 파일/키
        val prefs = context.getSharedPreferences(
            "HomeWidgetPreferences", Context.MODE_PRIVATE,
        )
        val json = prefs.getString("payload", null) ?: return null
        return try {
            WidgetPayload.fromJson(JSONObject(json))
        } catch (e: Exception) {
            null
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        // home_widget.updateWidget() 호출 시 ACTION_APPWIDGET_UPDATE 가
        // 명시적 컴포넌트로 전달되므로 onUpdate 가 자연 호출됨.
        // 추가 처리 불필요.
    }
}

// ───────────────────────────────────────────────────────────────────────
// Payload model
// ───────────────────────────────────────────────────────────────────────

private data class ShiftDef(
    val key: String,
    val short: String,
    val name: String,
    val solid: Int,
    val soft: Int,
)

private data class WidgetPayload(
    val anchorDate: String,
    val cycle: List<String>,
    val overrides: Map<String, String>,
    val shifts: Map<String, ShiftDef>,
    val holidays: Set<String>,
) {
    companion object {
        fun fromJson(j: JSONObject): WidgetPayload {
            val anchor = j.optString("anchorDate", "")
            val cycleJson = j.optJSONArray("cycle")
            val cycle = mutableListOf<String>()
            if (cycleJson != null) {
                for (i in 0 until cycleJson.length()) {
                    cycle.add(cycleJson.optString(i, ""))
                }
            }
            val overridesJson = j.optJSONObject("overrides")
            val overrides = mutableMapOf<String, String>()
            if (overridesJson != null) {
                for (k in overridesJson.keys()) {
                    overrides[k] = overridesJson.optString(k, "")
                }
            }
            val shiftsJson = j.optJSONObject("shifts")
            val shifts = mutableMapOf<String, ShiftDef>()
            if (shiftsJson != null) {
                for (k in shiftsJson.keys()) {
                    val s = shiftsJson.optJSONObject(k) ?: continue
                    shifts[k] = ShiftDef(
                        key = s.optString("key", k),
                        short = s.optString("short", "?"),
                        name = s.optString("name", ""),
                        solid = parseHex(s.optString("solid", "#8B95A1")),
                        soft = parseHex(s.optString("soft", "#ECEEF1")),
                    )
                }
            }
            val holidaysJson = j.optJSONArray("holidays")
            val holidays = mutableSetOf<String>()
            if (holidaysJson != null) {
                for (i in 0 until holidaysJson.length()) {
                    holidays.add(holidaysJson.optString(i, ""))
                }
            }
            return WidgetPayload(anchor, cycle, overrides, shifts, holidays)
        }
    }
}

// "#RRGGBB" → ARGB int (alpha 0xFF)
private fun parseHex(hex: String): Int {
    val s = hex.removePrefix("#")
    return try {
        val v = s.toLong(16).toInt()
        0xFF000000.toInt() or (v and 0xFFFFFF)
    } catch (_: Exception) {
        0xFF8B95A1.toInt()
    }
}

// ───────────────────────────────────────────────────────────────────────
// Fallback shifts — Flutter 가 shifts dict 를 안 보낼 때 (또는 알 수 없는 키)
// ───────────────────────────────────────────────────────────────────────

private val fallbackShifts: Map<String, ShiftDef> = mapOf(
    "day" to ShiftDef("day", "주", "주간", 0xFF3182F6.toInt(), 0xFFE8F2FE.toInt()),
    "night" to ShiftDef("night", "야", "야간", 0xFF5A4FCF.toInt(), 0xFFEDEBFB.toInt()),
    "duty" to ShiftDef("duty", "당", "당직", 0xFFF04452.toInt(), 0xFFFCE4E6.toInt()),
    "off" to ShiftDef("off", "비", "비번", 0xFF8B95A1.toInt(), 0xFFECEEF1.toInt()),
    "holiday" to ShiftDef("holiday", "휴", "휴무", 0xFFF77F36.toInt(), 0xFFFEEEDF.toInt()),
)

private fun resolveShift(code: String, payload: WidgetPayload?): ShiftDef? {
    payload?.shifts?.get(code)?.let { return it }
    return fallbackShifts[code]
}

// ───────────────────────────────────────────────────────────────────────
// Cycle math
// ───────────────────────────────────────────────────────────────────────

private val dateFmt: SimpleDateFormat by lazy {
    SimpleDateFormat("yyyy-MM-dd", Locale.US).apply { timeZone = TimeZone.getDefault() }
}

private fun parseDateKey(s: String): Date? = try {
    dateFmt.parse(s)
} catch (_: Exception) {
    null
}

private fun toDateKey(cal: Calendar): String {
    val y = cal.get(Calendar.YEAR)
    val m = cal.get(Calendar.MONTH) + 1
    val d = cal.get(Calendar.DAY_OF_MONTH)
    return "%04d-%02d-%02d".format(y, m, d)
}

private fun daysBetween(a: Calendar, b: Calendar): Int {
    val ms = 24L * 60 * 60 * 1000
    fun startOfDayUTC(c: Calendar): Long {
        val gc = Calendar.getInstance(TimeZone.getDefault())
        gc.set(c.get(Calendar.YEAR), c.get(Calendar.MONTH), c.get(Calendar.DAY_OF_MONTH), 0, 0, 0)
        gc.set(Calendar.MILLISECOND, 0)
        return gc.timeInMillis
    }
    return ((startOfDayUTC(b) - startOfDayUTC(a)) / ms).toInt()
}

private fun shiftFor(date: Calendar, payload: WidgetPayload): String {
    val key = toDateKey(date)
    payload.overrides[key]?.let { return it }
    val anchor = parseDateKey(payload.anchorDate) ?: return "off"
    if (payload.cycle.isEmpty()) return "off"
    val anchorCal = Calendar.getInstance().apply { time = anchor }
    val diff = daysBetween(anchorCal, date)
    val n = payload.cycle.size
    val idx = ((diff % n) + n) % n
    return payload.cycle[idx]
}

// ───────────────────────────────────────────────────────────────────────
// Canvas rendering — iOS 위젯과 픽셀-단위 동일.
// ───────────────────────────────────────────────────────────────────────

// 색상 토큰 (iOS 위젯과 일치)
private const val COLOR_BG = 0xFFF2F4F6.toInt()
private const val COLOR_TEXT_PRIMARY = 0xFF191F28.toInt()
private const val COLOR_TEXT_SECONDARY = 0xFF6B7884.toInt()
private const val COLOR_TEXT_TERTIARY = 0xFF8B95A1.toInt()
private const val COLOR_RED_WEEKEND = 0xFFF04452.toInt()
private const val COLOR_BLUE_WEEKEND = 0xFF3182F6.toInt()

// 캔버스 해상도. ImageView 가 fitCenter 로 스케일링.
private const val CANVAS_W = 600
private const val CANVAS_H = 600

private fun drawWidgetBitmap(payload: WidgetPayload?): Bitmap {
    val bitmap = Bitmap.createBitmap(CANVAS_W, CANVAS_H, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)

    // 배경 (rounded — iOS 17 containerBackground 대응)
    val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = COLOR_BG }
    val cornerR = 48f
    canvas.drawRoundRect(
        RectF(0f, 0f, CANVAS_W.toFloat(), CANVAS_H.toFloat()),
        cornerR, cornerR, bgPaint,
    )

    val padding = 28f
    val innerW = CANVAS_W - padding * 2
    val innerH = CANVAS_H - padding * 2

    val today = Calendar.getInstance()
    val year = today.get(Calendar.YEAR)
    val month = today.get(Calendar.MONTH) // 0-based
    val todayDay = today.get(Calendar.DAY_OF_MONTH)

    // ── Header: "M월 YYYY" ─────────────────────────────────────────
    val monthPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
        color = COLOR_TEXT_PRIMARY
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        textSize = 32f
        textAlign = Paint.Align.LEFT
    }
    val yearPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
        color = COLOR_TEXT_SECONDARY
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
        textSize = 22f
        textAlign = Paint.Align.LEFT
    }
    val monthText = "${month + 1}월"
    val yearText = year.toString()
    val headerY = padding + 28f
    canvas.drawText(monthText, padding, headerY, monthPaint)
    val monthW = monthPaint.measureText(monthText)
    canvas.drawText(yearText, padding + monthW + 10f, headerY, yearPaint)

    val headerBottom = padding + 44f

    // ── Weekday row ────────────────────────────────────────────────
    val weekdays = listOf("일", "월", "화", "수", "목", "금", "토")
    val weekdayPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        textSize = 18f
        textAlign = Paint.Align.CENTER
    }
    val cellW = innerW / 7f
    val weekdayY = headerBottom + 18f
    for (i in 0..6) {
        weekdayPaint.color = when (i) {
            0 -> COLOR_RED_WEEKEND
            6 -> COLOR_BLUE_WEEKEND
            else -> COLOR_TEXT_TERTIARY
        }
        val cx = padding + cellW * i + cellW / 2f
        canvas.drawText(weekdays[i], cx, weekdayY, weekdayPaint)
    }

    val gridTop = weekdayY + 16f
    val gridBottom = padding + innerH
    val rowH = (gridBottom - gridTop) / 6f

    // ── Cells (6 rows x 7 cols) ────────────────────────────────────
    val firstOfMonth = Calendar.getInstance().apply {
        set(year, month, 1, 0, 0, 0)
        set(Calendar.MILLISECOND, 0)
    }
    val firstWeekday = (firstOfMonth.get(Calendar.DAY_OF_WEEK) - 1) // Sun=0

    for (row in 0..5) {
        for (col in 0..6) {
            val idx = row * 7 + col
            val cell = Calendar.getInstance().apply {
                time = firstOfMonth.time
                add(Calendar.DAY_OF_MONTH, idx - firstWeekday)
            }
            val cellMonth = cell.get(Calendar.MONTH)
            val cellDay = cell.get(Calendar.DAY_OF_MONTH)
            val inMonth = cellMonth == month
            val isToday = inMonth && cellDay == todayDay

            val cellX = padding + cellW * col
            val cellY = gridTop + rowH * row

            val weekday = cell.get(Calendar.DAY_OF_WEEK) - 1
            val isHoliday = payload?.holidays?.contains(toDateKey(cell)) == true
            val dayColor = when {
                isToday -> 0xFFFFFFFF.toInt()
                !inMonth -> argbWithAlpha(
                    if (isHoliday) COLOR_RED_WEEKEND else COLOR_TEXT_TERTIARY,
                    0.5f,
                )

                isHoliday -> COLOR_RED_WEEKEND
                weekday == 0 -> COLOR_RED_WEEKEND
                weekday == 6 -> COLOR_BLUE_WEEKEND
                else -> COLOR_TEXT_PRIMARY
            }

            // Day number (with optional today circle)
            val dayCenterX = cellX + cellW / 2f
            val dayCenterY = cellY + 18f
            if (isToday) {
                val circlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = COLOR_BLUE_WEEKEND
                }
                canvas.drawCircle(dayCenterX, dayCenterY - 6f, 16f, circlePaint)
            }
            val dayPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
                color = dayColor
                typeface = Typeface.create(
                    Typeface.DEFAULT,
                    if (isToday) Typeface.BOLD else Typeface.NORMAL,
                )
                textSize = 22f
                textAlign = Paint.Align.CENTER
            }
            canvas.drawText(cellDay.toString(), dayCenterX, dayCenterY, dayPaint)

            // Shift badge (only in-month)
            if (inMonth && payload != null) {
                val code = shiftFor(cell, payload)
                val shift = resolveShift(code, payload)
                if (shift != null) {
                    val badgeTop = cellY + 32f
                    val badgeBottom = badgeTop + 24f
                    val badgeLeft = cellX + 4f
                    val badgeRight = cellX + cellW - 4f
                    val badgePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = shift.soft
                    }
                    canvas.drawRoundRect(
                        RectF(badgeLeft, badgeTop, badgeRight, badgeBottom),
                        8f, 8f, badgePaint,
                    )
                    val shortPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = shift.solid
                        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                        textSize = 17f
                        textAlign = Paint.Align.CENTER
                    }
                    val baseline = badgeTop + 17f
                    canvas.drawText(shift.short, dayCenterX, baseline, shortPaint)
                }
            }
        }
    }

    return bitmap
}

private fun argbWithAlpha(color: Int, alpha: Float): Int {
    val a = max(0, min255((alpha * 255f).toInt()))
    return (a shl 24) or (color and 0x00FFFFFF)
}

private fun min255(v: Int): Int = if (v > 255) 255 else v

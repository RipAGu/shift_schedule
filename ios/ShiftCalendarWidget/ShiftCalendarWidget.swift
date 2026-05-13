import WidgetKit
import SwiftUI

// MARK: - Constants

private let appGroup = "group.com.ripagu.shiftapp"
private let payloadKey = "payload"

// MARK: - Payload model

struct ShiftDef: Codable {
    let key: String
    let short: String
    let name: String
    let solid: String  // "#RRGGBB"
    let soft: String
}

struct WidgetPayload: Codable {
    let anchorDate: String              // "YYYY-MM-DD"
    let cycle: [String]                 // ["day", "day", "night", ...]
    let overrides: [String: String]     // { "YYYY-MM-DD": "night" }
    let shifts: [String: ShiftDef]?     // optional — Flutter 가 매번 같이 전송
}

// MARK: - Shift visuals

private struct Shift {
    let code: String
    let short: String
    let name: String
    let solid: Color
    let soft: Color
}

// Flutter 에서 shifts 사전을 보내주지 않은 경우(이전 버전 호환)를 위한 폴백.
private let fallbackShifts: [String: Shift] = [
    "day": Shift(code: "day", short: "주", name: "주간",
                 solid: Color(red: 0.192, green: 0.510, blue: 0.965),
                 soft:  Color(red: 0.910, green: 0.949, blue: 0.996)),
    "night": Shift(code: "night", short: "야", name: "야간",
                 solid: Color(red: 0.353, green: 0.310, blue: 0.812),
                 soft:  Color(red: 0.929, green: 0.922, blue: 0.984)),
    "duty": Shift(code: "duty", short: "당", name: "당직",
                 solid: Color(red: 0.941, green: 0.267, blue: 0.322),
                 soft:  Color(red: 0.988, green: 0.894, blue: 0.902)),
    "off": Shift(code: "off", short: "비", name: "비번",
                 solid: Color(red: 0.545, green: 0.584, blue: 0.631),
                 soft:  Color(red: 0.925, green: 0.933, blue: 0.945)),
    "holiday": Shift(code: "holiday", short: "휴", name: "휴무",
                 solid: Color(red: 0.969, green: 0.498, blue: 0.212),
                 soft:  Color(red: 0.996, green: 0.933, blue: 0.875)),
]

private func hexColor(_ hex: String) -> Color {
    var s = hex
    if s.hasPrefix("#") { s.removeFirst() }
    guard s.count == 6, let v = UInt32(s, radix: 16) else { return Color.gray }
    let r = Double((v >> 16) & 0xFF) / 255.0
    let g = Double((v >> 8) & 0xFF) / 255.0
    let b = Double(v & 0xFF) / 255.0
    return Color(red: r, green: g, blue: b)
}

private func resolveShift(_ code: String, payload: WidgetPayload?) -> Shift? {
    if let p = payload, let def = p.shifts?[code] {
        return Shift(code: def.key, short: def.short, name: def.name,
                     solid: hexColor(def.solid), soft: hexColor(def.soft))
    }
    return fallbackShifts[code]
}

private let bgColor = Color(red: 0.949, green: 0.957, blue: 0.965)   // #F2F4F6
private let textPrimary = Color(red: 0.098, green: 0.122, blue: 0.157) // #191F28
private let textSecondary = Color(red: 0.420, green: 0.471, blue: 0.529) // #6B7684
private let textTertiary = Color(red: 0.545, green: 0.584, blue: 0.631) // #8B95A1
private let redWeekend = Color(red: 0.941, green: 0.267, blue: 0.322)  // #F04452
private let blueWeekend = Color(red: 0.192, green: 0.510, blue: 0.965) // #3182F6

// MARK: - Cycle math

private func parseDateKey(_ s: String) -> Date? {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    f.timeZone = TimeZone.current
    return f.date(from: s)
}

private func dateKey(_ d: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    f.timeZone = TimeZone.current
    return f.string(from: d)
}

private func shiftFor(date: Date, payload: WidgetPayload) -> String {
    if let override = payload.overrides[dateKey(date)] {
        return override
    }
    guard let anchor = parseDateKey(payload.anchorDate),
          !payload.cycle.isEmpty else {
        return "off"
    }
    let cal = Calendar(identifier: .gregorian)
    let a = cal.startOfDay(for: anchor)
    let d = cal.startOfDay(for: date)
    let diff = cal.dateComponents([.day], from: a, to: d).day ?? 0
    let n = payload.cycle.count
    let idx = ((diff % n) + n) % n
    return payload.cycle[idx]
}

// MARK: - Timeline

struct ShiftCalendarEntry: TimelineEntry {
    let date: Date
    let payload: WidgetPayload?
}

struct ShiftCalendarProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShiftCalendarEntry {
        ShiftCalendarEntry(date: Date(), payload: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (ShiftCalendarEntry) -> Void) {
        completion(ShiftCalendarEntry(date: Date(), payload: loadPayload()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShiftCalendarEntry>) -> Void) {
        let entry = ShiftCalendarEntry(date: Date(), payload: loadPayload())
        let cal = Calendar.current
        let nextMidnight = cal.date(byAdding: .day, value: 1,
                                    to: cal.startOfDay(for: Date())) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }

    private func loadPayload() -> WidgetPayload? {
        guard let suite = UserDefaults(suiteName: appGroup),
              let jsonString = suite.string(forKey: payloadKey),
              let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(WidgetPayload.self, from: data)
    }
}

// MARK: - View

struct ShiftCalendarWidgetView: View {
    let entry: ShiftCalendarEntry

    var body: some View {
        let today = entry.date
        let cal = Calendar(identifier: .gregorian)
        let year = cal.component(.year, from: today)
        let month = cal.component(.month, from: today)

        let firstOfMonth = cal.date(from: DateComponents(year: year, month: month, day: 1))!
        let firstWeekday = cal.component(.weekday, from: firstOfMonth) - 1 // Sun=0
        let cells: [Date] = (0..<42).map { i in
            cal.date(byAdding: .day, value: i - firstWeekday, to: firstOfMonth)!
        }

        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .lastTextBaseline) {
                Text("\(month)월")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textPrimary)
                Text("\(String(year))")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(textSecondary)
                Spacer()
            }
            .padding(.bottom, 8)

            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    Text(["일","월","화","수","목","금","토"][i])
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(weekdayColor(i))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            ForEach(0..<6, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<7, id: \.self) { col in
                        let day = cells[row * 7 + col]
                        let inMonth = cal.component(.month, from: day) == month
                        let isToday = cal.isDate(day, inSameDayAs: today)
                        let shiftCode = entry.payload != nil
                            ? shiftFor(date: day, payload: entry.payload!)
                            : "off"
                        CellView(day: day,
                                 inMonth: inMonth,
                                 isToday: isToday,
                                 shiftCode: entry.payload != nil ? shiftCode : nil,
                                 payload: entry.payload)
                    }
                }
                if row < 5 { Spacer(minLength: 2) }
            }
        }
        .padding(14)
    }

    private func weekdayColor(_ idx: Int) -> Color {
        if idx == 0 { return redWeekend }
        if idx == 6 { return blueWeekend }
        return textTertiary
    }
}


// MARK: - Cell

private struct CellView: View {
    let day: Date
    let inMonth: Bool
    let isToday: Bool
    let shiftCode: String?
    let payload: WidgetPayload?

    var body: some View {
        let cal = Calendar(identifier: .gregorian)
        let dayNum = cal.component(.day, from: day)
        let weekday = cal.component(.weekday, from: day) - 1
        let shift = shiftCode.flatMap { resolveShift($0, payload: payload) }

        let dayColor: Color = {
            if isToday { return .white }
            if !inMonth { return textTertiary.opacity(0.5) }
            if weekday == 0 { return redWeekend }
            if weekday == 6 { return blueWeekend }
            return textPrimary
        }()

        VStack(spacing: 2) {
            ZStack {
                if isToday {
                    Circle()
                        .fill(blueWeekend)
                        .frame(width: 18, height: 18)
                }
                Text("\(dayNum)")
                    .font(.system(size: 11, weight: isToday ? .bold : .semibold))
                    .foregroundColor(dayColor)
            }
            .frame(height: 18)

            if inMonth, let s = shift {
                Text(s.short)
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(s.solid)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 1)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(s.soft)
                    )
            } else {
                Spacer().frame(height: 12)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Widget definition

struct ShiftCalendarWidget: Widget {
    let kind: String = "ShiftCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShiftCalendarProvider()) { entry in
            if #available(iOS 17.0, *) {
                ShiftCalendarWidgetView(entry: entry)
                    .containerBackground(bgColor, for: .widget)
            } else {
                ShiftCalendarWidgetView(entry: entry)
                    .background(bgColor)
            }
        }
        .configurationDisplayName("교대근무 캘린더")
        .description("이번 달 근무 일정을 한눈에 봐요")
        .supportedFamilies([.systemLarge])  // 4x4
    }
}

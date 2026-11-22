import SwiftUI

enum TeaBase: String, CaseIterable, Identifiable {
    case greenTea = "翠玉綠茶"
    case blackTea = "熟成紅茶"
    case oolong = "炭焙烏龍"
    case freshMilk = "濃醇鮮奶"

    var id: String { rawValue }

    var basePrice: Int {
        switch self {
        case .greenTea: 35
        case .blackTea: 35
        case .oolong: 40
        case .freshMilk: 55
        }
    }

    var baseCalories: Int {
        switch self {
        case .greenTea: 10
        case .blackTea: 15
        case .oolong: 15
        case .freshMilk: 160
        }
    }

    var defaultTopColor: Color {
        switch self {
        case .greenTea: Color(red: 0.72, green: 0.88, blue: 0.56)
        case .blackTea: Color(red: 0.72, green: 0.36, blue: 0.18)
        case .oolong: Color(red: 0.65, green: 0.45, blue: 0.24)
        case .freshMilk: Color(red: 0.98, green: 0.96, blue: 0.90)
        }
    }

    var defaultBottomColor: Color {
        switch self {
        case .greenTea: Color(red: 0.48, green: 0.72, blue: 0.34)
        case .blackTea: Color(red: 0.45, green: 0.18, blue: 0.08)
        case .oolong: Color(red: 0.40, green: 0.24, blue: 0.10)
        case .freshMilk: Color(red: 0.89, green: 0.84, blue: 0.75)
        }
    }
}

enum CupSize: String, CaseIterable, Identifiable {
    case medium = "中杯"
    case large = "大杯"
    case jumbo = "重量杯"

    var id: String { rawValue }

    var priceAdjustment: Int {
        switch self {
        case .medium: 0
        case .large: 10
        case .jumbo: 25
        }
    }

    var calorieMultiplier: Double {
        switch self {
        case .medium: 1.0
        case .large: 1.3
        case .jumbo: 1.7
        }
    }

    var previewScale: CGFloat {
        switch self {
        case .medium: 0.86
        case .large: 0.95
        case .jumbo: 1.05
        }
    }
}

struct DrinkOrder {
    var drinkName = ""
    var customerLastName = ""

    var teaBase: TeaBase = .blackTea
    var cupSize: CupSize = .large

    var sweetness: Double = 50
    var iceLevel: Double = 50

    var bobaCount = 1
    var coconutJellyCount = 0
    var puddingCount = 0

    var hasCheeseFoam = false
    var hasEcoCup = false

    var topColor: Color = TeaBase.blackTea.defaultTopColor
    var bottomColor: Color = TeaBase.blackTea.defaultBottomColor
    var stickerBgColor = Color(red: 1.0, green: 0.94, blue: 0.72)

    var pickupDate: Date = .now.addingTimeInterval(15 * 60)
    var note = ""

    var trimmedDrinkName: String {
        drinkName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedCustomerLastName: String {
        customerLastName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedNote: String {
        note.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var totalToppings: Int {
        bobaCount + coconutJellyCount + puddingCount
    }

    var totalPrice: Int {
        let base = teaBase.basePrice + cupSize.priceAdjustment
        let toppings = bobaCount * 10 + coconutJellyCount * 10 + puddingCount * 15
        let foam = hasCheeseFoam ? 20 : 0
        let ecoDiscount = hasEcoCup ? -5 : 0
        return max(0, base + toppings + foam + ecoDiscount)
    }

    var totalCalories: Int {
        let baseCal = Double(teaBase.baseCalories) * cupSize.calorieMultiplier
        let sugarCal = (sweetness / 100.0) * 240.0 * cupSize.calorieMultiplier
        let toppingsCal = Double(bobaCount * 160 + coconutJellyCount * 90 + puddingCount * 180)
        let foamCal = hasCheeseFoam ? 250.0 : 0.0
        return Int((baseCal + sugarCal + toppingsCal + foamCal).rounded())
    }

    var sweetnessLabel: String {
        let percent = Int(sweetness)
        return switch percent {
        case 0: "無糖 (0%)"
        case 10...30: "微糖 (\(percent)%)"
        case 40...60: "半糖 (\(percent)%)"
        case 70...90: "少糖 (\(percent)%)"
        default: "全糖螞蟻人 (100%)"
        }
    }

    var iceLabel: String {
        let percent = Int(iceLevel)
        return switch percent {
        case 0: "完全去冰 (0%)"
        case 1...35: "微冰 (\(percent)%)"
        case 36...70: "少冰 (\(percent)%)"
        default: "正常冰 (\(percent)%)"
        }
    }

    var tastinessStars: Int {
        var score = 4

        if totalToppings > 6 {
            score -= 2
        } else if totalToppings > 4 {
            score -= 1
        }

        if sweetness == 100 && hasCheeseFoam { score -= 1 }
        if teaBase == .freshMilk && hasCheeseFoam && sweetness == 0 { score -= 1 }
        if totalToppings == 0 && sweetness == 0 && !hasCheeseFoam { score = 3 }
        if (30...70).contains(Int(sweetness)) && (1...3).contains(totalToppings) { score = 5 }

        return min(5, max(1, score))
    }

    var tastinessStarsText: String {
        String(repeating: "★", count: tastinessStars) + String(repeating: "☆", count: 5 - tastinessStars)
    }

    var formattedPickupTime: String {
        pickupDate.formatted(
            .verbatim(
                "\(month: .twoDigits)/\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
                timeZone: .current,
                calendar: .current
            )
        )
    }

    var toppingsSummary: String {
        var parts: [String] = []
        if bobaCount > 0 { parts.append("珍珠×\(bobaCount)") }
        if coconutJellyCount > 0 { parts.append("椰果×\(coconutJellyCount)") }
        if puddingCount > 0 { parts.append("布丁×\(puddingCount)") }
        if hasCheeseFoam { parts.append("厚奶蓋") }
        return parts.isEmpty ? "無加料" : parts.joined(separator: "、")
    }
}

struct DrinkPreset: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let apply: (inout DrinkOrder) -> Void

    static let allPresets: [DrinkPreset] = [
        DrinkPreset(title: "全糖去冰肥宅快樂水", icon: "flame.fill") { order in
            order.drinkName = "肥宅快樂特調"
            order.teaBase = .blackTea
            order.cupSize = .jumbo
            order.sweetness = 100
            order.iceLevel = 0
            order.bobaCount = 3
            order.coconutJellyCount = 2
            order.puddingCount = 2
            order.hasCheeseFoam = true
            order.topColor = Color(red: 0.78, green: 0.34, blue: 0.16)
            order.bottomColor = Color(red: 0.38, green: 0.14, blue: 0.06)
        },
        DrinkPreset(title: "健身魔人無糖特調", icon: "figure.run") { order in
            order.drinkName = "自律純茶"
            order.teaBase = .greenTea
            order.cupSize = .medium
            order.sweetness = 0
            order.iceLevel = 25
            order.bobaCount = 0
            order.coconutJellyCount = 0
            order.puddingCount = 0
            order.hasCheeseFoam = false
            order.hasEcoCup = true
            order.topColor = TeaBase.greenTea.defaultTopColor
            order.bottomColor = TeaBase.greenTea.defaultBottomColor
        },
        DrinkPreset(title: "實驗室神秘漸層", icon: "flask.fill") { order in
            order.drinkName = "暗黑宇宙星雲"
            order.teaBase = .oolong
            order.cupSize = .large
            order.sweetness = 50
            order.iceLevel = 50
            order.bobaCount = 1
            order.coconutJellyCount = 2
            order.puddingCount = 0
            order.hasCheeseFoam = true
            order.topColor = Color(red: 0.62, green: 0.32, blue: 0.88)
            order.bottomColor = Color(red: 0.18, green: 0.76, blue: 0.82)
            order.stickerBgColor = Color(red: 0.94, green: 0.86, blue: 1.0)
        }
    ]
}

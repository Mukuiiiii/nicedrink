import Foundation

// MARK: - 評價分類

enum DrinkReviewCategory: CaseIterable {
    case highCalories
    case tooManyToppings
    case sugarBomb
    case ultraHealthy
    case creamyDessert
    case goldenRatio
    case experimental
}

enum DrinkReviewGenerator {
        static func matchingCategories(for order: DrinkOrder) -> [DrinkReviewCategory] {
        var categories: [DrinkReviewCategory] = []

        if order.totalCalories >= 1000 {
            categories.append(.highCalories)
        }
        if order.totalToppings >= 6 {
            categories.append(.tooManyToppings)
        }
        if order.sweetness == 100 && order.iceLevel == 0 {
            categories.append(.sugarBomb)
        }
        if order.sweetness == 0 && order.totalToppings == 0 && !order.hasCheeseFoam {
            categories.append(.ultraHealthy)
        }
        if order.hasCheeseFoam && order.puddingCount >= 2 {
            categories.append(.creamyDessert)
        }
        if order.tastinessStars == 5 && order.totalCalories < 1000 {
            categories.append(.goldenRatio)
        }

        return categories.isEmpty ? [.experimental] : categories
    }

    static func randomReview(for order: DrinkOrder) -> String {
        let category = matchingCategories(for: order).randomElement() ?? .experimental
        return reviews(for: category, order: order).randomElement()
            ?? "實驗室系統暫時當機，但這杯「\(order.trimmedDrinkName)」看起來相當有挑戰性。"
    }

    private static func reviews(for category: DrinkReviewCategory, order: DrinkOrder) -> [String] {
        let drinkName = order.trimmedDrinkName
        let customer = order.trimmedCustomerLastName

        return switch category {
        case .highCalories:
            [
                "⚠️ 警告！這杯高達 \(order.totalCalories) 大卡，確定要喝嗎？喝完建議直接跑一場半馬贖罪。",
                "🚨 實驗室警報大作！\(order.totalCalories) 大卡已經超越一整個雞腿便當，體重計正在角落發抖。",
                "🔥 這杯「\(drinkName)」自帶 \(order.totalCalories) 大卡核融合能量，喝完大概可以直接冬眠三天。",
                "💀 \(order.totalCalories) kcal 的罪惡深淵，店員封膜的時候手都在抖，祝你的代謝系統好運。"
            ]

        case .tooManyToppings:
            [
                "這已經不是飲料，是一碗裝在杯子裡的八寶粥吧？店員吸管都要插不進去了。",
                "總共加了 \(order.totalToppings) 份料，茶底只是用來潤滑配料的配角，建議直接改附湯匙。",
                "搖飲料時聽起來像在搖沙鈴，這杯喝完咀嚼肌會直接升級成職業健美等級。",
                "這杯的固體比例嚴重超標，喝完不用吃晚餐，下巴還順便做完一組重訓。",
                "下個配料該不會是四十一號混泥土吧。"
            ]

        case .sugarBomb:
            [
                "全糖又去冰，毫無稀釋空間的純粹糖漿炸彈，胰島素正在發出求救訊號。",
                "100% 甜度配 0% 冰塊，連路過的螞蟻看到都會起立鼓掌、尊稱你一聲教主。",
                "這已經不是手搖飲，是液態方糖濃縮液，喝一口靈魂直接甜到升天。",
                "零冰塊的濃稠全糖衝擊，牙醫診所已自動為 \(customer) 先生/小姐保留下週掛號名額。"
            ]

        case .ultraHealthy:
            [
                "無糖無料又純粹，健身房教練看到都會感動流淚的自律聖品。",
                "清淡到幾乎能喝出禪意，這杯「\(drinkName)」散發著滿滿的養生仙氣。",
                "零糖零料零奶蓋，全實驗室最理智的訂單，店員搖起來毫無心理負擔。",
                "如此克制的配方，確定沒有走錯棚來到暗黑特調實驗室嗎？"
            ]

        case .creamyDessert:
            [
                "厚奶蓋配雙倍布丁，滑順到可以直接當正餐吃，熱量表已經放棄計算你的體脂。",
                "奶蓋加上 \(order.puddingCount) 顆布丁，這根本是披著手搖飲外皮的豪華法式甜點杯。",
                "一口吸上來全是濃郁奶香與滑嫩布丁，罪惡感與幸福感同時突破天際。",
                "濃稠到快要用挖的才吃得到，這杯「\(drinkName)」已經正式跨足下午茶蛋糕界。"
            ]

        case .goldenRatio:
            [
                "黃金比例！這杯「\(drinkName)」意外地很合理，店員甚至想自己偷留一杯。",
                "甜度與配料拿捏得恰到好處，堪稱暗黑實驗室裡難得一見的正常美味奇蹟。",
                "五星級神級特調誕生！\(customer) 先生/小姐根本是被耽誤的手搖飲研發總監。",
                "這配方平衡得無懈可擊，建議直接列入本店隱藏菜單，明天就會開始排隊。"
            ]

        case .experimental:
            [
                "有點奇特但還算能入口的實驗室配方，祝你好運，\(customer) 先生/小姐。",
                "這杯「\(drinkName)」散發著微妙的實驗氣息，喝之前建議先深呼吸並懷抱敬畏之心。",
                "配方走向相當跳脫常理，店員一邊調一邊露出了困惑又敬佩的眼神。",
                "介於神作與暗黑料理之間的薛丁格手搖飲，只有喝下第一口才知道答案。"
            ]
        }
    }
}

# 奇葩手搖飲／暗黑特調實驗室 (SwiftUI)

依照「[233 結合各種輸入元件 & 顯示 alert 的 SwiftUI / UIKit / Flutter App](https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84%E8%A9%A6%E7%85%89-%E5%8B%87%E8%80%85%E7%9A%84-100-%E9%81%93-swift-ios-app-%E8%AC%8E%E9%A1%8C/233-%E7%B5%90%E5%90%88%E5%90%84%E7%A8%AE%E8%BC%B8%E5%85%A5%E5%85%83%E4%BB%B6-%E9%A1%AF%E7%A4%BA-alert-%E7%9A%84-swiftui-uikit-flutter-app-0b742250143d)」設計的 SwiftUI 專案。

## 檔案說明

- `DrinkModels.swift`：茶底、杯型、訂單資料模型、金額/熱量/好喝指數計算與毒舌評語邏輯，以及 `.contextMenu` 預設配方。
- `DrinkPreviewCard.swift`：頂部即時手搖杯視覺預覽卡片（含漸層飲料、奶蓋、冰塊、配料、客製照片貼紙與長按 `.contextMenu`）。
- `ContentView.swift`：主表單頁面，整合所有輸入元件與 `Alert` 結算互動。

## 涵蓋的輸入元件與互動

1. **TextField**：特調命名、顧客姓氏（含鍵盤「完成」收合按鈕）。
2. **Picker / SegmentedControl**：茶底選單、杯型分段選擇。
3. **Slider**：甜度（0%～100%）、冰塊（0%～100%）。
4. **Stepper**：珍珠、椰果、布丁份數加減。
5. **Toggle**：加厚芝士奶蓋、自備環保杯折抵。
6. **ColorPicker**：飲料上/下漸層色、貼紙底色。
7. **PhotosPicker (`PhotosUI`)**：上傳相簿照片作為客製杯身貼紙。
8. **DatePicker**：預約自取日期與時間。
9. **TextEditor**：給店員的奇葩備註（附 Placeholder）。
10. **contextMenu**：長按上方飲料預覽杯身，一鍵套用預設暗黑配方或隨機生成。
11. **Alert**：未填必填欄位時跳出提醒；送出時顯示總金額、高熱量警告與毒舌評語，並提供「狠心下單 / 我再改一下」雙按鈕。

## 如何在 Xcode 中使用

1. 在 Mac 上打開 Xcode，建立一個新的 **iOS App** 專案（Interface 選 **SwiftUI**，Deployment Target 建議 **iOS 16.0+**）。
2. 將 `DrinkModels.swift`、`DrinkPreviewCard.swift`、`ContentView.swift` 拖入專案中取代原本的 `ContentView.swift`。
3. 執行 Simulator 或實機即可測試（`PhotosPicker` 在模擬器中亦可直接選取內建測試相片）。

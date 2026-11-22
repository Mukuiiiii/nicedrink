import PhotosUI
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var order = DrinkOrder()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var stickerImage: UIImage?

    @State private var validationErrorMessage: String?
    @State private var isShowingConfirmation = false
    @State private var isShowingOrderSubmitted = false
    @State private var currentReview = ""
    @FocusState private var isTextInputFocused: Bool

    private var teaBaseBinding: Binding<TeaBase> {
        Binding(
            get: { order.teaBase },
            set: { newBase in
                order.teaBase = newBase
                order.topColor = newBase.defaultTopColor
                order.bottomColor = newBase.defaultBottomColor
            }
        )
    }

    private var isShowingValidationError: Binding<Bool> {
        Binding(
            get: { validationErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    validationErrorMessage = nil
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DrinkPreviewCard(
                    order: $order,
                    stickerImage: stickerImage,
                    onRandomize: randomizeOrder
                )
                Form {
                    basicInfoSection
                    baseAndSizeSection
                    sweetnessAndIceSection
                    toppingsSection
                    customizationSection
                    pickupAndNoteSection
                    actionSection
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("暗黑特調實驗室")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完成") {
                        isTextInputFocused = false
                    }
                }
            }
            .task(id: selectedPhotoItem) {
                guard let selectedPhotoItem,
                      let data = try? await selectedPhotoItem.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    return
                }
                stickerImage = image
            }
            .alert(
                "資料還沒填完喔！",
                isPresented: isShowingValidationError,
                presenting: validationErrorMessage
            ) { _ in
                Button("回去補填", role: .cancel) {}
            } message: { message in
                Text(message)
            }
            .alert(
                order.totalCalories >= 1000 ? "⚠️ 高熱量暗黑警報" : "🧪 特調實驗室結算",
                isPresented: $isShowingConfirmation
            ) {
                Button("我再改一下", role: .cancel) {}
                Button("狠心下單", role: .destructive) {
                    isShowingOrderSubmitted = true
                }
            } message: {
                Text(confirmationMessage)
            }
            .alert("下單成功！", isPresented: $isShowingOrderSubmitted) {
                Button("太棒了", role: .cancel) {}
            } message: {
                Text("店員正在含淚調製您的「\(order.trimmedDrinkName)」，請於 \(order.formattedPickupTime) 準時取餐。")
            }
        }
    }

    // MARK: - Form Sections

    private var basicInfoSection: some View {
        Section("1. 特調檔案") {
            TextField("為這杯特調命名（例如：深夜罪惡感）", text: $order.drinkName)
                .focused($isTextInputFocused)

            TextField("顧客姓氏（例如：陳）", text: $order.customerLastName)
                .focused($isTextInputFocused)
        }
    }

    private var baseAndSizeSection: some View {
        Section("2. 基底與杯型") {
            Picker("選擇茶底", selection: teaBaseBinding) {
                ForEach(TeaBase.allCases) { base in
                    Text("\(base.rawValue) ($\(base.basePrice))").tag(base)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("杯型選擇")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Picker("杯型", selection: $order.cupSize) {
                    ForEach(CupSize.allCases) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var sweetnessAndIceSection: some View {
        Section("3. 甜度與冰塊") {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("甜度")
                    Spacer()
                    Text(order.sweetnessLabel)
                        .foregroundStyle(.secondary)
                }
                Slider(value: $order.sweetness, in: 0...100, step: 10)
                    .tint(.pink)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("冰塊")
                    Spacer()
                    Text(order.iceLabel)
                        .foregroundStyle(.secondary)
                }
                Slider(value: $order.iceLevel, in: 0...100, step: 25)
                    .tint(.cyan)
            }
        }
    }

    private var toppingsSection: some View {
        Section("4. 罪惡配料與加購") {
            Stepper("波霸珍珠（+10元）：\(order.bobaCount) 份", value: $order.bobaCount, in: 0...5)
            Stepper("Q彈椰果（+10元）：\(order.coconutJellyCount) 份", value: $order.coconutJellyCount, in: 0...5)
            Stepper("統一布丁（+15元）：\(order.puddingCount) 顆", value: $order.puddingCount, in: 0...3)

            Toggle("加厚芝士奶蓋（+20元 / +250 kcal）", isOn: $order.hasCheeseFoam)
            Toggle("自備環保杯（折抵 5 元）", isOn: $order.hasEcoCup)
        }
    }

    private var customizationSection: some View {
        Section("5. 夢幻漸層與客製貼紙") {
            ColorPicker("飲料上層顏色", selection: $order.topColor, supportsOpacity: false)
            ColorPicker("飲料下層顏色", selection: $order.bottomColor, supportsOpacity: false)
            ColorPicker("杯身貼紙底色", selection: $order.stickerBgColor, supportsOpacity: false)

            HStack {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label(
                        stickerImage == nil ? "上傳客製杯身貼紙 / 梗圖" : "更換杯身貼紙照片",
                        systemImage: "photo.on.rectangle.angled"
                    )
                }
                .buttonStyle(.borderless)

                Spacer()

                if stickerImage != nil {
                    Button("移除", role: .destructive) {
                        stickerImage = nil
                        selectedPhotoItem = nil
                    }
                    .font(.caption)
                    .buttonStyle(.borderless)
                }
            }
        }
    }

    private var pickupAndNoteSection: some View {
        Section("6. 自取時間與奇葩備註") {
            DatePicker(
                "預約自取時間",
                selection: $order.pickupDate,
                in: Date.now...,
                displayedComponents: [.date, .hourAndMinute]
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("給店員的備註")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField(
                    "例如：珍珠要幫我一顆一顆數好、搖飲料時請順時針搖 17 下...",
                    text: $order.note,
                    axis: .vertical
                )
                .lineLimit(3...6)
                .focused($isTextInputFocused)
            }
        }
    }

    private var actionSection: some View {
        Section {
            Button {
                submitOrder()
            } label: {
                Text("送出暗黑訂單（NT$\(order.totalPrice)）")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            HStack {
                Button("隨機暗黑特調") {
                    withAnimation {
                        randomizeOrder()
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderless)

                Divider()

                Button("重設配方", role: .destructive) {
                    withAnimation {
                        resetOrder()
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderless)
            }
        }
    }

    private var confirmationMessage: String {
        let noteText = order.trimmedNote.isEmpty ? "無" : order.trimmedNote
        return """
        顧客：\(order.trimmedCustomerLastName) 先生/小姐
        特調：\(order.trimmedDrinkName)（\(order.cupSize.rawValue) \(order.teaBase.rawValue)）
        規格：\(order.sweetnessLabel) / \(order.iceLabel)
        配料：\(order.toppingsSummary)
        自取：\(order.formattedPickupTime)
        備註：\(noteText)

        💰 總金額：NT$\(order.totalPrice)
        🔥 總熱量：\(order.totalCalories) kcal
        ⭐ 好喝指數：\(order.tastinessStarsText)

        💬 實驗室毒舌評語：
        \(currentReview)
        """
    }

    private func submitOrder() {
        isTextInputFocused = false

        if order.trimmedDrinkName.isEmpty {
            validationErrorMessage = "請先為這杯暗黑特調取個名字！"
            return
        }
        if order.trimmedCustomerLastName.isEmpty {
            validationErrorMessage = "請輸入顧客姓氏，店員才知道要叫誰取餐！"
            return
        }

        currentReview = DrinkReviewGenerator.randomReview(for: order)
        isShowingConfirmation = true
    }

    private func randomizeOrder() {
        let names = ["暗黑破壞神", "老闆的眼淚", "深夜肥宅夢", "肝指數特調", "紫色神秘藥水"]
        order.drinkName = names.randomElement() ?? "神秘特調"
        order.teaBase = TeaBase.allCases.randomElement() ?? .blackTea
        order.cupSize = CupSize.allCases.randomElement() ?? .large
        order.sweetness = Double([0, 30, 50, 70, 100].randomElement() ?? 50)
        order.iceLevel = Double([0, 25, 50, 75, 100].randomElement() ?? 50)
        order.bobaCount = Int.random(in: 0...4)
        order.coconutJellyCount = Int.random(in: 0...3)
        order.puddingCount = Int.random(in: 0...2)
        order.hasCheeseFoam = Bool.random()
        order.topColor = Color(
            red: .random(in: 0.2...0.95),
            green: .random(in: 0.2...0.95),
            blue: .random(in: 0.2...0.95)
        )
        order.bottomColor = Color(
            red: .random(in: 0.15...0.85),
            green: .random(in: 0.15...0.85),
            blue: .random(in: 0.15...0.85)
        )
    }

    private func resetOrder() {
        order = DrinkOrder()
        stickerImage = nil
        selectedPhotoItem = nil
    }
}

#Preview {
    ContentView()
}

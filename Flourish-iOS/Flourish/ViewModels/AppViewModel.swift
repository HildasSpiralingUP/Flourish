import Foundation
import Observation

@Observable
final class AppViewModel {

    // MARK: - Onboarding
    var hasAcceptedDisclaimer: Bool = false

    // MARK: - Navigation
    var selectedTab: Tab = .nursery
    var skyMode: SkyMode = .day
    var isMeditating: Bool = false

    enum Tab: String, CaseIterable {
        case nursery, garden, coins, shop, health
        var label: String { rawValue.capitalized }
        var icon: String {
            switch self {
            case .nursery: return "🪴"
            case .garden:  return "🌳"
            case .coins:   return "🪙"
            case .shop:    return "🛒"
            case .health:  return "💪"
            }
        }
    }

    // MARK: - Stats
    var coins: Int = 80
    var pendingSteps: Int = 0   // steps not yet converted
    var syncedSteps: Int = 0    // from HealthKit
    var waterGlasses: Int = 0
    let waterGoal: Int = 8

    // MARK: - Nursery
    var pots: [Pot] = [
        Pot(type: .daisy),
        Pot(type: .cactus),
    ]
    var selectedSeedType: PlantType = .daisy

    // MARK: - Garden
    var gardenItems: [GardenItem] = []

    // MARK: - Health
    var weightLog: [WeightEntry] = [
        WeightEntry(date: date(-8), value: 186),
        WeightEntry(date: date(-6), value: 185),
        WeightEntry(date: date(-4), value: 184),
        WeightEntry(date: date(-2), value: 183),
    ]

    // MARK: - Toast
    var toastMessage: String? = nil
    var toastEmoji: String = "🌱"

    // MARK: - Affirmation
    let todayAffirmation: String = affirmations.randomElement()!
    var showAffirmation: Bool = true

    // MARK: - Services
    var audioManager = AudioManager()
    var healthKitService = HealthKitService()

    // MARK: - Computed
    var readyPots: [Pot]   { pots.filter(\.isReady) }
    var growingPots: [Pot] { pots.filter { !$0.isReady } }

    // MARK: - Init
    init() {
        load()
        Task { await refreshSteps() }
    }

    // MARK: - Actions

    func convertSteps() {
        guard pendingSteps >= 100 else {
            showToast("Walk more to earn coins!", emoji: "👟")
            return
        }
        let earned = pendingSteps / 100
        coins += earned
        distributeToAllPots(steps: pendingSteps, water: 0)
        pendingSteps = 0
        audioManager.playCoins()
        showToast("+\(earned) coins earned!", emoji: "🪙")
        save()
    }

    func addWaterGlass() {
        guard waterGlasses < waterGoal else {
            showToast("Daily goal reached! 🎉", emoji: "💧")
            return
        }
        waterGlasses += 1
        distributeToAllPots(steps: 0, water: 1)
        audioManager.playWater()
        showToast("\(waterGlasses)/\(waterGoal) glasses today", emoji: "💧")
        save()
    }

    func startPot(type: PlantType) {
        if type.coinCost > 0 {
            guard coins >= type.coinCost else {
                showToast("Not enough coins!", emoji: "🪙")
                return
            }
            coins -= type.coinCost
        }
        pots.append(Pot(type: type))
        audioManager.playPlant()
        showToast("\(type.name) seedling started!", emoji: "🌱")
        save()
    }

    func transplantPot(_ pot: Pot) {
        let px = Double.random(in: 0.1...0.85)
        let py = Double.random(in: 0.15...0.80)
        gardenItems.append(GardenItem(
            content: .plant(pot.type),
            xFraction: px,
            yFraction: py
        ))
        pots.removeAll { $0.id == pot.id }
        audioManager.playPlant()
        showToast("\(pot.type.name) planted in your garden!", emoji: "🌳")
        selectedTab = .garden
        save()
    }

    func removePot(_ pot: Pot) {
        pots.removeAll { $0.id == pot.id }
        save()
    }

    func placeDeco(_ deco: DecorationID) {
        let def = deco.definition
        guard coins >= def.cost else {
            showToast("Not enough coins!", emoji: "🪙")
            return
        }
        coins -= def.cost
        let px = Double.random(in: 0.1...0.85)
        let py = Double.random(in: 0.15...0.80)
        gardenItems.append(GardenItem(
            content: .decoration(deco),
            xFraction: px,
            yFraction: py
        ))
        audioManager.playChime()
        showToast("\(def.name) placed!", emoji: def.emoji)
        selectedTab = .garden
        save()
    }

    func moveGardenItem(id: UUID, xFraction: Double, yFraction: Double) {
        guard let idx = gardenItems.firstIndex(where: { $0.id == id }) else { return }
        gardenItems[idx].xFraction = xFraction
        gardenItems[idx].yFraction = yFraction
    }

    func logWeight(_ value: Double) {
        weightLog.append(WeightEntry(date: Date(), value: value))
        showToast("Weight logged!", emoji: "⚖️")
        save()
    }

    // MARK: - HealthKit

    func refreshSteps() async {
        do {
            try await healthKitService.requestAuthorization()
            let steps = try await healthKitService.todayStepCount()
            await MainActor.run {
                syncedSteps = steps
                pendingSteps = steps
            }
        } catch {
            // HealthKit unavailable in simulator or denied — keep mock value
            await MainActor.run {
                if syncedSteps == 0 {
                    syncedSteps = 4_200
                    pendingSteps = 4_200
                }
            }
        }
    }

    // MARK: - Toast

    func showToast(_ message: String, emoji: String = "🌱") {
        toastEmoji = emoji
        toastMessage = message
        Task {
            try? await Task.sleep(for: .seconds(2.8))
            await MainActor.run { toastMessage = nil }
        }
    }

    // MARK: - Persistence

    private let potsKey        = "flourish.pots"
    private let gardenKey      = "flourish.garden"
    private let coinsKey       = "flourish.coins"
    private let waterKey       = "flourish.water"
    private let weightKey      = "flourish.weight"
    private let disclaimerKey  = "flourish.disclaimer"
    private let skyKey         = "flourish.sky"

    func save() {
        let enc = JSONEncoder()
        UserDefaults.standard.set(try? enc.encode(pots),        forKey: potsKey)
        UserDefaults.standard.set(try? enc.encode(gardenItems), forKey: gardenKey)
        UserDefaults.standard.set(try? enc.encode(weightLog),   forKey: weightKey)
        UserDefaults.standard.set(coins,                        forKey: coinsKey)
        UserDefaults.standard.set(waterGlasses,                 forKey: waterKey)
        UserDefaults.standard.set(hasAcceptedDisclaimer,        forKey: disclaimerKey)
        UserDefaults.standard.set(skyMode.rawValue,             forKey: skyKey)
    }

    private func load() {
        let dec = JSONDecoder()
        let ud  = UserDefaults.standard

        if let data = ud.data(forKey: potsKey),
           let saved = try? dec.decode([Pot].self, from: data) {
            pots = saved
        }
        if let data = ud.data(forKey: gardenKey),
           let saved = try? dec.decode([GardenItem].self, from: data) {
            gardenItems = saved
        }
        if let data = ud.data(forKey: weightKey),
           let saved = try? dec.decode([WeightEntry].self, from: data) {
            weightLog = saved
        }
        coins             = ud.integer(forKey: coinsKey)
        waterGlasses      = ud.integer(forKey: waterKey)
        hasAcceptedDisclaimer = ud.bool(forKey: disclaimerKey)
        if let raw = ud.string(forKey: skyKey), let mode = SkyMode(rawValue: raw) {
            skyMode = mode
        }
        // Default coins for fresh install
        if coins == 0 && !ud.bool(forKey: "flourish.launched") {
            coins = 80
            ud.set(true, forKey: "flourish.launched")
        }
    }

    // MARK: - Helpers

    private func distributeToAllPots(steps: Int, water: Int) {
        for i in pots.indices {
            pots[i].stepsAccumulated += steps
            pots[i].waterAccumulated += water
        }
        save()
    }
}

private func date(_ daysFromNow: Int) -> Date {
    Calendar.current.date(byAdding: .day, value: daysFromNow, to: Date()) ?? Date()
}

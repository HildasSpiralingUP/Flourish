import Foundation

// MARK: - Plant

enum PlantType: String, CaseIterable, Codable, Identifiable {
    case daisy, tulip, cactus, sunflower, rose, blossom, tree

    var id: String { rawValue }

    var name: String {
        switch self {
        case .daisy:     return "Daisy"
        case .tulip:     return "Tulip"
        case .cactus:    return "Cactus"
        case .sunflower: return "Sunflower"
        case .rose:      return "Rose"
        case .blossom:   return "Cherry Blossom"
        case .tree:      return "Oak Tree"
        }
    }

    var stages: [String] {
        switch self {
        case .daisy:     return ["🌱","🌿","🌼","🌼"]
        case .tulip:     return ["🌱","🌿","🌷","🌷"]
        case .cactus:    return ["🌱","🌱","🌵","🌵"]
        case .sunflower: return ["🌱","🌿","🌻","🌻"]
        case .rose:      return ["🌱","🌿","🥀","🌹"]
        case .blossom:   return ["🌱","🌿","🌸","🌸"]
        case .tree:      return ["🌱","🌿","🌳","🌲"]
        }
    }

    var stepsRequired: Int {
        switch self {
        case .daisy:     return 2_000
        case .tulip:     return 3_000
        case .cactus:    return 1_500
        case .sunflower: return 5_000
        case .rose:      return 6_000
        case .blossom:   return 8_000
        case .tree:      return 15_000
        }
    }

    var waterRequired: Int {
        switch self {
        case .daisy:     return 3
        case .tulip:     return 4
        case .cactus:    return 1
        case .sunflower: return 6
        case .rose:      return 8
        case .blossom:   return 10
        case .tree:      return 20
        }
    }

    var coinCost: Int {
        switch self {
        case .daisy, .tulip, .cactus: return 0
        case .sunflower: return 80
        case .rose:      return 100
        case .blossom:   return 150
        case .tree:      return 200
        }
    }

    var description: String {
        switch self {
        case .daisy:     return "A cheerful starter bloom."
        case .tulip:     return "Classic and elegant."
        case .cactus:    return "Low maintenance, high spirit."
        case .sunflower: return "Follows the sun, just like you."
        case .rose:      return "Worth every single step."
        case .blossom:   return "Rare and breathtaking."
        case .tree:      return "A true achievement. Mighty & proud."
        }
    }

    var fullGrowthEmoji: String { stages[3] }

    func emoji(forGrowth growth: Double) -> String {
        stages[growthStage(growth)]
    }

    func growthStage(_ growth: Double) -> Int {
        if growth < 0.25 { return 0 }
        if growth < 0.50 { return 1 }
        if growth < 0.85 { return 2 }
        return 3
    }
}

// MARK: - Pot

struct Pot: Identifiable, Codable {
    var id: UUID = UUID()
    var type: PlantType
    var stepsAccumulated: Int = 0
    var waterAccumulated: Int = 0

    var growth: Double {
        let stepFraction = min(Double(stepsAccumulated) / Double(type.stepsRequired), 1.0)
        let waterFraction = min(Double(waterAccumulated) / Double(type.waterRequired), 1.0)
        return min(stepFraction, waterFraction)
    }

    var isReady: Bool { growth >= 1.0 }

    var currentEmoji: String { type.emoji(forGrowth: growth) }
    var currentStage: Int { type.growthStage(growth) }

    var stepFraction: Double { min(Double(stepsAccumulated) / Double(type.stepsRequired), 1.0) }
    var waterFraction: Double { min(Double(waterAccumulated) / Double(type.waterRequired), 1.0) }

    var limitingFactor: LimitingFactor? {
        if stepFraction < waterFraction { return .steps }
        if waterFraction < stepFraction { return .water }
        return nil
    }

    enum LimitingFactor { case steps, water }
}

// MARK: - Garden Item

enum GardenItemContent: Codable {
    case plant(PlantType)
    case decoration(DecorationID)
}

struct GardenItem: Identifiable, Codable {
    var id: UUID = UUID()
    var content: GardenItemContent
    var xFraction: Double  // 0–1 relative to canvas width
    var yFraction: Double  // 0–1 relative to canvas height

    var emoji: String {
        switch content {
        case .plant(let type):      return type.fullGrowthEmoji
        case .decoration(let did):  return did.definition.emoji
        }
    }
}

// MARK: - Decoration

enum DecorationID: String, CaseIterable, Codable, Identifiable {
    case mushroom, butterfly, lantern, bench, pond, gnome, rainbow, well, fountain, house, windmill, treehouse

    var id: String { rawValue }

    var definition: DecorationDef { DecorationDef.all[self]! }
}

struct DecorationDef {
    let name: String
    let emoji: String
    let cost: Int

    static let all: [DecorationID: DecorationDef] = [
        .mushroom:  .init(name:"Mushroom",      emoji:"🍄",  cost:50),
        .butterfly: .init(name:"Butterfly",     emoji:"🦋",  cost:80),
        .lantern:   .init(name:"Lantern",       emoji:"🏮",  cost:120),
        .bench:     .init(name:"Garden Bench",  emoji:"🪑",  cost:180),
        .pond:      .init(name:"Lily Pond",     emoji:"🪷",  cost:250),
        .gnome:     .init(name:"Garden Gnome",  emoji:"🧙",  cost:300),
        .rainbow:   .init(name:"Rainbow",       emoji:"🌈",  cost:400),
        .well:      .init(name:"Wishing Well",  emoji:"⛲",  cost:500),
        .fountain:  .init(name:"Fountain",      emoji:"⛲",  cost:550),
        .house:     .init(name:"Tiny House",    emoji:"🏡",  cost:600),
        .windmill:  .init(name:"Windmill",      emoji:"🎡",  cost:700),
        .treehouse: .init(name:"Tree House",    emoji:"🏚",  cost:800),
    ]
}

// MARK: - Sky / Time of Day

enum SkyMode: String, CaseIterable, Codable {
    case day, afternoon, sunset, night

    var displayName: String {
        switch self {
        case .day:       return "Day"
        case .afternoon: return "Afternoon"
        case .sunset:    return "Sunset"
        case .night:     return "Night"
        }
    }

    var icon: String {
        switch self {
        case .day:       return "☀️"
        case .afternoon: return "🌤"
        case .sunset:    return "🌅"
        case .night:     return "🌙"
        }
    }

    var skyTop: String {
        switch self {
        case .day:       return "#87CEEB"
        case .afternoon: return "#FFD89B"
        case .sunset:    return "#ff7e5f"
        case .night:     return "#0f2027"
        }
    }

    var isNight: Bool { self == .night }
}

// MARK: - Weight Log

struct WeightEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var value: Double  // lbs
}

// MARK: - Affirmations

let affirmations: [String] = [
    "Every step you take is a step toward the best version of you. 💪",
    "You are stronger than yesterday. Keep going! 🌟",
    "Your body is capable of amazing things. Trust the process. 🌱",
    "Small consistent actions lead to extraordinary results. ✨",
    "You deserve to feel good in your body. Today is a great day to start. 🌸",
    "Progress, not perfection. You are doing wonderfully. 🦋",
    "Your health is your greatest wealth. Invest in yourself today. 💚",
    "Drink water, take steps, grow something beautiful. That is all it takes. 🌿",
]

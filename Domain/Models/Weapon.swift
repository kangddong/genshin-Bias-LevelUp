import Foundation

struct Weapon: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let rarity: Int
    let image: String
    let imageAlternatives: [String]?
    let localImage: String?
    let type: WeaponType
    let materialId: String

    init(
        id: String,
        name: String,
        rarity: Int,
        image: String = "",
        imageAlternatives: [String]? = nil,
        localImage: String? = nil,
        type: WeaponType,
        materialId: String
    ) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.image = image
        self.imageAlternatives = imageAlternatives
        self.localImage = localImage
        self.type = type
        self.materialId = materialId
    }

    var imageCandidates: [String] {
        var values = [image]
        if let imageAlternatives {
            values.append(contentsOf: imageAlternatives)
        }

        var seen = Set<String>()
        return values.filter { value in
            guard !value.isEmpty else { return false }
            return seen.insert(value).inserted
        }
    }
}

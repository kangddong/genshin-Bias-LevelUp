import Foundation

struct Character: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let image: String
    let imageAlternatives: [String]?
    let localImage: String?
    let name: String
    let element: ElementType
    let nation: NationType
    let materialId: String

    init(
        id: String,
        image: String,
        imageAlternatives: [String]? = nil,
        localImage: String? = nil,
        name: String,
        element: ElementType,
        nation: NationType,
        materialId: String
    ) {
        self.id = id
        self.image = image
        self.imageAlternatives = imageAlternatives
        self.localImage = localImage
        self.name = name
        self.element = element
        self.nation = nation
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

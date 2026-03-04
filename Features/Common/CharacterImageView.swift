import SwiftUI

struct CharacterImageView: View {
    enum PlaceholderStyle {
        case character
        case symbol(String)
    }

    let localImagePath: String?
    let imageURLs: [String]
    let size: CGFloat
    let placeholderStyle: PlaceholderStyle

    init(imageURL: String, size: CGFloat) {
        self.localImagePath = nil
        self.imageURLs = [imageURL]
        self.size = size
        self.placeholderStyle = .character
    }

    init(imageURLs: [String], size: CGFloat) {
        self.localImagePath = nil
        self.imageURLs = imageURLs
        self.size = size
        self.placeholderStyle = .character
    }

    init(localImagePath: String?, imageURLs: [String], size: CGFloat, placeholderStyle: PlaceholderStyle = .character) {
        self.localImagePath = localImagePath
        self.imageURLs = imageURLs
        self.size = size
        self.placeholderStyle = placeholderStyle
    }

    var body: some View {
        placeholder
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }

    private var placeholder: some View {
        ZStack {
            Color(.secondarySystemBackground)
            switch placeholderStyle {
            case .character:
                Image(systemName: "person.crop.square")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.2)
                    .foregroundStyle(.secondary)
            case .symbol(let systemName):
                Image(systemName: systemName)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

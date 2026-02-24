import SwiftUI
import UIKit

struct CharacterImageView: View {
    let localImagePath: String?
    let imageURLs: [String]
    let size: CGFloat
    @StateObject private var loader = CharacterImageLoader()

    init(imageURL: String, size: CGFloat) {
        self.localImagePath = nil
        self.imageURLs = [imageURL]
        self.size = size
    }

    init(imageURLs: [String], size: CGFloat) {
        self.localImagePath = nil
        self.imageURLs = imageURLs
        self.size = size
    }

    init(localImagePath: String?, imageURLs: [String], size: CGFloat) {
        self.localImagePath = localImagePath
        self.imageURLs = imageURLs
        self.size = size
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .task(id: [localImagePath ?? "", imageURLs.joined(separator: "|")].joined(separator: "::")) {
            await loader.load(localImagePath: localImagePath, urlStrings: imageURLs)
        }
    }

    private var placeholder: some View {
        ZStack {
            Color(.secondarySystemBackground)
            if let paimon = Self.paimonPlaceholder {
                Image(uiImage: paimon)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private static let paimonPlaceholder: UIImage? = {
        guard let base = Bundle.main.resourceURL else { return nil }
        let url = base.appendingPathComponent("Images/placeholders/paimon.png")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }()
}

@MainActor
private final class CharacterImageLoader: ObservableObject {
    @Published var image: UIImage?

    private static let memoryCache = NSCache<NSURL, UIImage>()
    private static let resolvedURLCache = NSCache<NSString, NSURL>()
    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024,
            diskPath: "character-image-cache"
        )
        return URLSession(configuration: config)
    }()

    func load(localImagePath: String?, urlStrings: [String]) async {
        if let localImagePath, let localImage = loadLocalImage(path: localImagePath) {
            image = localImage
            return
        }

        let urls = urlStrings.compactMap { normalizedURL(from: $0) }
        guard let firstURL = urls.first else {
            image = nil
            return
        }

        let firstKey = NSString(string: firstURL.absoluteString)

        if let resolvedURL = Self.resolvedURLCache.object(forKey: firstKey) {
            if let cachedImage = Self.memoryCache.object(forKey: resolvedURL) {
                image = cachedImage
                return
            }
            if let loaded = await fetchImage(from: resolvedURL as URL) {
                image = loaded
                return
            }
        }

        for url in urls {
            if let cachedImage = Self.memoryCache.object(forKey: url as NSURL) {
                image = cachedImage
                if url != firstURL {
                    Self.resolvedURLCache.setObject(url as NSURL, forKey: firstKey)
                }
                return
            }
        }

        for url in urls {
            if let loaded = await fetchImage(from: url) {
                if url != firstURL {
                    Self.resolvedURLCache.setObject(url as NSURL, forKey: firstKey)
                }
                image = loaded
                return
            }
        }

        image = nil
    }

    private func loadLocalImage(path: String) -> UIImage? {
        guard let base = Bundle.main.resourceURL else { return nil }
        let fileURL = base.appendingPathComponent(path)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    private func fetchImage(from url: URL) async -> UIImage? {
        do {
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad

            let (data, response) = try await Self.session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return nil
            }
            guard let uiImage = UIImage(data: data) else {
                return nil
            }

            Self.memoryCache.setObject(uiImage, forKey: url as NSURL)
            return uiImage
        } catch {
            if Task.isCancelled { return nil }
            return nil
        }
    }

    private func normalizedURL(from raw: String) -> URL? {
        guard !raw.isEmpty else { return nil }
        if let direct = URL(string: raw) {
            return direct
        }
        let percentFixed = raw.replacingOccurrences(of: " ", with: "%20")
        if let percentURL = URL(string: percentFixed) {
            return percentURL
        }
        guard let encoded = raw.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            return nil
        }
        return URL(string: encoded)
    }
}

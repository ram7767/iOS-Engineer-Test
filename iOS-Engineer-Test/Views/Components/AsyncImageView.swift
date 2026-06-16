import SwiftUI

struct AsyncImageView: View {
    let urlString: String?
    var placeholder: Image = Image(systemName: "briefcase.fill")
    var size: CGFloat = 44

    @State private var loadedImage: UIImage?

    var body: some View {
        Group {
            if let loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .scaledToFit()
            } else {
                placeholder
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(Color(.systemGray5))
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
        .task(id: urlString) {
            guard let currentURL = urlString else { return }
            let image = await ImageCacheService.shared.image(for: currentURL)
            if Task.isCancelled { return }
            // Only apply if the URL hasn't changed while we were loading
            guard urlString == currentURL else { return }
            await MainActor.run { [image] in
                self.loadedImage = image
            }
        }
    }
}

#Preview("Async Image – no URL") {
    AsyncImageView(urlString: nil, size: 60)
        .padding()
}

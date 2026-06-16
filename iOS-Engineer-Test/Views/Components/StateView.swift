import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Loading jobs…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    var title: String = "No Jobs Found"
    var message: String = "Try adjusting your search or filters."
    var systemImage: String = "magnifyingglass"
    var action: (() -> Void)?
    var actionLabel: String = "Refresh"

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let action {
                Button(actionLabel, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        EmptyStateView(
            title: "Something Went Wrong",
            message: message,
            systemImage: "wifi.exclamationmark",
            action: retry,
            actionLabel: "Try Again"
        )
    }
}

#Preview("Loading") { LoadingView() }

#Preview("Empty") {
    EmptyStateView(
        title: "No Jobs Found",
        message: "Try adjusting your search or filters.",
        action: {}
    )
}

#Preview("Error") {
    ErrorStateView(message: "Could not connect to the server.") {}
}

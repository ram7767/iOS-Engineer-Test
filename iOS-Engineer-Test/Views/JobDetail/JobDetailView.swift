import SwiftUI

struct JobDetailView: View {
    @StateObject private var viewModel: JobDetailViewModel
    @Environment(\.openURL) private var openURL

    init(job: RemoteJob, savedJobsService: any SavedJobsServiceProtocol) {
        _viewModel = StateObject(wrappedValue: JobDetailViewModel(job: job, savedJobsService: savedJobsService))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                Divider()
                    .padding(.vertical, 16)

                metaSection
                    .padding(.horizontal, 20)

                Divider()
                    .padding(.vertical, 16)

                descriptionSection
                    .padding(.horizontal, 20)

                applyButton
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
            }
        }
        .navigationTitle(viewModel.job.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleSave()
                } label: {
                    Image(systemName: viewModel.isSaved ? "bookmark.fill" : "bookmark")
                        .symbolEffect(.bounce, value: viewModel.isSaved)
                }

                ShareLink(item: viewModel.shareText) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImageView(urlString: viewModel.job.companyLogoURL, size: 72)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.job.title)
                    .font(.title3)
                    .fontWeight(.bold)

                Text(viewModel.job.companyName)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(viewModel.job.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
    }

    private var metaSection: some View {
        VStack(spacing: 14) {
            InfoRow(icon: "mappin.circle.fill", label: "Location", value: viewModel.job.displayLocation, color: .red)
            InfoRow(icon: "banknote.fill", label: "Salary", value: viewModel.job.displaySalary, color: .green)
            InfoRow(icon: "briefcase.fill", label: "Type", value: viewModel.job.jobType, color: .blue)
            InfoRow(icon: "tag.fill", label: "Category", value: viewModel.job.categoryName, color: .purple)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About the role")
                .font(.headline)

            Text(viewModel.job.description.strippingHTML())
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(4)
        }
    }

    private var applyButton: some View {
        Button {
            if let url = URL(string: viewModel.job.url) {
                openURL(url)
            }
        } label: {
            Label("Apply Now", systemImage: "arrow.up.right.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    var color: Color = .accentColor

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value.isEmpty ? "—" : value)
                    .font(.subheadline)
            }
        }
    }
}

extension String {
    func strippingHTML() -> String {
        guard let data = data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributed.string
        }
        return replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}

#Preview {
    NavigationStack {
        JobDetailView(
            job: RemoteJob(
                id: 1,
                url: "https://example.com",
                title: "Senior iOS Engineer",
                companyName: "Acme Remote Inc",
                companyLogoURL: nil,
                categoryName: "software-dev",
                jobType: "full_time",
                publicationDate: "2026-06-01T00:00:00Z",
                candidateRequiredLocation: "USA, Europe",
                salary: "$130k – $160k",
                description: "<p>We are building <strong>great apps</strong> and need your help!</p>"
            ),
            savedJobsService: SavedJobsService.shared
        )
    }
}

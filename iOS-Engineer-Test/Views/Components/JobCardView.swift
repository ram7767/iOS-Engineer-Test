import SwiftUI

struct JobCardView: View {
    let job: RemoteJob
    var isSaved: Bool = false
    var onToggleSave: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImageView(urlString: job.companyLogoURL, size: 52)

                VStack(alignment: .leading, spacing: 2) {
                    Text(job.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Text(job.companyName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Save button — stops tap from propagating to NavigationLink
                if let onToggleSave {
                    Button {
                        onToggleSave()
                    } label: {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 18))
                            .foregroundStyle(isSaved ? Color.accentColor : Color.secondary)
                            .frame(width: 36, height: 36)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else if isSaved {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.accentColor)
                }
            }

            Divider()

            HStack(spacing: 16) {
                Label(job.displayLocation, systemImage: "mappin.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                if job.displaySalary != "Not specified" {
                    Label(job.displaySalary, systemImage: "banknote")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .lineLimit(1)
                }
            }

            HStack {
                TagView(text: job.categoryName)
                TagView(text: job.jobType, color: .blue)
                Spacer()
                Text(job.formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct TagView: View {
    let text: String
    var color: Color = .purple

    var body: some View {
        Text(text.isEmpty ? "Remote" : text)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview("Job Card – with save button") {
    @Previewable @State var saved = false
    JobCardView(
        job: RemoteJob(
            id: 1,
            url: "https://example.com",
            title: "Senior iOS Engineer",
            companyName: "Acme Remote Inc",
            companyLogoURL: nil,
            categoryName: "Software Development",
            jobType: "full_time",
            publicationDate: "2026-06-01T00:00:00Z",
            candidateRequiredLocation: "USA, Canada",
            salary: "$120k – $160k",
            description: "We are looking for a talented iOS engineer."
        ),
        isSaved: saved,
        onToggleSave: { saved.toggle() }
    )
    .padding()
}

import SwiftUI

struct SavedJobsView: View {
    @ObservedObject var viewModel: SavedJobsViewModel
    @Environment(\.savedJobsService) private var savedJobsService

    var body: some View {
        Group {
            if viewModel.isEmpty {
                EmptyStateView(
                    title: "No Saved Jobs",
                    message: "Bookmark jobs to see them here.",
                    systemImage: "bookmark.slash"
                )
            } else {
                List {
                    ForEach(viewModel.savedJobs) { job in
                        NavigationLink(value: job) {
                            JobCardView(job: job, isSaved: true)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            let job = viewModel.savedJobs[index]
                            viewModel.remove(job: job)
                        }
                    }
                }
                .listStyle(.plain)
                .navigationDestination(for: RemoteJob.self) { job in
                    JobDetailView(job: job, savedJobsService: savedJobsService)
                }
            }
        }
        .navigationTitle("Saved Jobs")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.loadSavedJobs() }
    }
}

#Preview {
    NavigationStack {
        SavedJobsView(viewModel: SavedJobsViewModel(savedJobsService: SavedJobsService.shared))
            .environment(\.savedJobsService, SavedJobsService.shared)
    }
}

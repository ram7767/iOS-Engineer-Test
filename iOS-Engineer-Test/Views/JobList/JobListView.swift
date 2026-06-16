import SwiftUI

struct JobListView: View {
    @ObservedObject var viewModel: JobListViewModel
    @ObservedObject var savedJobsViewModel: SavedJobsViewModel
    @Environment(\.savedJobsService) private var savedJobsService
    @State private var didLoad = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CategoryFilterView(
                    categories: viewModel.categories,
                    selected: viewModel.selectedCategory
                ) { category in
                    Task { await viewModel.applyCategory(category) }
                }

                Divider()

                contentView
            }
            .navigationTitle("Remote Jobs")
            .searchable(text: $viewModel.searchText, prompt: "Search title or company…")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SavedJobsView(viewModel: savedJobsViewModel)
                    } label: {
                        Label("Saved", systemImage: "bookmark.fill")
                    }
                }
            }
            .onAppear {
                guard !didLoad else { return }
                didLoad = true
                Task { await viewModel.loadJobs() }
            }
            .refreshable { await viewModel.refresh() }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .loading where viewModel.jobs.isEmpty:
            LoadingView()

        case .empty:
            EmptyStateView(
                title: "No Jobs Found",
                message: viewModel.searchText.isEmpty
                    ? "No remote jobs available right now."
                    : "No results for \"\(viewModel.searchText)\".",
                action: { Task { await viewModel.refresh() } }
            )

        case .error(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.loadJobs() }
            }

        default:
            jobList
        }
    }

    private var jobList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.jobs) { job in
                    NavigationLink(value: job) {
                        JobCardView(
                            job: job,
                            isSaved: savedJobsViewModel.isSaved(job: job),
                            onToggleSave: {
                                if savedJobsViewModel.isSaved(job: job) {
                                    savedJobsViewModel.remove(job: job)
                                } else {
                                    savedJobsService.save(job: job)
                                }
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding(.vertical, 12)
                } else if viewModel.hasMorePages {
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            Task { await viewModel.loadNextPage() }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationDestination(for: RemoteJob.self) { job in
            JobDetailView(job: job, savedJobsService: savedJobsService)
        }
    }
}

#Preview {
    JobListView(
        viewModel: JobListViewModel(jobService: JobService.shared),
        savedJobsViewModel: SavedJobsViewModel(savedJobsService: SavedJobsService.shared)
    )
    .environment(\.savedJobsService, SavedJobsService.shared)
}


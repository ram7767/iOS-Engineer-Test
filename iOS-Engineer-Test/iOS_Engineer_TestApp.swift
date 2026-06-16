import SwiftUI

@main
struct RemoteRecruitApp: App {
    private let jobService: any JobServiceProtocol = JobService.shared
    private let savedJobsService: any SavedJobsServiceProtocol = SavedJobsService.shared

    var body: some Scene {
        WindowGroup {
            RootView(
                jobService: jobService,
                savedJobsService: savedJobsService
            )
            .environment(\.savedJobsService, savedJobsService)
        }
    }
}

struct RootView: View {
    @StateObject private var jobListViewModel: JobListViewModel
    @StateObject private var savedJobsViewModel: SavedJobsViewModel

    init(jobService: any JobServiceProtocol, savedJobsService: any SavedJobsServiceProtocol) {
        _jobListViewModel = StateObject(wrappedValue: JobListViewModel(jobService: jobService))
        _savedJobsViewModel = StateObject(wrappedValue: SavedJobsViewModel(savedJobsService: savedJobsService))
    }

    var body: some View {
        JobListView(viewModel: jobListViewModel, savedJobsViewModel: savedJobsViewModel)
    }
}

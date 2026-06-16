import Foundation
import Combine

@MainActor
final class SavedJobsViewModel: ObservableObject {
    @Published private(set) var savedJobs: [RemoteJob] = []

    private let savedJobsService: SavedJobsServiceProtocol
    private var cancellable: AnyCancellable?

    init(savedJobsService: SavedJobsServiceProtocol) {
        self.savedJobsService = savedJobsService
        // Subscribe so the list auto-updates when saves happen from any screen
        cancellable = savedJobsService.savedJobsPublisher
            .sink { [weak self] jobs in
                self?.savedJobs = jobs
            }
    }

    func loadSavedJobs() {
        savedJobs = savedJobsService.savedJobs()
    }

    func remove(job: RemoteJob) {
        savedJobsService.remove(job: job)
        // Sync immediately (publisher may be async in production)
        savedJobs = savedJobsService.savedJobs()
    }

    func isSaved(job: RemoteJob) -> Bool {
        savedJobsService.isSaved(job: job)
    }

    var isEmpty: Bool { savedJobs.isEmpty }
}

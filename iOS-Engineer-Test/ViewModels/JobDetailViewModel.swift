import Foundation
import Combine

@MainActor
final class JobDetailViewModel: ObservableObject {
    @Published private(set) var isSaved: Bool = false

    let job: RemoteJob
    private let savedJobsService: SavedJobsServiceProtocol
    private var cancellable: AnyCancellable?

    init(job: RemoteJob, savedJobsService: SavedJobsServiceProtocol) {
        self.job = job
        self.savedJobsService = savedJobsService
        self.isSaved = savedJobsService.isSaved(job: job)
        // Keep isSaved in sync if another screen modifies the saved list
        cancellable = savedJobsService.savedJobsPublisher
            .map { [weak self] jobs -> Bool in
                guard let self else { return false }
                return jobs.contains(where: { $0.id == self.job.id })
            }
            .removeDuplicates()
            .sink { [weak self] saved in
                self?.isSaved = saved
            }
    }

    func toggleSave() {
        if isSaved {
            savedJobsService.remove(job: job)
        } else {
            savedJobsService.save(job: job)
        }
        // Immediately reflect the new state without waiting for the publisher
        isSaved = savedJobsService.isSaved(job: job)
    }

    var companyLogoURL: URL? {
        guard let raw = job.companyLogoURL, !raw.isEmpty else { return nil }
        return URL(string: raw)
    }

    var shareText: String {
        "\(job.title) at \(job.companyName)\n\(job.url)"
    }
}

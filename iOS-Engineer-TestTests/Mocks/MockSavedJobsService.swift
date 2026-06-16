import Foundation
import Combine
@testable import iOS_Engineer_Test

final class MockSavedJobsService: SavedJobsServiceProtocol {
    private var store: [RemoteJob] = [] {
        didSet { subject.send(store) }
    }
    private let subject = CurrentValueSubject<[RemoteJob], Never>([])

    var savedJobsPublisher: AnyPublisher<[RemoteJob], Never> {
        subject.eraseToAnyPublisher()
    }

    func savedJobs() -> [RemoteJob] { store }

    func save(job: RemoteJob) {
        if !store.contains(where: { $0.id == job.id }) {
            store.append(job)
        }
    }

    func remove(job: RemoteJob) {
        store.removeAll { $0.id == job.id }
    }

    func isSaved(job: RemoteJob) -> Bool {
        store.contains(where: { $0.id == job.id })
    }
}

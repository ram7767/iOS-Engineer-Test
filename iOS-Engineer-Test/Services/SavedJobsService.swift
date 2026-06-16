import Foundation
import Combine
import SwiftUI

protocol SavedJobsServiceProtocol: AnyObject {
    var savedJobsPublisher: AnyPublisher<[RemoteJob], Never> { get }
    func savedJobs() -> [RemoteJob]
    func save(job: RemoteJob)
    func remove(job: RemoteJob)
    func isSaved(job: RemoteJob) -> Bool
}

final class SavedJobsService: SavedJobsServiceProtocol {
    static let shared = SavedJobsService()

    private let key = "saved_jobs"
    private let defaults: UserDefaults
    private let subject: CurrentValueSubject<[RemoteJob], Never>

    var savedJobsPublisher: AnyPublisher<[RemoteJob], Never> {
        subject.eraseToAnyPublisher()
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let initial = Self.load(from: defaults, key: "saved_jobs")
        self.subject = CurrentValueSubject(initial)
    }

    func savedJobs() -> [RemoteJob] { subject.value }

    func save(job: RemoteJob) {
        var current = subject.value
        guard !current.contains(where: { $0.id == job.id }) else { return }
        current.append(job)
        persist(current)
    }

    func remove(job: RemoteJob) {
        var current = subject.value
        current.removeAll { $0.id == job.id }
        persist(current)
    }

    func isSaved(job: RemoteJob) -> Bool {
        subject.value.contains(where: { $0.id == job.id })
    }

    private func persist(_ jobs: [RemoteJob]) {
        subject.send(jobs)
        if let data = try? JSONEncoder().encode(jobs) {
            defaults.set(data, forKey: key)
        }
    }

    private static func load(from defaults: UserDefaults, key: String) -> [RemoteJob] {
        guard let data = defaults.data(forKey: key),
              let jobs = try? JSONDecoder().decode([RemoteJob].self, from: data) else {
            return []
        }
        return jobs
    }
}

// MARK: - Environment Key

private struct SavedJobsServiceKey: EnvironmentKey {
    static let defaultValue: any SavedJobsServiceProtocol = SavedJobsService.shared
}

extension EnvironmentValues {
    var savedJobsService: any SavedJobsServiceProtocol {
        get { self[SavedJobsServiceKey.self] }
        set { self[SavedJobsServiceKey.self] = newValue }
    }
}

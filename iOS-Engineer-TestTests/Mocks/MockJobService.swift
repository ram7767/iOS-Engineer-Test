import Foundation
@testable import iOS_Engineer_Test

final class MockJobService: JobServiceProtocol {
    var jobsToReturn: [RemoteJob] = []
    var errorToThrow: Error?
    var fetchCallCount = 0

    func fetchAllJobs() async throws -> [RemoteJob] {
        fetchCallCount += 1
        if let error = errorToThrow { throw error }
        return jobsToReturn
    }
}

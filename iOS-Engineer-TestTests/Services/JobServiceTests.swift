import XCTest
@testable import iOS_Engineer_Test

final class JobServiceTests: XCTestCase {

    // MARK: - Error descriptions

    func test_invalidURLError_hasDescription() {
        let error = JobServiceError.invalidURL
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }

    func test_networkError_includesUnderlyingDescription() {
        let underlying = URLError(.notConnectedToInternet)
        let error = JobServiceError.networkError(underlying)
        XCTAssertTrue(error.errorDescription!.contains("Network"))
    }

    func test_serverError_includesStatusCode() {
        let error = JobServiceError.serverError(503)
        XCTAssertTrue(error.errorDescription!.contains("503"))
    }

    func test_decodingError_hasDescription() {
        let underlying = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "bad data"))
        let error = JobServiceError.decodingError(underlying)
        XCTAssertNotNil(error.errorDescription)
    }

    // MARK: - fetchAllJobs success

    func test_fetchAllJobs_decodesResponseCorrectly() async throws {
        let jobs = (1...5).map { i -> [String: Any] in
            ["id": i, "url": "https://example.com/\(i)", "title": "Job \(i)",
             "company_name": "Co", "company_logo": NSNull(), "category": "Software Development",
             "job_type": "full_time", "publication_date": "2026-01-01T00:00:00Z",
             "candidate_required_location": "", "salary": "", "description": "Desc"]
        }
        let data = try JSONSerialization.data(withJSONObject: ["jobs": jobs])
        let url = URL(string: "https://remotive.com/api/remote-jobs")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!

        let service = JobService(session: MockURLSession(data: data, response: response))
        let result = try await service.fetchAllJobs()

        XCTAssertEqual(result.count, 5)
        XCTAssertEqual(result.first?.id, 1)
        XCTAssertEqual(result.first?.categoryName, "Software Development")
    }

    func test_fetchAllJobs_returnsEmptyForEmptyJobsArray() async throws {
        let data = try JSONSerialization.data(withJSONObject: ["jobs": []])
        let url = URL(string: "https://remotive.com/api/remote-jobs")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!

        let service = JobService(session: MockURLSession(data: data, response: response))
        let result = try await service.fetchAllJobs()

        XCTAssertTrue(result.isEmpty)
    }

    func test_fetchAllJobs_throwsServerErrorOn500() async throws {
        let url = URL(string: "https://remotive.com/api/remote-jobs")!
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
        let service = JobService(session: MockURLSession(data: Data(), response: response))

        do {
            _ = try await service.fetchAllJobs()
            XCTFail("Expected error")
        } catch JobServiceError.serverError(let code) {
            XCTAssertEqual(code, 500)
        }
    }

    func test_fetchAllJobs_throwsDecodingErrorOnBadData() async throws {
        let url = URL(string: "https://remotive.com/api/remote-jobs")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let service = JobService(session: MockURLSession(data: Data("bad json".utf8), response: response))

        do {
            _ = try await service.fetchAllJobs()
            XCTFail("Expected decoding error")
        } catch JobServiceError.decodingError {
            // expected
        }
    }

    func test_fetchAllJobs_cachesResultOnSecondCall() async throws {
        let jobs: [[String: Any]] = [
            ["id": 1, "url": "https://example.com/1", "title": "Job 1",
             "company_name": "Co", "company_logo": NSNull(), "category": "Software Development",
             "job_type": "full_time", "publication_date": "2026-01-01T00:00:00Z",
             "candidate_required_location": "", "salary": "", "description": "Desc"]
        ]
        let data = try JSONSerialization.data(withJSONObject: ["jobs": jobs])
        let url = URL(string: "https://remotive.com/api/remote-jobs")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let session = MockURLSession(data: data, response: response)
        let service = JobService(session: session)

        _ = try await service.fetchAllJobs()
        _ = try await service.fetchAllJobs()

        XCTAssertEqual(session.callCount, 1, "Second call should use cache, not network")
    }
}

// MARK: - Mock URLSession

private final class MockURLSession: URLSessionProtocol {
    private let _data: Data
    private let _response: URLResponse
    private(set) var callCount = 0

    init(data: Data, response: URLResponse) {
        self._data = data
        self._response = response
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        callCount += 1
        return (_data, _response)
    }
}

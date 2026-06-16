import Foundation

protocol JobServiceProtocol {
    func fetchAllJobs() async throws -> [RemoteJob]
}

enum JobServiceError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:        return "Invalid URL."
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .decodingError(let e): return "Data error: \(e.localizedDescription)"
        case .serverError(let code): return "Server returned error \(code)."
        }
    }
}

// MARK: - URL Session abstraction for testability

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

// MARK: - JobService

final class JobService: JobServiceProtocol {
    static let shared = JobService()

    private let session: URLSessionProtocol
    private let baseURL = "https://remotive.com/api/remote-jobs"
    private var cache: [RemoteJob]?

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func fetchAllJobs() async throws -> [RemoteJob] {
        if let cached = cache { return cached }

        guard let url = URL(string: baseURL) else { throw JobServiceError.invalidURL }

        let (data, response) = try await session.data(from: url)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw JobServiceError.serverError(http.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(JobResponse.self, from: data)
            cache = decoded.jobs
            return decoded.jobs
        } catch {
            throw JobServiceError.decodingError(error)
        }
    }

    func clearCache() { cache = nil }
}

import Foundation

struct RemoteJob: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let url: String
    let title: String
    let companyName: String
    let companyLogoURL: String?
    let categoryName: String
    let jobType: String
    let publicationDate: String
    let candidateRequiredLocation: String
    let salary: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case title
        case companyName = "company_name"
        case companyLogoURL = "company_logo"
        case categoryName = "category"
        case jobType = "job_type"
        case publicationDate = "publication_date"
        case candidateRequiredLocation = "candidate_required_location"
        case salary
        case description
    }

    var displayLocation: String {
        candidateRequiredLocation.isEmpty ? "Worldwide / Remote" : candidateRequiredLocation
    }

    var displaySalary: String {
        salary.isEmpty ? "Not specified" : salary
    }

    var formattedDate: String {
        let display = DateFormatter()
        display.dateStyle = .medium

        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = withFractional.date(from: publicationDate) {
            return display.string(from: date)
        }

        let withoutFractional = ISO8601DateFormatter()
        withoutFractional.formatOptions = [.withInternetDateTime]
        if let date = withoutFractional.date(from: publicationDate) {
            return display.string(from: date)
        }

        return publicationDate
    }
}

struct JobResponse: Codable {
    let jobs: [RemoteJob]
}

struct JobCategory: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String
}

import Foundation
@testable import iOS_Engineer_Test

extension RemoteJob {
    static func fixture(
        id: Int = 1,
        title: String = "iOS Engineer",
        companyName: String = "Acme Inc",
        location: String = "Worldwide",
        salary: String = "$100k - $150k",
        description: String = "Great job for iOS devs.",
        url: String = "https://example.com/job/1",
        categoryName: String = "Software Development",
        jobType: String = "full_time",
        companyLogoURL: String? = nil,
        publicationDate: String = "2026-06-01T00:00:00Z"
    ) -> RemoteJob {
        RemoteJob(
            id: id,
            url: url,
            title: title,
            companyName: companyName,
            companyLogoURL: companyLogoURL,
            categoryName: categoryName,
            jobType: jobType,
            publicationDate: publicationDate,
            candidateRequiredLocation: location,
            salary: salary,
            description: description
        )
    }
}

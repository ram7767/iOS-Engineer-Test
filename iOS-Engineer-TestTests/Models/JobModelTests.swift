import XCTest
@testable import iOS_Engineer_Test

final class JobModelTests: XCTestCase {

    func test_displayLocation_returnsWorldwideWhenEmpty() {
        let job = RemoteJob.fixture(location: "")
        XCTAssertEqual(job.displayLocation, "Worldwide / Remote")
    }

    func test_displayLocation_returnsActualLocationWhenSet() {
        let job = RemoteJob.fixture(location: "USA, Canada")
        XCTAssertEqual(job.displayLocation, "USA, Canada")
    }

    func test_displaySalary_returnsNotSpecifiedWhenEmpty() {
        let job = RemoteJob.fixture(salary: "")
        XCTAssertEqual(job.displaySalary, "Not specified")
    }

    func test_displaySalary_returnsActualSalaryWhenSet() {
        let job = RemoteJob.fixture(salary: "$100k")
        XCTAssertEqual(job.displaySalary, "$100k")
    }

    func test_formattedDate_parsesISO8601() {
        let job = RemoteJob.fixture(publicationDate: "2026-06-01T00:00:00Z")
        XCTAssertFalse(job.formattedDate.isEmpty)
        XCTAssertNotEqual(job.formattedDate, "2026-06-01T00:00:00Z")
    }

    func test_formattedDate_fallbacksToRawOnInvalidDate() {
        let job = RemoteJob.fixture(publicationDate: "not-a-date")
        XCTAssertEqual(job.formattedDate, "not-a-date")
    }

    func test_job_isHashable() {
        let job1 = RemoteJob.fixture(id: 1)
        let job2 = RemoteJob.fixture(id: 2)
        let set: Set<RemoteJob> = [job1, job2]
        XCTAssertEqual(set.count, 2)
    }

    func test_job_equalityBasedOnAllFields() {
        let job1 = RemoteJob.fixture(id: 1)
        let job2 = RemoteJob.fixture(id: 1)
        XCTAssertEqual(job1, job2)
    }

    func test_job_decodingFromJSON() throws {
        let json = """
        {
            "id": 99,
            "url": "https://example.com",
            "title": "Backend Dev",
            "company_name": "TestCo",
            "company_logo": null,
            "category": "devops",
            "job_type": "contract",
            "publication_date": "2026-01-01T00:00:00Z",
            "candidate_required_location": "Europe",
            "salary": "",
            "description": "A great role."
        }
        """.data(using: .utf8)!

        let job = try JSONDecoder().decode(RemoteJob.self, from: json)
        XCTAssertEqual(job.id, 99)
        XCTAssertEqual(job.title, "Backend Dev")
        XCTAssertEqual(job.companyName, "TestCo")
        XCTAssertNil(job.companyLogoURL)
        XCTAssertEqual(job.categoryName, "devops")
    }
}

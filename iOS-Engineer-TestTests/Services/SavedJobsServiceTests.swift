import XCTest
@testable import iOS_Engineer_Test

final class SavedJobsServiceTests: XCTestCase {

    private var sut: SavedJobsService!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: #file)!
        defaults.removePersistentDomain(forName: #file)
        sut = SavedJobsService(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: #file)
        sut = nil
        defaults = nil
        super.tearDown()
    }

    func test_savedJobs_isInitiallyEmpty() {
        XCTAssertTrue(sut.savedJobs().isEmpty)
    }

    func test_save_addsJob() {
        sut.save(job: .fixture(id: 1))
        XCTAssertEqual(sut.savedJobs().count, 1)
    }

    func test_save_doesNotDuplicateJob() {
        sut.save(job: .fixture(id: 1))
        sut.save(job: .fixture(id: 1))
        XCTAssertEqual(sut.savedJobs().count, 1)
    }

    func test_remove_removesJob() {
        let job = RemoteJob.fixture(id: 3)
        sut.save(job: job)
        sut.remove(job: job)
        XCTAssertTrue(sut.savedJobs().isEmpty)
    }

    func test_remove_doesNothingWhenJobNotSaved() {
        sut.remove(job: .fixture(id: 99))
        XCTAssertTrue(sut.savedJobs().isEmpty)
    }

    func test_isSaved_returnsTrueAfterSaving() {
        let job = RemoteJob.fixture(id: 5)
        sut.save(job: job)
        XCTAssertTrue(sut.isSaved(job: job))
    }

    func test_isSaved_returnsFalseBeforeSaving() {
        XCTAssertFalse(sut.isSaved(job: .fixture(id: 6)))
    }

    func test_persistenceAcrossInstances() {
        sut.save(job: .fixture(id: 10, title: "Persistent Job"))

        let newInstance = SavedJobsService(defaults: defaults)
        let jobs = newInstance.savedJobs()

        XCTAssertEqual(jobs.count, 1)
        XCTAssertEqual(jobs.first?.title, "Persistent Job")
    }

    func test_saveMultipleJobs() {
        (1...5).forEach { sut.save(job: .fixture(id: $0)) }
        XCTAssertEqual(sut.savedJobs().count, 5)
    }
}

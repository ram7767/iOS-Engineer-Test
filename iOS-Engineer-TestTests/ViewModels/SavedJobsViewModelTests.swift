import XCTest
@testable import iOS_Engineer_Test

@MainActor
final class SavedJobsViewModelTests: XCTestCase {

    private var mockService: MockSavedJobsService!
    private var viewModel: SavedJobsViewModel!

    override func setUp() {
        super.setUp()
        mockService = MockSavedJobsService()
        viewModel = SavedJobsViewModel(savedJobsService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func test_initialState_isEmpty() {
        viewModel.loadSavedJobs()
        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertTrue(viewModel.savedJobs.isEmpty)
    }

    func test_loadSavedJobs_returnsPersistedJobs() {
        let job = RemoteJob.fixture(id: 10)
        mockService.save(job: job)

        viewModel.loadSavedJobs()

        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertEqual(viewModel.savedJobs.count, 1)
        XCTAssertEqual(viewModel.savedJobs.first?.id, 10)
    }

    func test_remove_deletesJobAndRefreshesList() {
        let job = RemoteJob.fixture(id: 5)
        mockService.save(job: job)
        viewModel.loadSavedJobs()
        XCTAssertEqual(viewModel.savedJobs.count, 1)

        viewModel.remove(job: job)

        XCTAssertTrue(viewModel.savedJobs.isEmpty)
        XCTAssertTrue(viewModel.isEmpty)
    }

    func test_isSaved_returnsTrueForSavedJob() {
        let job = RemoteJob.fixture(id: 7)
        mockService.save(job: job)

        XCTAssertTrue(viewModel.isSaved(job: job))
    }

    func test_isSaved_returnsFalseForUnsavedJob() {
        let job = RemoteJob.fixture(id: 8)
        XCTAssertFalse(viewModel.isSaved(job: job))
    }

    func test_loadSavedJobs_multipleJobs() {
        (1...5).forEach { mockService.save(job: .fixture(id: $0)) }
        viewModel.loadSavedJobs()
        XCTAssertEqual(viewModel.savedJobs.count, 5)
    }
}

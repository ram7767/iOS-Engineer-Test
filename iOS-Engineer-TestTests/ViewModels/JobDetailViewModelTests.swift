import XCTest
@testable import iOS_Engineer_Test

@MainActor
final class JobDetailViewModelTests: XCTestCase {

    private var mockService: MockSavedJobsService!
    private var job: RemoteJob!
    private var viewModel: JobDetailViewModel!

    override func setUp() {
        super.setUp()
        mockService = MockSavedJobsService()
        job = .fixture(id: 42, title: "Senior iOS Engineer")
        viewModel = JobDetailViewModel(job: job, savedJobsService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        job = nil
        super.tearDown()
    }

    func test_initialState_isNotSaved() {
        XCTAssertFalse(viewModel.isSaved)
    }

    func test_toggleSave_savesJob() {
        viewModel.toggleSave()
        XCTAssertTrue(viewModel.isSaved)
        XCTAssertTrue(mockService.isSaved(job: job))
    }

    func test_toggleSave_unsavesJobWhenAlreadySaved() {
        viewModel.toggleSave()
        viewModel.toggleSave()
        XCTAssertFalse(viewModel.isSaved)
        XCTAssertFalse(mockService.isSaved(job: job))
    }

    func test_shareText_containsTitleAndURL() {
        XCTAssertTrue(viewModel.shareText.contains(job.title))
        XCTAssertTrue(viewModel.shareText.contains(job.url))
    }

    func test_companyLogoURL_isNilWhenEmpty() {
        let j = RemoteJob.fixture(companyLogoURL: nil)
        let vm = JobDetailViewModel(job: j, savedJobsService: mockService)
        XCTAssertNil(vm.companyLogoURL)
    }

    func test_companyLogoURL_isValidWhenProvided() {
        let j = RemoteJob.fixture(companyLogoURL: "https://example.com/logo.png")
        let vm = JobDetailViewModel(job: j, savedJobsService: mockService)
        XCTAssertNotNil(vm.companyLogoURL)
        XCTAssertEqual(vm.companyLogoURL?.absoluteString, "https://example.com/logo.png")
    }

    func test_jobProperties_areExposed() {
        XCTAssertEqual(viewModel.job.title, "Senior iOS Engineer")
        XCTAssertEqual(viewModel.job.id, 42)
    }
}

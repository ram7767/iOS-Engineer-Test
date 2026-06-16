import XCTest
import Combine
@testable import iOS_Engineer_Test

@MainActor
final class JobListViewModelTests: XCTestCase {

    private var mockService: MockJobService!
    private var viewModel: JobListViewModel!

    override func setUp() {
        super.setUp()
        mockService = MockJobService()
        viewModel = JobListViewModel(jobService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Initial Load

    func test_loadJobs_setsLoadedStateOnSuccess() async {
        mockService.jobsToReturn = (1...5).map { .fixture(id: $0) }
        await viewModel.loadJobs()
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertFalse(viewModel.jobs.isEmpty)
    }

    func test_loadJobs_setsErrorStateOnFailure() async {
        mockService.errorToThrow = JobServiceError.serverError(500)
        await viewModel.loadJobs()
        if case .error = viewModel.state { } else {
            XCTFail("Expected error state, got \(viewModel.state)")
        }
    }

    func test_loadJobs_setsEmptyStateWhenNoJobs() async {
        mockService.jobsToReturn = []
        await viewModel.loadJobs()
        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertTrue(viewModel.jobs.isEmpty)
    }

    func test_loadJobs_doesNotRefetchWhenAlreadyLoaded() async {
        mockService.jobsToReturn = [.fixture(id: 1)]
        await viewModel.loadJobs()
        await viewModel.loadJobs()
        XCTAssertEqual(mockService.fetchCallCount, 1)
    }

    func test_loadJobs_jobsAreNotEmptyAfterLoad() async {
        mockService.jobsToReturn = [.fixture(id: 1), .fixture(id: 2)]
        await viewModel.loadJobs()
        XCTAssertEqual(viewModel.jobs.count, 2)
    }

    // MARK: - Pagination

    func test_pagination_firstPageHas10Jobs() async {
        mockService.jobsToReturn = (1...25).map { .fixture(id: $0) }
        await viewModel.loadJobs()
        XCTAssertEqual(viewModel.jobs.count, 10)
        XCTAssertTrue(viewModel.hasMorePages)
    }

    func test_loadNextPage_appendsNextBatch() async {
        mockService.jobsToReturn = (1...25).map { .fixture(id: $0) }
        await viewModel.loadJobs()
        XCTAssertEqual(viewModel.jobs.count, 10)
        await viewModel.loadNextPage()
        XCTAssertEqual(viewModel.jobs.count, 20)
        XCTAssertTrue(viewModel.hasMorePages)
    }

    func test_loadNextPage_setsNoMorePagesOnLastBatch() async {
        mockService.jobsToReturn = (1...15).map { .fixture(id: $0) }
        await viewModel.loadJobs()
        await viewModel.loadNextPage()
        XCTAssertEqual(viewModel.jobs.count, 15)
        XCTAssertFalse(viewModel.hasMorePages)
    }

    func test_noMorePagesWhenTotalFitsOnePage() async {
        mockService.jobsToReturn = (1...8).map { .fixture(id: $0) }
        await viewModel.loadJobs()
        XCTAssertEqual(viewModel.jobs.count, 8)
        XCTAssertFalse(viewModel.hasMorePages)
    }

    func test_loadNextPage_doesNothingWhenNoMorePages() async {
        mockService.jobsToReturn = (1...5).map { .fixture(id: $0) }
        await viewModel.loadJobs()
        XCTAssertFalse(viewModel.hasMorePages)
        await viewModel.loadNextPage()
        XCTAssertEqual(mockService.fetchCallCount, 1)
        XCTAssertEqual(viewModel.jobs.count, 5)
    }

    func test_exactlyOnePage_hasNoMorePages() async {
        mockService.jobsToReturn = (1...10).map { .fixture(id: $0) }
        await viewModel.loadJobs()
        XCTAssertEqual(viewModel.jobs.count, 10)
        XCTAssertFalse(viewModel.hasMorePages)
    }

    func test_threeFullPages() async {
        mockService.jobsToReturn = (1...30).map { .fixture(id: $0) }
        await viewModel.loadJobs()
        await viewModel.loadNextPage()
        await viewModel.loadNextPage()
        XCTAssertEqual(viewModel.jobs.count, 30)
        XCTAssertFalse(viewModel.hasMorePages)
    }

    // MARK: - Search (client-side)

    func test_search_filtersJobsByTitle() async {
        mockService.jobsToReturn = [
            .fixture(id: 1, title: "iOS Engineer"),
            .fixture(id: 2, title: "Android Developer"),
            .fixture(id: 3, title: "Senior iOS Dev")
        ]
        await viewModel.loadJobs()
        await viewModel.applySearch("iOS")
        XCTAssertEqual(viewModel.jobs.count, 2)
        XCTAssertTrue(viewModel.jobs.allSatisfy { $0.title.localizedCaseInsensitiveContains("iOS") })
    }

    func test_search_filtersJobsByCompany() async {
        mockService.jobsToReturn = [
            .fixture(id: 1, companyName: "Apple Inc"),
            .fixture(id: 2, companyName: "Google LLC"),
            .fixture(id: 3, companyName: "Apple Consulting")
        ]
        await viewModel.loadJobs()
        await viewModel.applySearch("Apple")
        XCTAssertEqual(viewModel.jobs.count, 2)
    }

    func test_search_filtersJobsByCategory() async {
        mockService.jobsToReturn = [
            .fixture(id: 1, categoryName: "Software Development"),
            .fixture(id: 2, categoryName: "Marketing")
        ]
        await viewModel.loadJobs()
        await viewModel.applySearch("Software")
        XCTAssertEqual(viewModel.jobs.count, 1)
    }

    func test_search_emptyQueryShowsAll() async {
        mockService.jobsToReturn = (1...5).map { .fixture(id: $0) }
        await viewModel.loadJobs()
        await viewModel.applySearch("something")
        await viewModel.applySearch("")
        XCTAssertEqual(viewModel.jobs.count, 5)
    }

    func test_search_noMatchReturnsEmpty() async {
        mockService.jobsToReturn = [.fixture(id: 1, title: "iOS Engineer")]
        await viewModel.loadJobs()
        await viewModel.applySearch("python")
        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertTrue(viewModel.jobs.isEmpty)
    }

    func test_search_caseInsensitive() async {
        mockService.jobsToReturn = [.fixture(id: 1, title: "iOS Engineer")]
        await viewModel.loadJobs()
        await viewModel.applySearch("ios engineer")
        XCTAssertEqual(viewModel.jobs.count, 1)
    }

    func test_search_trimsWhitespace() async {
        mockService.jobsToReturn = [.fixture(id: 1, title: "iOS Engineer")]
        await viewModel.loadJobs()
        await viewModel.applySearch("  iOS  ")
        XCTAssertEqual(viewModel.jobs.count, 1)
    }

    // MARK: - Category filter (client-side)

    func test_applyCategory_filtersJobsByCategory() async {
        mockService.jobsToReturn = [
            .fixture(id: 1, categoryName: "Software Development"),
            .fixture(id: 2, categoryName: "Marketing"),
            .fixture(id: 3, categoryName: "Software Development")
        ]
        await viewModel.loadJobs()
        await viewModel.applyCategory("Software Development")
        XCTAssertEqual(viewModel.jobs.count, 2)
        XCTAssertTrue(viewModel.jobs.allSatisfy { $0.categoryName == "Software Development" })
    }

    func test_applyCategory_emptyStringShowsAll() async {
        mockService.jobsToReturn = [
            .fixture(id: 1, categoryName: "Software Development"),
            .fixture(id: 2, categoryName: "Marketing")
        ]
        await viewModel.loadJobs()
        await viewModel.applyCategory("Software Development")
        await viewModel.applyCategory("")
        XCTAssertEqual(viewModel.jobs.count, 2)
    }

    func test_applyCategory_noMatchReturnsEmpty() async {
        mockService.jobsToReturn = [.fixture(id: 1, categoryName: "Marketing")]
        await viewModel.loadJobs()
        await viewModel.applyCategory("Software Development")
        XCTAssertEqual(viewModel.state, .empty)
    }

    func test_applyCategory_caseInsensitive() async {
        mockService.jobsToReturn = [.fixture(id: 1, categoryName: "Software Development")]
        await viewModel.loadJobs()
        await viewModel.applyCategory("software development")
        XCTAssertEqual(viewModel.jobs.count, 1)
    }

    func test_applyCategory_preservesSearchText() async {
        mockService.jobsToReturn = [
            .fixture(id: 1, title: "iOS Dev", categoryName: "Software Development"),
            .fixture(id: 2, title: "Marketing Mgr", categoryName: "Marketing")
        ]
        await viewModel.loadJobs()
        await viewModel.applySearch("iOS")
        await viewModel.applyCategory("Software Development")
        XCTAssertEqual(viewModel.searchText, "iOS")
        XCTAssertEqual(viewModel.jobs.count, 1)
    }

    func test_selectedCategory_isSetCorrectly() async {
        mockService.jobsToReturn = [.fixture()]
        await viewModel.loadJobs()
        await viewModel.applyCategory("Marketing")
        XCTAssertEqual(viewModel.selectedCategory, "Marketing")
    }

    // MARK: - Refresh

    func test_refresh_resetsSearchAndCategory() async {
        mockService.jobsToReturn = [.fixture()]
        await viewModel.loadJobs()
        viewModel.searchText = "iOS"
        viewModel.selectedCategory = "Design"
        await viewModel.refresh()
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.selectedCategory, "")
    }

    func test_refresh_fetchesNewData() async {
        mockService.jobsToReturn = [.fixture(id: 1)]
        await viewModel.loadJobs()
        mockService.jobsToReturn = [.fixture(id: 1), .fixture(id: 2)]
        await viewModel.refresh()
        XCTAssertEqual(viewModel.jobs.count, 2)
        XCTAssertEqual(mockService.fetchCallCount, 2)
    }

    func test_refresh_fromErrorStateSucceeds() async {
        mockService.errorToThrow = JobServiceError.networkError(URLError(.notConnectedToInternet))
        await viewModel.loadJobs()
        if case .error = viewModel.state { } else { XCTFail("Expected error") }

        mockService.errorToThrow = nil
        mockService.jobsToReturn = [.fixture(id: 1)]
        await viewModel.refresh()

        XCTAssertEqual(viewModel.state, .loaded)
    }

    // MARK: - Combined filter + search

    func test_categoryAndSearch_bothApplied() async {
        mockService.jobsToReturn = [
            .fixture(id: 1, title: "iOS Engineer", categoryName: "Software Development"),
            .fixture(id: 2, title: "iOS Engineer", categoryName: "Marketing"),
            .fixture(id: 3, title: "Android Dev", categoryName: "Software Development")
        ]
        await viewModel.loadJobs()
        await viewModel.applySearch("iOS")
        await viewModel.applyCategory("Software Development")
        XCTAssertEqual(viewModel.jobs.count, 1)
        XCTAssertEqual(viewModel.jobs.first?.id, 1)
    }

    func test_clearSearchAfterCategory_showsCategoryOnly() async {
        mockService.jobsToReturn = [
            .fixture(id: 1, title: "iOS Engineer", categoryName: "Software Development"),
            .fixture(id: 2, title: "Android Dev", categoryName: "Software Development"),
            .fixture(id: 3, title: "Marketer", categoryName: "Marketing")
        ]
        await viewModel.loadJobs()
        await viewModel.applyCategory("Software Development")
        await viewModel.applySearch("")
        XCTAssertEqual(viewModel.jobs.count, 2)
    }

    // MARK: - State

    func test_initialState_isIdle() {
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertTrue(viewModel.jobs.isEmpty)
        XCTAssertFalse(viewModel.hasMorePages)
    }

    func test_categories_listIsNotEmpty() {
        XCTAssertFalse(viewModel.categories.isEmpty)
    }

    func test_pageSize_isTen() {
        XCTAssertEqual(viewModel.pageSize, 10)
    }
}

import Foundation
import Combine

enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}

@MainActor
final class JobListViewModel: ObservableObject {
    @Published private(set) var jobs: [RemoteJob] = []
    @Published var state: ViewState = .idle
    @Published var searchText: String = ""
    @Published var selectedCategory: String = ""
    @Published private(set) var isLoadingMore = false
    @Published private(set) var hasMorePages = false

    let pageSize = 10

    private var allJobs: [RemoteJob] = []
    private var filteredJobs: [RemoteJob] = []
    private var currentPage = 0

    private let jobService: JobServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var suppressSearchObserver = false

    let categories = [
        "Software Development",
        "Design",
        "Marketing",
        "DevOps / Sysadmin",
        "Customer Service",
        "Finance / Legal",
        "Sales",
        "Product",
        "Writing",
        "Data and Analytics",
        "Artificial Intelligence"
    ]

    init(jobService: JobServiceProtocol) {
        self.jobService = jobService
        observeSearch()
    }

    // MARK: - Search observer (UI typing only — bypassed by applySearch/_)

    private func observeSearch() {
        $searchText
            .dropFirst()
            .debounce(for: .milliseconds(350), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self, !self.suppressSearchObserver else { return }
                self.applyFiltersAndReset()
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API

    func loadJobs() async {
        switch state {
        case .idle, .empty, .error: break
        default: return
        }
        await fetchAndReset()
    }

    func refresh() async {
        suppressSearchObserver = true
        searchText = ""
        selectedCategory = ""
        suppressSearchObserver = false
        if let js = jobService as? JobService { js.clearCache() }
        await fetchAndReset()
    }

    // async so the UI can call `Task { await viewModel.applyCategory(cat) }` or `await` directly.
    // applyFiltersAndReset() is called synchronously so state is updated before this returns.
    func applySearch(_ query: String) async {
        suppressSearchObserver = true
        searchText = query
        suppressSearchObserver = false
        applyFiltersAndReset()
    }

    func applyCategory(_ category: String) async {
        suppressSearchObserver = true
        selectedCategory = category
        suppressSearchObserver = false
        applyFiltersAndReset()
    }

    func loadNextPage() async {
        guard hasMorePages, !isLoadingMore else { return }
        isLoadingMore = true
        let nextPage = currentPage + 1
        let slice = pageSlice(page: nextPage)
        try? await Task.sleep(nanoseconds: 50_000_000)
        jobs.append(contentsOf: slice)
        currentPage = nextPage
        hasMorePages = (currentPage * pageSize) < filteredJobs.count
        isLoadingMore = false
    }

    // MARK: - Private helpers

    private func fetchAndReset() async {
        // Yield once so the first @Published mutation never fires inside a view update cycle.
        await Task.yield()
        state = .loading
        jobs = []
        allJobs = []
        filteredJobs = []
        currentPage = 0
        hasMorePages = false

        do {
            allJobs = try await jobService.fetchAllJobs()
        } catch {
            state = .error(error.localizedDescription)
            return
        }

        applyFiltersAndReset()
    }

    private func applyFiltersAndReset() {
        filteredJobs = allJobs.filter { job in
            let matchesCategory = selectedCategory.isEmpty
                || job.categoryName.localizedCaseInsensitiveContains(selectedCategory)
            let q = searchText.trimmingCharacters(in: .whitespaces)
            let matchesSearch = q.isEmpty
                || job.title.localizedCaseInsensitiveContains(q)
                || job.companyName.localizedCaseInsensitiveContains(q)
                || job.categoryName.localizedCaseInsensitiveContains(q)
            return matchesCategory && matchesSearch
        }

        currentPage = 0
        let firstSlice = pageSlice(page: 1)
        jobs = firstSlice
        currentPage = firstSlice.isEmpty ? 0 : 1
        hasMorePages = filteredJobs.count > pageSize
        state = jobs.isEmpty ? .empty : .loaded
    }

    private func pageSlice(page: Int) -> [RemoteJob] {
        let start = (page - 1) * pageSize
        guard start < filteredJobs.count else { return [] }
        let end = min(start + pageSize, filteredJobs.count)
        return Array(filteredJobs[start..<end])
    }
}

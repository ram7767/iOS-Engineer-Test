import XCTest
import SwiftUI
@testable import iOS_Engineer_Test

/// Renders SwiftUI views via UIHostingController so their `body` getters
/// execute and are counted by xccov, without requiring XCUITest.
@MainActor
final class ViewRenderingTests: XCTestCase {

    private var window: UIWindow!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
    }

    override func tearDown() {
        window = nil
        super.tearDown()
    }

    private func render<V: View>(_ view: V) {
        let host = UIHostingController(rootView: view)
        window.rootViewController = host
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
    }

    // MARK: - StateView components

    func test_loadingView_renders() {
        render(LoadingView())
    }

    func test_emptyStateView_renders_withoutAction() {
        render(EmptyStateView(title: "Empty", message: "Nothing here."))
    }

    func test_emptyStateView_renders_withAction() {
        render(EmptyStateView(title: "Empty", message: "Nothing.", action: {}, actionLabel: "Retry"))
    }

    func test_emptyStateView_renders_customSystemImage() {
        render(EmptyStateView(
            title: "No Jobs",
            message: "Try a different filter.",
            systemImage: "magnifyingglass",
            action: {}
        ))
    }

    func test_errorStateView_renders() {
        render(ErrorStateView(message: "Could not connect.") {})
    }

    // MARK: - SavedJobsView

    func test_savedJobsView_renders_empty() {
        let service = MockSavedJobsService()
        let vm = SavedJobsViewModel(savedJobsService: service)
        render(
            NavigationStack {
                SavedJobsView(viewModel: vm)
                    .environment(\.savedJobsService, service)
            }
        )
    }

    func test_savedJobsView_renders_withJobs() {
        let service = MockSavedJobsService()
        service.save(job: .fixture(id: 1))
        service.save(job: .fixture(id: 2))
        let vm = SavedJobsViewModel(savedJobsService: service)
        render(
            NavigationStack {
                SavedJobsView(viewModel: vm)
                    .environment(\.savedJobsService, service)
            }
        )
    }

    // MARK: - JobDetailView

    func test_jobDetailView_renders_unsaved() {
        let service = MockSavedJobsService()
        render(
            NavigationStack {
                JobDetailView(job: .fixture(), savedJobsService: service)
            }
        )
    }

    func test_jobDetailView_renders_savedJob() {
        let service = MockSavedJobsService()
        let job = RemoteJob.fixture(id: 42)
        service.save(job: job)
        render(
            NavigationStack {
                JobDetailView(job: job, savedJobsService: service)
            }
        )
    }

    func test_jobDetailView_renders_withLongDescription() {
        let service = MockSavedJobsService()
        let longDesc = String(repeating: "We are hiring. ", count: 100)
        render(
            NavigationStack {
                JobDetailView(
                    job: .fixture(description: longDesc),
                    savedJobsService: service
                )
            }
        )
    }

    func test_jobDetailView_renders_htmlDescription() {
        let service = MockSavedJobsService()
        render(
            NavigationStack {
                JobDetailView(
                    job: .fixture(description: "<p>We need a <strong>senior iOS dev</strong>.</p>"),
                    savedJobsService: service
                )
            }
        )
    }

    func test_jobDetailView_renders_withLogo() {
        let service = MockSavedJobsService()
        render(
            NavigationStack {
                JobDetailView(
                    job: .fixture(companyLogoURL: "https://example.com/logo.png"),
                    savedJobsService: service
                )
            }
        )
    }

    func test_jobDetailView_renders_noSalary() {
        let service = MockSavedJobsService()
        render(
            NavigationStack {
                JobDetailView(
                    job: .fixture(salary: ""),
                    savedJobsService: service
                )
            }
        )
    }

    // MARK: - String.strippingHTML

    func test_strippingHTML_removesBasicTags() {
        let html = "<p>Hello <strong>world</strong></p>"
        let result = html.strippingHTML()
        XCTAssertFalse(result.contains("<"))
        XCTAssertTrue(result.contains("Hello"))
        XCTAssertTrue(result.contains("world"))
    }

    func test_strippingHTML_plainTextUnchanged() {
        let plain = "No HTML here"
        XCTAssertEqual(plain.strippingHTML(), plain)
    }

    func test_strippingHTML_emptyString() {
        XCTAssertEqual("".strippingHTML(), "")
    }

    func test_strippingHTML_nestedTags() {
        let html = "<div><ul><li>Item 1</li><li>Item 2</li></ul></div>"
        let result = html.strippingHTML()
        XCTAssertFalse(result.contains("<div>"))
        XCTAssertTrue(result.contains("Item"))
    }
}

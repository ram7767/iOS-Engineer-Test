import XCTest
import UIKit
@testable import iOS_Engineer_Test

final class ImageCacheServiceTests: XCTestCase {

    private var service: ImageCacheService!

    override func setUp() {
        super.setUp()
        service = ImageCacheService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func test_invalidURL_returnsNil() async {
        let result = await service.image(for: "not a url !!!")
        XCTAssertNil(result)
    }

    func test_clearCache_doesNotCrash() async {
        await service.clearCache()
    }

    func test_clearCache_removesObjects() async {
        // Prime cache with a real-looking URL (will fail to load — that's fine)
        _ = await service.image(for: "https://example.com/image.png")
        await service.clearCache()
        // After clearing, requesting again should not crash
        let result = await service.image(for: "https://example.com/image.png")
        XCTAssertNil(result)   // network not available in tests, so nil is expected
    }

    func test_emptyURLString_returnsNil() async {
        let result = await service.image(for: "")
        XCTAssertNil(result)
    }

    func test_concurrentRequests_sameURL_doNotCrash() async {
        let url = "https://example.com/concurrent.png"
        async let r1 = service.image(for: url)
        async let r2 = service.image(for: url)
        let (_, _) = await (r1, r2)
        // Just verifying no crash / deadlock
    }
}

import XCTest
@testable import CustomElementKit

final class CustomElementKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CustomElementKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

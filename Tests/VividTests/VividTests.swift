import XCTest
@testable import Vivid

final class VividTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Vivid().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

import XCTest
@testable import msbar

final class msbarTests: XCTestCase {
    func testClockFormatterFormat() {
        let formatter = makeClockFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        // 2024-01-02 03:04:05.678 UTC
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 2
        components.hour = 3
        components.minute = 4
        components.second = 5
        components.nanosecond = 678_000_000
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)!

        let result = formatter.string(from: date)
        XCTAssertEqual(result, "03:04:05.678")
    }
}

import XCTest
@testable import msbar

final class msbarTests: XCTestCase {
    func testClockFormatterFormat() {
        let formatter = makeClockFormatter(for: .hmsMilliseconds)
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

    func testClockFormatterVariants() {
        let date = Date(timeIntervalSince1970: 1_708_810_645.345) // 2024-03-05T19:50:45.345Z
        let timeZoneUTC = TimeZone(secondsFromGMT: 0)

        let hms = makeClockFormatter(for: .hms)
        hms.timeZone = timeZoneUTC
        XCTAssertEqual(hms.string(from: date), "19:50:45")

        let hm = makeClockFormatter(for: .hourMinute)
        hm.timeZone = timeZoneUTC
        XCTAssertEqual(hm.string(from: date), "19:50")

        let split = makeClockFormatter(for: .hmsSplitMilliseconds)
        split.timeZone = timeZoneUTC
        XCTAssertEqual(split.string(from: date), "19:50:45\n345")

        let ms = makeClockFormatter(for: .msMilliseconds)
        ms.timeZone = timeZoneUTC
        XCTAssertEqual(ms.string(from: date), "50:45.345")
    }
}

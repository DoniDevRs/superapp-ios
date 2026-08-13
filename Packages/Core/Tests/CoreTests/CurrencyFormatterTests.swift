import XCTest
@testable import Core

final class CurrencyFormatterTests: XCTestCase {
    func test_decimalFromTypedDigits_convertsCentsCorrectly() {
        XCTAssertEqual(CurrencyFormatter.decimal(fromTypedDigits: "25000"), Decimal(250))
        XCTAssertEqual(CurrencyFormatter.decimal(fromTypedDigits: "5"), Decimal(0.05))
        XCTAssertEqual(CurrencyFormatter.decimal(fromTypedDigits: ""), Decimal(0))
    }

    func test_string_formatsAsBRL() {
        let result = CurrencyFormatter.string(from: Decimal(250))
        XCTAssertTrue(result.contains("250"))
    }
}

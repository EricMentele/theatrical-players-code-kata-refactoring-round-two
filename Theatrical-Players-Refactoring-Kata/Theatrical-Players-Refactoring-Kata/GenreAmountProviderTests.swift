import XCTest
@testable import Theatrical_Players_Refactoring_Kata

class GenreAmountProviderTests: XCTestCase {
    func test_amountFor_throwsErrorOnNewPlayGenre() throws {
        let sut = GenreCostProvider()
        
        XCTAssertThrowsError(try sut.amountFor(genre: "always new"))
    }
    
    func test_amountFor_hasCorrectCostWhenHighVolume() throws {
        let sut = GenreCostProvider()
        let cases: [(String, Int)] = [
            ("tragedy", 55),
            ("comedy", 35)
        ]
        let expected = [
            "tragedy": 650,
            "comedy": 580
        ]
        
        for testCase in cases {
            XCTAssertEqual(try sut.amountFor(genre: testCase.0)(testCase.1), expected[testCase.0]!)
        }
    }
}

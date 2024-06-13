import XCTest
@testable import Theatrical_Players_Refactoring_Kata

class GenreAmountProviderTests: XCTestCase {
    func test_amountFor_throwsErrorOnNewPlayGenre() throws {
        let sut = GenreDollarCostProvider()
        
        XCTAssertThrowsError(try sut.amountFor(genre: "always new"))
    }
    
    func test_amountFor_hasCorrectCostWhenHighVolume() throws {
        let sut = GenreDollarCostProvider()
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
    
    func test_amountFor_hasCorrectCostWhenBaseVolume() throws {
        let sut = GenreDollarCostProvider()
        let cases: [(String, Int)] = [
            ("pastoral", 30),
            ("history", 30)
        ]
        let expected = [
            "pastoral": 400,
            "history": 400
        ]
        
        for testCase in cases {
            XCTAssertEqual(try sut.amountFor(genre: testCase.0)(testCase.1), expected[testCase.0]!)
        }
    }
}

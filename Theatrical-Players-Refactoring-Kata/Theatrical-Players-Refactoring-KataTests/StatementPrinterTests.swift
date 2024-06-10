
import XCTest
@testable import Theatrical_Players_Refactoring_Kata

struct GenreCostProvider: GenreAmountProvider {
    func amountFor(genre: String) throws -> AmountCalculator {
        switch (genre) {
        case "tragedy" :
            return { attendance in
                var result = 40000
                if (attendance > 30) {
                    result += 1000 * (attendance - 30)
                }
                return result / 100
            }
        case "comedy" :
            return { attendance in
                var result = 30000
                if (attendance > 20) {
                    result += 10000 + 500 * (attendance - 20)
                }
                return (result + 300 * attendance) / 100
            }
        default:
            throw GenreError.newGenre
        }
    }
    
    enum GenreError: Error {
        case newGenre
    }
}

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

class StatementPrinterTests: XCTestCase {
    func test_exampleStatement() throws {
        
        let expected = """
            Statement for BigCo
              Hamlet: $650.00 (55 seats)
              As You Like It: $580.00 (35 seats)
              Othello: $500.00 (40 seats)
            Amount owed is $1,730.00
            You earned 47 credits

            """
        
        let plays = [
            "hamlet": Play(name: "Hamlet", genre: "tragedy"),
            "as-like": Play(name: "As You Like It", genre: "comedy"),
            "othello": Play(name: "Othello", genre: "tragedy")
        ]
        
        let invoice = Invoice(
            customer: "BigCo", performances: [
                Performance(playID: "hamlet", audience: 55),
                Performance(playID: "as-like", audience: 35),
                Performance(playID: "othello", audience: 40)
            ]
        )
        
        let sut: StatementProvider = StatementPrinter()
        let statementDataProvider: StatementDataProvider = StatementPrinter()
        let statementData = try statementDataProvider.statementData(invoice, plays)
        let result = sut.formattedStatement(from: statementData)
        
        XCTAssertEqual(result, expected)
    }
    
    func test_statementWithNewPlayTypes() {
        let plays = [
            "henry-v": Play(name: "Henry V", genre: "history"),
            "as-like": Play(name: "As You Like It", genre: "pastoral")
        ]
        
        let invoice = Invoice(
            customer: "BigCo", performances: [
                Performance(playID: "henry-v", audience: 53),
                Performance(playID: "as-like", audience: 55)
            ]
        )
        
        let sut: StatementDataProvider = StatementPrinter()
        
        XCTAssertThrowsError(try sut.statementData(invoice, plays))
    }
    
    func test_print_throwsErrorOnUnkownPlayType() {
        let plays = [
            "hamlet": Play(name: "Hamlet", genre: "tragedy"),
            "as-like": Play(name: "As You Like It", genre: "comedy")
        ]
        
        let invoice = Invoice(
            customer: "BigCo", performances: [
                Performance(playID: "hamlet", audience: 55),
                Performance(playID: "as-like", audience: 35),
                Performance(playID: "othello", audience: 40)
            ]
        )
        
        let sut: StatementDataProvider = StatementPrinter()
        
        XCTAssertThrowsError(try sut.statementData(invoice, plays))
    }
}


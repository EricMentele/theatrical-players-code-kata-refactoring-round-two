import Foundation

struct GenreDollarCostProvider: GenreAmountProvider {
    func amountFor(genre: String) throws -> AmountCalculator {
        switch (genre) {
        case "tragedy", "pastoral", "history" :
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

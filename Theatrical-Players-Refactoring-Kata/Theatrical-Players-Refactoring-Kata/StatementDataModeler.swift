final class StatementDataModeler: StatementDataProvider {
    let genreCostProvider: GenreAmountProvider
    
    init(genreCostProvider: GenreAmountProvider = GenreDollarCostProvider()) {
        self.genreCostProvider = genreCostProvider
    }
    
    func statementData(_ invoice: Invoice, _ plays: Dictionary<String, Play>) throws -> StatementData {
        return try StatementData(
            customerName: invoice.customer,
            charges: invoice.performances.map(statementCostLineData),
            totalCost: invoice.performances.map(statementCostLineData).reduce(into: 0) { $0 += $1.1 },
            totalVolumeCredits: totalVolumeCreditsFor(invoice.performances)
        )
        // MARK: Helpers
        
        func statementCostLineData(_ performance: Performance) throws -> StatementData.Charge {
            (try playFor(playID: performance.playID).name,
             try genreCostProvider.amountFor(genre: try playFor(playID: performance.playID).genre)(performance.audience),
             performance.audience)
        }
        
        func totalVolumeCreditsFor(_ performances: [Performance]) throws -> Int {
            var result = 0
            for performance in invoice.performances {
                // add volume credits
                result += volumeCreditsFor(genre: try playFor(playID: performance.playID).genre, audienceCount: performance.audience)
            }
            
            return result
        }
        
        func volumeCreditsFor(genre: String, audienceCount: Int) -> Int {
            // add volume credits
            var result = max(audienceCount - 30, 0)
            // add extra credit for every ten comedy attendees
            if ("comedy" == genre) {
                result += Int(round(Double(audienceCount / 5)))
            }
            return result
        }
        
        func playFor(playID: String) throws -> Play {
            guard let play = plays[playID] else {
                throw UnknownTypeError.unknownTypeError("unknown play")
            }
            
            return play
        }
    }
}

extension StatementDataModeler {
    enum UnknownTypeError: Error {
        case unknownTypeError(String)
    }
}

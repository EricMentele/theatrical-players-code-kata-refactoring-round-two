protocol StatementProvider {
    func formattedStatement(from statementData: StatementData) -> String
}

protocol StatementDataProvider {
    func statementData(_ invoice: Invoice, _ plays: Dictionary<String, Play>) throws -> StatementData
}

protocol GenreAmountProvider {
    typealias AmountCalculator = (Int) -> Int
    
    func amountFor(genre: String) throws -> AmountCalculator
}

struct StatementData {
    typealias Charge = (
        playName: String,
        amount: Int,
        attendanceCount: Int
    )
    
    let customerName: String
    let charges: [Charge]
    let totalCost: Int
    let totalVolumeCredits: Int
}

class StatementPrinter: StatementProvider {
    let genreCostProvider: GenreAmountProvider
    
    func formattedStatement(from statementData: StatementData) -> String {
        var result = "Statement for \(statementData.customerName)\n"
        
        let frmt = NumberFormatter()
        frmt.numberStyle = .currency
        frmt.locale = Locale(identifier: "en_US")
        
        for costLineItem in statementData.charges {
            // print line for this order
            result += "  \(costLineItem.0):" + " \(frmt.string(for: NSNumber(value: Double((costLineItem.1))))!)" + " (\(costLineItem.2) seats)\n"
        }
        result += "Amount owed is \(frmt.string(for: NSNumber(value: Double(statementData.totalCost)))!)\n"
        result += "You earned \(statementData.totalVolumeCredits) credits\n"
        return result
    }
    
    init(genreCostProvider: GenreAmountProvider = GenreDollarCostProvider()) {
        self.genreCostProvider = genreCostProvider
    }
}

extension StatementPrinter: StatementDataProvider {
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

enum UnknownTypeError: Error {
    case unknownTypeError(String)
}

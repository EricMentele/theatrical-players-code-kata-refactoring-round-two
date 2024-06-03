class StatementPrinter {
    func print(_ invoice: Invoice, _ plays: Dictionary<String, Play>) throws -> String {
        var volumeCredits = 0
        var result = "Statement for \(invoice.customer)\n"
        
        let frmt = NumberFormatter()
        frmt.numberStyle = .currency
        frmt.locale = Locale(identifier: "en_US")
        
        for performance in invoice.performances {
            // add volume credits
            volumeCredits += volumeCreditsFor(genre: try playFor(playID: performance.playID).type, audienceCount: performance.audience)
            
            // print line for this order
            result += "  \(try playFor(playID: performance.playID).name): \(frmt.string(for: NSNumber(value: Double((try performanceDollarCostTotalFor(genre: try playFor(playID: performance.playID).type, attendance: performance.audience)))))!) (\(performance.audience) seats)\n"
        }
        result += "Amount owed is \(frmt.string(for: NSNumber(value: Double(try totalCostOf(invoice.performances))))!)\n"
        result += "You earned \(volumeCredits) credits\n"
        return result
        
        func volumeCreditsFor(genre: String, audienceCount: Int) -> Int {
            // add volume credits
            var result = max(audienceCount - 30, 0)
            // add extra credit for every ten comedy attendees
            if ("comedy" == genre) {
                volumeCredits += Int(round(Double(audienceCount / 5)))
            }
            return result
        }
        
        func totalCostOf(_ performances: [Performance]) throws -> Int {
            var result = 0
            for performance in performances {
                result += try performanceDollarCostTotalFor(genre: try playFor(playID: performance.playID).type, attendance: performance.audience)
            }
            return result
        }
        
        func playFor(playID: String) throws -> Play {
            guard let play = plays[playID] else {
                throw UnknownTypeError.unknownTypeError("unknown play")
            }
            
            return play
        }
        
        func performanceDollarCostTotalFor(genre: String, attendance: Int) throws -> Int {
            var cost: Int = 0
            
            switch (genre) {
            case "tragedy" :
                cost = 40000
                if (attendance > 30) {
                    cost += 1000 * (attendance - 30)
                }
                
            case "comedy" :
                cost = 30000
                if (attendance > 20) {
                    cost += 10000 + 500 * (attendance - 20)
                }
                cost += 300 * attendance
                
            default : throw UnknownTypeError.unknownTypeError("unknown type: \(genre)")
            }
            
            return cost / 100
        }
    }
}

enum UnknownTypeError: Error {
    case unknownTypeError(String)
}

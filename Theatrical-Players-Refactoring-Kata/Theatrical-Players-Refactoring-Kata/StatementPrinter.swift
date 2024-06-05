class StatementPrinter {
    struct StatementData {
        let customerName: String
        let costLineItemsData: [(String, Int, Int)]
    }
    
    func formattedStatementText(_ invoice: Invoice, _ plays: Dictionary<String, Play>) throws -> String {
        let statementData = StatementData(
            customerName: invoice.customer,
            costLineItemsData: try invoice.performances.map(statementLineData)
        )
        var result = "Statement for \(statementData.customerName)\n"
        
        let frmt = NumberFormatter()
        frmt.numberStyle = .currency
        frmt.locale = Locale(identifier: "en_US")
        
        for costLineItem in statementData.costLineItemsData {
            // print line for this order
            result += "  \(costLineItem.0):" + " \(frmt.string(for: NSNumber(value: Double((costLineItem.1))))!)" + " (\(costLineItem.2) seats)\n"
        }
        result += "Amount owed is \(frmt.string(for: NSNumber(value: Double(try totalCostOf(invoice.performances))))!)\n"
        result += "You earned \(try totalVolumeCreditsFor(invoice.performances)) credits\n"
        return result
        
        // MARK: Helpers
        
        func statementLineData(_ performance: Performance) throws -> (String, Int, Int) {
            (try playFor(playID: performance.playID).name,
             try performanceDollarCostTotalFor(genre: try playFor(playID: performance.playID).type, attendance: performance.audience),
             performance.audience)
        }
        
        func totalVolumeCreditsFor(_ performances: [Performance]) throws -> Int {
            var result = 0
            for performance in invoice.performances {
                // add volume credits
                result += volumeCreditsFor(genre: try playFor(playID: performance.playID).type, audienceCount: performance.audience)
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

class StatementPrinter {
    func print(_ invoice: Invoice, _ plays: Dictionary<String, Play>) throws -> String {
        var totalAmount = 0
        var volumeCredits = 0
        var result = "Statement for \(invoice.customer)\n"
        
        let frmt = NumberFormatter()
        frmt.numberStyle = .currency
        frmt.locale = Locale(identifier: "en_US")
        
        for performance in invoice.performances {
            guard let play = plays[performance.playID] else {
                throw UnknownTypeError.unknownTypeError("unknown play")
            }
            
            // add volume credits
            volumeCredits += max(performance.audience - 30, 0)
            // add extra credit for every ten comedy attendees
            if ("comedy" == play.type) {
                volumeCredits += Int(round(Double(performance.audience / 5)))
            }
            
            // print line for this order
            result += "  \(play.name): \(frmt.string(for: NSNumber(value: Double((try performanceDollarCostTotalFor(genre: play.type, attendance: performance.audience)))))!) (\(performance.audience) seats)\n"
            
            totalAmount += try performanceDollarCostTotalFor(genre: play.type, attendance: performance.audience)
        }
        result += "Amount owed is \(frmt.string(for: NSNumber(value: Double(totalAmount)))!)\n"
        result += "You earned \(volumeCredits) credits\n"
        return result
        
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

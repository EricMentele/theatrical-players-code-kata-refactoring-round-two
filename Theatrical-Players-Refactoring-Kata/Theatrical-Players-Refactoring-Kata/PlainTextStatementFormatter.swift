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

class PlainTextStatementFormatter: StatementProvider {
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
}

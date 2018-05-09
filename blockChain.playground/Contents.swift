//: Playground - noun: a place where people can play

import Cocoa

class Transaction : Codable {
    var from: String
    var to: String
    var amount: Double
    
    init(from: String, to: String, amount: Double) {
        self.from = from
        self.to = to
        self.amount = amount
    }
}

class Block {
    var index: Int = 0
    var previousHash: String = ""
    var hash: String!
    var nonce: Int
    private (set) var transactions: [Transaction] = [Transaction]()
    
    var key: String {
        get {
            let transactionsData = try! JSONEncoder().encode(self.transactions)
            let transactionsJSONString = String(data: transactionsData, encoding: .utf8)
            
            return String(self.index) + self.previousHash + String(self.nonce) + transactionsJSONString!
        }
    }
    
    func addTransaction(transaction: Transaction) {
        self.transactions.append(transaction)
    }
    
    init() {
        self.nonce = 0
    }
}

class Blockchain {
    private (set) var blocks: [Block] = [Block]()
    
    init(genesisBlock: Block) {
        addBlock(genesisBlock)
    }
    
    private func addBlock(_ block: Block) {
        if self.blocks.isEmpty {
            block.previousHash = "0000000000"
            block.hash = generateHash(for: block)
        }
        
        self.blocks.append(block)
    }
    
    func generateHash(for block: Block) -> String {
        var hash = block.key.sha1Hash()
        return hash
    }
}

// String Extension
extension String {
    func sha1Hash() -> String {
        let task = Process()
        task.launchPath = "/usr/bin/shasum"
        task.arguments = []
        
        let inputPipe = Pipe()
        inputPipe.fileHandleForWriting.write(self.data(using: String.Encoding.utf8)!)
        inputPipe.fileHandleForWriting.closeFile()
        
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardInput = inputPipe
        task.launch()
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let hash = String(data: data, encoding: String.Encoding.utf8)!
        return hash.replacingOccurrences(of: "-\n", with: "")
    }
}

let genesisBlock = Block()
let blockChain = Blockchain(genesisBlock: genesisBlock)

let transaction = Transaction(from: "Mary", to: "Steve", amount: 20)

let block1 = Block()
block1.addTransaction(transaction: transaction)
block1.key

import UIKit

/**
 JAVA version
 */

struct Request {
    let amount: Int
    let type: String
}

protocol Handler {
    var successor: Handler? { get set }

    func handle(request: Request)
}

class BaseHandler: Handler {
    var successor: Handler?

    func handle(request: Request) {
        fatalError()
    }
}

class Manager: BaseHandler {
    override func handle(request: Request) {
        if request.amount < 10 {
            print("approved! By Manager")
        } else {
            if let successor = self.successor {
                successor.handle(request: request)
            }
        }
    }
}

class VP: BaseHandler {
    override func handle(request: Request) {
        if request.type == "PTO" {
            print("reject! by VP")
            return
        }
        if request.type == "promote" && request.amount < 50 {
            print("approved! By VP")
        } else {
            if let successor = self.successor {
                successor.handle(request: request)
            }
        }
    }
}

class CEO: BaseHandler {
    override func handle(request: Request) {
        print("deny by CEO")
    }
}

let manager = Manager()
let vp = VP()
let ceo = CEO()
manager.successor = vp
vp.successor = ceo

let request1 = Request(amount: 5, type: "PTO")
let request2 = Request(amount: 10, type: "PTO")
let request3 = Request(amount: 60, type: "protooooo")

manager.handle(request: request1)
manager.handle(request: request2)
manager.handle(request: request3)

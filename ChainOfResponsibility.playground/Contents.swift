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


/**
 Swift Design pattern version
 */


struct Message {
    let from:String
    let to:String
    let subject:String
}

class LocalTransmitter {
    func sendMessage(_ message: Message) {
        print("Message to \(message.to) sent locally")
    }
}

class RemoteTransmitter {
    func sendMessage(_ message: Message) {
        print("Message to \(message.to) sent remotely")
    }
}

class PriorityTransmitter {
    func sendMessage(_ message: Message) {
        print("Message to \(message.to) sent as priority");
    }
}

let messages = [
    Message(from: "bob@example.com", to: "joe@example.com",
            subject: "Free for lunch?"),
    Message(from: "joe@example.com", to: "alice@acme.com",
            subject: "New Contracts"),
    Message(from: "pete@example.com", to: "all@example.com",
            subject: "Priority: All-Hands Meeting"),
]

let localT = LocalTransmitter();
let remoteT = RemoteTransmitter();
let priorityT = PriorityTransmitter();

for msg in messages {
    if msg.subject.hasPrefix("Priority") {
        priorityT.sendMessage(msg);
    } else if let index = msg.from.firstIndex(of: "@") {
        if msg.to.hasSuffix(msg.from[index..<msg.from.endIndex]) {
            localT.sendMessage(msg);
        } else {
            remoteT.sendMessage(msg);
        }
    } else {
        print("Error: cannot send message to \(msg.from)");
    }
}


class Transmitter {
    var nextLink:Transmitter?;
    required init() {}
    func sendMessage(_ message:Message) {
        if (nextLink != nil) {
            nextLink!.sendMessage(message);
        } else {
            print("End of chain reached. Message not sent");
        }
    }

    class func matchEmailSuffix(_ message:Message) -> Bool {
        if let index = message.from.firstIndex(of: "@") {
            return message.to.hasSuffix(message.from[index..<message.from.endIndex])
        }
        return false;
    }

    class func createChain() -> Transmitter? {
        let transmitterClasses:[Transmitter.Type] = [
            PriorityTransmitterV2.self,
            LocalTransmitterV2.self,
            RemoteTransmitterV2.self
        ];

        var link:Transmitter?;
        for tClass in transmitterClasses.reversed() {
            let existingLink = link;
            link = tClass.init();
            link?.nextLink = existingLink;
        }
        return link;
    }
}

class LocalTransmitterV2 : Transmitter {
    override func sendMessage(_ message: Message) {
        if (Transmitter.matchEmailSuffix(message)) {
            print("Message to \(message.to) sent locally");
        } else {
            super.sendMessage(message);
        } }
}

class RemoteTransmitterV2 : Transmitter {
    override func sendMessage(_ message: Message) {
        if (!Transmitter.matchEmailSuffix(message)) {
            print("Message to \(message.to) sent remotely");
        } else {
            super.sendMessage(message);
        } }
}

class PriorityTransmitterV2 : Transmitter {
    override func sendMessage(_ message: Message) {
        if (message.subject.hasPrefix("Priority")) {
            print("Message to \(message.to) sent as priority");
        } else {
            super.sendMessage(message);
        } }
}

if let chain = Transmitter.createChain() {
    for msg in messages {
        chain.sendMessage(msg);
    }
}

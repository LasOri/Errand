//
//  Errand.swift
//  Errand
//
//  Created by LasOri on 2019. 06. 24..
//  Copyright © 2019. LasOri. All rights reserved.
//

import Foundation

enum Land {
    case mein
    case land(String)
}

class Errand<T> {
    
    typealias QuestsClosure = () throws -> T?
    
    private var wanderlustLand: Land?
    
    private lazy var wanderlustQueue: OperationQueue = {
        var queue = OperationQueue()
        guard let land = wanderlustLand else {
            queue.name = "Errand"
            return queue
        }
        switch land {
        case .mein:
            queue = OperationQueue.main
        case .land(let name):
            queue.name = name
        }
        return queue
    }()

    init() {
        
    }
    
    func wanderlust(on land: Land) -> Errand {
        wanderlustLand = land
        return self
    }

    func startQuests(questsHandler: @escaping QuestsClosure) {
        wanderlustQueue.addOperation {
            try! questsHandler()
        }
    }
}

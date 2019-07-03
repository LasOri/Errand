//
//  Errand.swift
//  Errand
//
//  Created by LasOri on 2019. 06. 24..
//  Copyright © 2019. LasOri. All rights reserved.
//

import Foundation

enum QuestError: Error, Equatable {
    case questFailed(String)
}

prefix operator !&
@discardableResult
prefix func !&<T>(operand: Quest<T>) throws -> T? {
    var reward: T?
    var err: Error?
    let group = DispatchGroup()
    group.enter()
    operand.earn { result in
        switch result {
        case .success(let value):
            reward = value
        case .failure(let error):
            err = error
        }
        group.leave()
    }
    let timeoutResult = group.wait(timeout: DispatchTime.now() + operand.questTime)
    switch timeoutResult {
    case .timedOut:
        throw QuestError.questFailed("Quest time expired!")
    case .success: break
    }
    if let error = err {
        throw error
    }
    return reward
}

@discardableResult
prefix func !&<T>(operand: (Quest<T>) throws -> ()) throws -> T? {
    var reward: T?
    do {
        let quest = try <&operand as! Quest<T>
        reward = try !&quest
    } catch {
        throw error
    }
    return reward
}

enum Land {
    case mein
    case land(String)
}

class Errand<T> {
    
    typealias QuestsClosure = () throws -> T?
    typealias RewardClosure = (T) -> ()
    typealias TombClosure = (Error) -> ()
    
    private var wanderlustLand: Land?
    private var arrivalLand: Land?
    
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
    
    private lazy var arrivalQueue: OperationQueue = {
        var queue = OperationQueue.main
        guard let land = arrivalLand else {
            return queue
        }
        switch land {
        case .mein:
            break
        case .land(let name):
            queue = OperationQueue()
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

    func arrival(on land: Land) -> Errand {
        arrivalLand = land
        return self
    }
    
    func startQuests(questsHandler: @escaping QuestsClosure, rewardHandler: RewardClosure? = nil, willHandler: TombClosure? = nil) {
        wanderlustQueue.addOperation {
            do {
                if let reward = try questsHandler() {
                    self.arrivalQueue.addOperation {
                        rewardHandler?(reward)
                    }
                }
            } catch {
                self.arrivalQueue.addOperation {
                    willHandler?(error)
                }
            }
        }
    }
}

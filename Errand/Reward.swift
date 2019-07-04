//
//  Reward.swift
//  Errand
//
//  Created by LasOri on 2019. 07. 02..
//  Copyright © 2019. LasOri. All rights reserved.
//

import Foundation

class Reward<Treasure> {
    
    typealias RewardCallback = (Result<Treasure, Error>) -> ()
    
    var reward: Result<Treasure, Error>? {
        didSet { reward.map(report) }
    }
    
    private lazy var callbacks = [RewardCallback]()
    
    func earn(with callback: @escaping RewardCallback) {
        callbacks.append(callback)
        reward.map(callback)
    }
    
    private func report(reward: Result<Treasure, Error>) {
        callbacks.forEach { $0(reward) }
    }
    
}

extension Reward {
    func follow<NextValue>(with closure: @escaping (Treasure) throws -> Reward<NextValue>) -> Reward<NextValue> {
        let quest = Quest<NextValue>()
        earn { result in
            switch result {
            case .success(let value):
                do {
                    let reward = try closure(value)
                    reward.earn(with: { result in
                        switch result {
                        case .success(let value):
                            quest.win(the: value)
                        case .failure(let error):
                            quest.die(by: error)
                        }
                    })
                } catch {
                    quest.die(by: error)
                }
            case .failure(let error):
                quest.die(by: error)
            }
        }
        return quest
    }
}

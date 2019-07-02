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


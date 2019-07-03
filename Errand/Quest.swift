//
//  Quest.swift
//  Errand
//
//  Created by LasOri on 2019. 07. 02..
//  Copyright © 2019. LasOri. All rights reserved.
//

import Foundation

prefix operator <&
@discardableResult 
prefix func <&<T>(operand: (Quest<T>) throws -> ()) throws -> Reward<T> {
    let quest = Quest<T>()
    try operand(quest)
    return quest
}

class Quest<Treasure>: Reward<Treasure> {
    
    var questTime: Double = 30
    
    init(treasure: Treasure? = nil) {
        super.init()

        if let treasure = treasure {
            reward = .success(treasure)
        }
    }
    
    func win(the treasure: Treasure) {
        reward = .success(treasure)
    }

    func die(by cause: Error) {
        reward = .failure(cause)
    }
    
}

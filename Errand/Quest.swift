//
//  Quest.swift
//  Errand
//
//  Created by LasOri on 2019. 07. 02..
//  Copyright © 2019. LasOri. All rights reserved.
//

import Foundation

class Quest<Treasure>: Reward<Treasure> {
    
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

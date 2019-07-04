//
//  RewardTests.swift
//  ErrandTests
//
//  Created by LasOri on 2019. 07. 02..
//  Copyright © 2019. LasOri. All rights reserved.
//

import XCTest
@testable import Errand

class RewardTests: XCTestCase {
    
    let timeout = 3.0

    func testEarn() {
        let reward = Reward<String>()
        let expectedResult = "expectedResult"
        var returnedResult: Result<String, Error>!
        
        let expectation = XCTestExpectation(description: "waitForReward")
        reward.earn { result in
            returnedResult = result
            expectation.fulfill()
        }
    
        reward.reward = .success(expectedResult)
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(.completed, waiterResult)
        XCTAssertEqual(expectedResult, try! returnedResult.get())
    }

    func testFollow() {
        let expectedResult = "third"
        var results = ["first", "second", expectedResult]
        let rewardClosure: (Quest<String>) -> () = { quest in
            DispatchQueue(label: "test").asyncAfter(deadline: .now() + 2, execute: {
                quest.win(the: results.remove(at: 0))
            })
        }
        
        let reward = try! <&rewardClosure
     
        let result = try! !&(reward
            .follow { value -> Reward<String> in
                return try! <&rewardClosure
            }
            .follow(with: { value -> Reward<String> in
                return try! <&rewardClosure
            }) as! Quest<String>)
        
        XCTAssertEqual(expectedResult, result)
    }
    
}

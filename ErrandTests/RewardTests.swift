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
            expectation.fulfill()
            returnedResult = result
        }
    
        reward.reward = .success(expectedResult)
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(.completed, waiterResult)
        XCTAssertEqual(expectedResult, try! returnedResult.get())
    }

}

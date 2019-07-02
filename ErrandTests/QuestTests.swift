//
//  QuestTests.swift
//  ErrandTests
//
//  Created by LasOri on 2019. 07. 02..
//  Copyright © 2019. LasOri. All rights reserved.
//

import XCTest
@testable import Errand

class QuestTests: XCTestCase {

    let timeout = 3.0
    
    func testInit() {
        let expectedReward = "extectedReward"
        
        let quest = Quest<String>(treasure: expectedReward)
        
        XCTAssertEqual(expectedReward, try! quest.reward?.get())
    }
    
    func testWin() {
        let quest = Quest<String>()
        let expectedResult = "expectedResult"
        var returnedResult: Result<String, Error>!
        
        let expectation = XCTestExpectation(description: "waitForReward")
        quest.earn { result in
            returnedResult = result
            expectation.fulfill()
        }
        
        quest.win(the: expectedResult)
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(.completed, waiterResult)
        XCTAssertEqual(expectedResult, try! returnedResult.get())
    }
    
    func testDie() {
        enum TestError: Error, Equatable {
            case expectedError
        }
        
        let quest = Quest<String>()
        var returnedError: TestError!
        
        let expectation = XCTestExpectation(description: "waitForReward")
        quest.earn { result in
            switch result {
            case .success( _):
                break
            case .failure(let error):
                returnedError = error as? TestError
            }
            expectation.fulfill()
        }
        
        quest.die(by: TestError.expectedError)
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(.completed, waiterResult)
        XCTAssertEqual(TestError.expectedError, returnedError)
    }
    
    func testRewardCreator() {
        let expectedResult = "expectedResult"
        var returnedResult = "returnedResult"
        
        let rewardClosure: (Quest<String>) -> () = { quest in
            DispatchQueue(label: "test").asyncAfter(deadline: .now() + 2, execute: {
                quest.win(the: expectedResult)
            })
        }
        
        let reward = try! <&rewardClosure
        
        let expectation = XCTestExpectation(description: "waitForReward")
        reward.earn { result in
            returnedResult = try! result.get()
            expectation.fulfill()
        }
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(.completed, waiterResult)
        XCTAssertEqual(expectedResult, returnedResult)
    }
}

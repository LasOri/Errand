//
//  ErrandTests.swift
//  ErrandTests
//
//  Created by LasOri on 2019. 06. 24..
//  Copyright © 2019. LasOri. All rights reserved.
//

import XCTest
@testable import Errand

class ErrandTests: XCTestCase {
    
    enum TestError: Error, Equatable {
        case expectedError
    }
    
    let timeout = 2.0

    func testWanderlust_when_landIsGiven() {
        let expectedQueueName = "Dream"
        var returnedQueueName: String!
        
        let errand = Errand<String>()
            .wanderlust(on: .land(expectedQueueName))
        
        let expectation = XCTestExpectation(description: "waitForResult")
        errand.startQuests(questsHandler: { () -> String? in
            returnedQueueName = OperationQueue.current!.name
            expectation.fulfill()
            return nil
        })
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(.completed, waiterResult)
        XCTAssertEqual(expectedQueueName, returnedQueueName)
    }
    
    func testWanderlust_when_landIsNotGiven() {
        let expectedQueueName = "Errand"
        var returnedQueueName: String!
        
        let errand = Errand<String>()
        
        let expectation = XCTestExpectation(description: "waitForResult")
        errand.startQuests(questsHandler: { () -> String? in
            returnedQueueName = OperationQueue.current!.name
            expectation.fulfill()
            return nil
        })
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(.completed, waiterResult)
        XCTAssertEqual(expectedQueueName, returnedQueueName)
    }
    
    func testArrival_when_landIsGiven() {
        let expectedQueueName = "Dream"
        let expectedResult = "result"
        var returnedQueueName: String!
        var returnedResult: String!
        
        let errand = Errand<String>()
            .arrival(on: .land(expectedQueueName))
        
        let expectation = XCTestExpectation(description: "waitForResult")
        errand.startQuests(questsHandler: { () -> String? in
            return expectedResult
        }, rewardHandler: { (result) in
            returnedResult = result
            returnedQueueName = OperationQueue.current!.name
            expectation.fulfill()
        }, willHandler: nil)
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(.completed, waiterResult)
        XCTAssertEqual(expectedQueueName, returnedQueueName)
        XCTAssertEqual(expectedResult, returnedResult)
    }
    
    func testArrival_when_landIsNotGiven() {
        let expectedQueueName = OperationQueue.main.name
        let expectedResult = "result"
        var returnedQueueName: String!
        var returnedResult: String!
        
        let errand = Errand<String>()
        
        let expectation = XCTestExpectation(description: "waitForResult")
        errand.startQuests(questsHandler: { () -> String? in
            return expectedResult
        }, rewardHandler: { (result) in
            returnedResult = result
            returnedQueueName = OperationQueue.current!.name
            expectation.fulfill()
        }, willHandler: nil)
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(.completed, waiterResult)
        XCTAssertEqual(expectedQueueName, returnedQueueName)
        XCTAssertEqual(expectedResult, returnedResult)
    }
    
    func testArrival_when_landIsGiven_errorHappens() {
        let expectedQueueName = "Dream"
        var returnedQueueName: String!
        var returnedError: TestError!
        
        let errand = Errand<String>()
            .arrival(on: .land(expectedQueueName))
        
        let expectation = XCTestExpectation(description: "waitForResult")
        errand.startQuests(questsHandler: { () -> String? in
            throw TestError.expectedError
        }, rewardHandler: nil, willHandler: { error in
            returnedQueueName = OperationQueue.current!.name
            returnedError = error as? ErrandTests.TestError
            expectation.fulfill()
        })
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(.completed, waiterResult)
        XCTAssertEqual(expectedQueueName, returnedQueueName)
        XCTAssertEqual(TestError.expectedError, returnedError)
    }
    
    func testArrival_when_landIsNotGiven_errorHappens() {
        let expectedQueueName = OperationQueue.main.name
        var returnedQueueName: String!
        var returnedError: TestError!
        
        let errand = Errand<String>()
        
        let expectation = XCTestExpectation(description: "waitForResult")
        errand.startQuests(questsHandler: { () -> String? in
            throw TestError.expectedError
        }, rewardHandler: nil, willHandler: { error in
            returnedQueueName = OperationQueue.current!.name
            returnedError = error as? ErrandTests.TestError
            expectation.fulfill()
        })
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(.completed, waiterResult)
        XCTAssertEqual(expectedQueueName, returnedQueueName)
        XCTAssertEqual(TestError.expectedError, returnedError)
    }
    
    func testQuestWaiter_withQuest() {
        let expectedResult = "result"
        
        let rewardClosure: (Quest<String>) -> () = { quest in
            DispatchQueue(label: "test").asyncAfter(deadline: .now() + 2, execute: {
                quest.win(the: expectedResult)
            })
        }
        let reward = try! <&rewardClosure
        let quest = reward as! Quest<String>
        
        let returnedResult = try! !&quest
        
        XCTAssertEqual(expectedResult, returnedResult)
    }
    
    func testQuestWaiter_withQuestClosure() {
        let expectedResult = "result"
        
        let questClosure: (Quest<String>) -> () = { quest in
            DispatchQueue(label: "test").asyncAfter(deadline: .now() + 2, execute: {
                quest.win(the: expectedResult)
            })
        }
        
        let returnedResult = try! !&questClosure
        
        XCTAssertEqual(expectedResult, returnedResult)
    }
    
    func testQuestWaiter_withTimeOut() {
        let expectedResult = "result"
        
        let rewardClosure: (Quest<String>) -> () = { quest in
            DispatchQueue(label: "test").asyncAfter(deadline: .now() + self.timeout + 2, execute: {
                quest.win(the: expectedResult)
            })
        }
        let reward = try! <&rewardClosure
        let quest = reward as! Quest<String>
        quest.questTime = timeout
        
        XCTAssertThrowsError(try !&quest)
    }
}

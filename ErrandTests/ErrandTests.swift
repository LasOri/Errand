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
    
    let timeout = 3.0

    func testWanderlust() {
        let expectedQueueName = "Dream"
        var returnedQueueName: String!
        
        let errand = Errand<String>()
            .wanderlust(on: .land(expectedQueueName))
        
        let expectation = XCTestExpectation(description: "waitForResult")
        errand.startQuests { () -> String? in
            returnedQueueName = OperationQueue.current!.name
            expectation.fulfill()
            return nil
        }
        
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(.completed, waiterResult)
        XCTAssertEqual(expectedQueueName, returnedQueueName)
    }
}

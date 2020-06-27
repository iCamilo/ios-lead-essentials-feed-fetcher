//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedFetcher

extension FeedStoreSpecs where Self: XCTestCase {
	
	func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: .success(nil), file: file, line: line)
	}
	
	func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieveTwice: .success(nil), file: file, line: line)
	}
	
	func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed()
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)
		
        expect(sut, toRetrieve: .success( CachedFeed(feed: feed, timestamp: timestamp) ), file: file, line: line)
	}
	
	func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed()
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)
		
        expect(sut, toRetrieveTwice: .success( CachedFeed(feed: feed, timestamp: timestamp) ), file: file, line: line)
	}
	
	func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let insertionError = insert((uniqueImageFeed(), Date()), to: sut)
		
		XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
	}
	
	func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed(), Date()), to: sut)
		
		let insertionError = insert((uniqueImageFeed(), Date()), to: sut)
		
		XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
	}
	
	func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed(), Date()), to: sut)
		
		let latestFeed = uniqueImageFeed()
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), to: sut)
		
		expect(sut, toRetrieve: .success( CachedFeed(feed: latestFeed, timestamp: latestTimestamp) ), file: file, line: line)
	}

	func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
	}
	
	func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .success(nil), file: file, line: line)
	}

	func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed(), Date()), to: sut)
		
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
	}
	
	func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed(), Date()), to: sut)
		
		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .success(nil), file: file, line: line)
	}
	
	func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		var completedOperationsInOrder = [XCTestExpectation]()
		
		let op1 = expectation(description: "Operation 1")
		sut.insert(uniqueImageFeed(), timestamp: Date()) { _ in
			completedOperationsInOrder.append(op1)
			op1.fulfill()
		}
		
		let op2 = expectation(description: "Operation 2")
		sut.deleteCachedFeed { _ in
			completedOperationsInOrder.append(op2)
			op2.fulfill()
		}
		
		let op3 = expectation(description: "Operation 3")
		sut.insert(uniqueImageFeed(), timestamp: Date()) { _ in
			completedOperationsInOrder.append(op3)
			op3.fulfill()
		}
		
		waitForExpectations(timeout: 5.0)
		
		XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
	}

}

extension FeedStoreSpecs where Self: XCTestCase {
	func uniqueImageFeed() -> [LocalFeedImage] {
		return [uniqueImage(), uniqueImage()]
	}
	
	func uniqueImage() -> LocalFeedImage {
		return LocalFeedImage(id: UUID(), url: anyURL(), description: "any", location: "any")
	}
	
	func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}

	@discardableResult
	func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache insertion")
		var insertionError: Error?
		sut.insert(cache.feed, timestamp: cache.timestamp) { insertionResult in
            switch insertionResult {
            case let.failure(receivedInsertionError):
                insertionError = receivedInsertionError
            default: break
            }
			
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return insertionError
	}
	
	@discardableResult
	func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache deletion")
		var deletionError: Error?
		sut.deleteCachedFeed { deletionResult in
            switch deletionResult {
            case let .failure(receivedDeletionError):
                deletionError = receivedDeletionError
            default: break
            }
			
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return deletionError
	}
	
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
	
	func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for cache retrieval")
		
		sut.retrieveCachedFeed { retrievedResult in
			switch (expectedResult, retrievedResult) {
			case (.success(nil), .success(nil)),
				 (.failure, .failure):
				break
				
            case let (.success( .some(expectedCache) ),
                      .success( .some(retrievedCache) )):
                XCTAssertEqual(retrievedCache.feed, expectedCache.feed, file: file, line: line)
                XCTAssertEqual(retrievedCache.timestamp, expectedCache.timestamp, file: file, line: line)
				
			default:
				XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
}

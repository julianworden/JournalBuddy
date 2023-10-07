//
//  Sequence+filter.swift
//  JournalBuddy
//
//  Created by Julian Worden on 10/6/23.
//

extension Sequence {
    /// Filters a specified number of elements in a sequence when those elements adhere to a given criteria. Ideal
    /// for filtering a large sequence while also avoiding iterating through elements unnecessarily after a desired sequence
    /// size has been reached.
    ///
    /// To avoid performance issues with `reserveCapacity(_:)` only use this method when the array that's
    /// returned is guaranteed to reach the given limit.
    /// Source: https://stackoverflow.com/questions/41871861/limit-the-results-of-a-swift-array-filter-to-x-for-performance
    /// - Parameters:
    ///   - isIncluded: A closure that receives each element of the sequence one at a time and determines whether or not
    ///     each element should be included in the returned sequence. Returns `true` if it should be included.
    ///   - limit: The maximum number of elements that can be included in the returned array.
    /// - Returns: The filtered array with a maximum count determined by `limit` that adheres to the criteria set in `isIncluded`.
    public func filter(where isIncluded: (Iterator.Element) -> Bool, limit: Int) -> [Iterator.Element] {
        var result = [Iterator.Element]()
        result.reserveCapacity(limit)
        var count = 0
        var iterator = makeIterator()

        while count < limit, let element = iterator.next() {
            if isIncluded(element) {
                result.append(element)
                count += 1
            }
        }
        
        return result
    }
}

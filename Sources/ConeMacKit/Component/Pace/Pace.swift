//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation

public typealias PaceThen<T> = ((PaceResult<T>) -> Void)

public enum PaceResult<T> {
    case success(T)
    case failure(Error)
}

public extension PaceResult {
    static private func unit(x: T) -> PaceResult<T> {
        .success(x)
    }
    
    func map<U>(_ f: (T) throws -> U) -> PaceResult<U> {
        flatMap({
            PaceResult<U>.unit(x: try f($0))
        })
    }
    
    func flatMap<U>(_ f: (T) throws -> PaceResult<U>) -> PaceResult<U> {
        switch self {
        case .success(let value):
            do {
                return try f(value)
            } catch let e {
                return .failure(e)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

public struct Pace<T> {
    private let trunk: ((@escaping PaceThen<T>) -> Void)!
    
    public init(_ trunk: ((@escaping PaceThen<T>) -> Void)!) {
        self.trunk = trunk
    }
    
    public func excute(_ callback: ((PaceResult<T>) -> Void)!) {
        trunk(callback)
    }
}

public extension Pace {
    static private func unit(x: T) -> Pace<T> {
        Pace<T>.init({
            $0(.success(x))
        })
    }
    
    func map<U>(_ f: ((T) throws -> U)!) -> Pace<U> {
        flatmap({
            Pace<U>.unit(x: try f($0))
        })
    }
    
    func flatmap<U>(_ f: ((T) throws -> Pace<U>)!) -> Pace<U> {
        Pace<U>.init { (cont) in
            excute({
                switch $0.map(f) {
                case .success(let async):
                    async.excute(cont)
                case .failure(let error):
                    cont(.failure(error))
                }
            })
        }
    }
    
    func then<U>(_ f: ((T, PaceThen<U>?) -> Void)!) -> Pace<U> {
        Pace<U>.init { (cont) in
            excute { (res) in
                switch res {
                case .success(let value):
                    f(value, cont)
                case .failure(let error):
                    cont(.failure(error))
                }
            }
        }
    }
    
    func schedule(queue: DispatchQueue = .main, after: TimeInterval = 0) -> Pace<T> {
        Pace<T>.init { (cont) in
            excute { (then) in
                queue.asyncAfter(deadline: .now() + after) {
                    switch then {
                    case .success(let value):
                        cont(.success(value))
                    case .failure(let error):
                        cont(.failure(error))
                    }
                }
            }
        }
    }
}


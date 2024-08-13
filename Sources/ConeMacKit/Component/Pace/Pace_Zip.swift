//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation

public extension Pace {
    static func zip<T2>(_ t1: Pace<T>, _ t2: Pace<T2>) -> Pace<(T, T2)> {
        Pace<(T, T2)>.init { (then) in
            
            var error: Error? = nil
            
            var t1Result: T?
            var t2Result: T2?
            
            func checkResult() {
                if let t1r = t1Result,
                   let t2r = t2Result {
                    then(.success((t1r, t2r)))
                }
            }
            
            func checkError(_ err: Error) {
                if error == nil {
                    error = err
                    then(.failure(err))
                }
            }
            
            t1.excute { (thenT1) in
                switch thenT1 {
                case .success(let valueT1):
                    t1Result = valueT1
                    checkResult()
                    break
                case .failure(let error):
                    checkError(error)
                    break
                }
            }
            
            t2.excute { (thenT2) in
                switch thenT2 {
                case .success(let valueT2):
                    t2Result = valueT2
                    checkResult()
                    break
                case .failure(let error):
                    checkError(error)
                    break
                }
            }
            
        }
    }
    
    static func zip<T2, T3>(_ t1: Pace<T>, _ t2: Pace<T2>, _ t3: Pace<T3>) -> Pace<(T, T2, T3)> {
        Pace<(T, T2, T3)>.init { (then) in
            
            var error: Error? = nil
            
            var t1Result: T?
            var t2Result: T2?
            var t3Result: T3?
            
            func checkResult() {
                if let t1r = t1Result,
                   let t2r = t2Result,
                   let t3r = t3Result {
                    then(.success((t1r, t2r, t3r)))
                }
            }
            
            func checkError(_ err: Error) {
                if error == nil {
                    error = err
                    then(.failure(err))
                }
            }
            
            t1.excute { (thenT1) in
                switch thenT1 {
                case .success(let valueT1):
                    t1Result = valueT1
                    checkResult()
                    break
                case .failure(let error):
                    checkError(error)
                    break
                }
            }
            
            t2.excute { (thenT2) in
                switch thenT2 {
                case .success(let valueT2):
                    t2Result = valueT2
                    checkResult()
                    break
                case .failure(let error):
                    checkError(error)
                    break
                }
            }
            
            t3.excute { (thenT3) in
                switch thenT3 {
                case .success(let valueT3):
                    t3Result = valueT3
                    checkResult()
                    break
                case .failure(let error):
                    checkError(error)
                    break
                }
            }
            
        }
    }
    
    static func zip<T2, T3, T4>(_ t1: Pace<T>, _ t2: Pace<T2>, _ t3: Pace<T3>, _ t4: Pace<T4>) -> Pace<(T, T2, T3, T4)> {
        Pace<(T, T2, T3, T4)>.init { (then) in
            
            var error: Error? = nil
            
            var t1Result: T?
            var t2Result: T2?
            var t3Result: T3?
            var t4Result: T4?
            
            func checkResult() {
                if let t1r = t1Result,
                   let t2r = t2Result,
                   let t3r = t3Result,
                   let t4r = t4Result {
                    then(.success((t1r, t2r, t3r, t4r)))
                }
            }
            
            func checkError(_ err: Error) {
                if error == nil {
                    error = err
                    then(.failure(err))
                }
            }
            
            t1.excute { (thenT1) in
                switch thenT1 {
                case .success(let valueT1):
                    t1Result = valueT1
                    checkResult()
                    break
                case .failure(let error):
                    checkError(error)
                    break
                }
            }
            
            t2.excute { (thenT2) in
                switch thenT2 {
                case .success(let valueT2):
                    t2Result = valueT2
                    checkResult()
                    break
                case .failure(let error):
                    checkError(error)
                    break
                }
            }
            
            t3.excute { (thenT3) in
                switch thenT3 {
                case .success(let valueT3):
                    t3Result = valueT3
                    checkResult()
                    break
                case .failure(let error):
                    checkError(error)
                    break
                }
            }
            
            t4.excute { (thenT4) in
                switch thenT4 {
                case .success(let valueT4):
                    t4Result = valueT4
                    checkResult()
                    break
                case .failure(let error):
                    checkError(error)
                    break
                }
            }
            
        }
    }
}

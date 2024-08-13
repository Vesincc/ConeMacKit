//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation

@dynamicMemberLookup
public struct Setter<Subject> {
    
    public init(_ subject: Subject) {
        self.subject = subject
    }
    
    public let subject: Subject
     
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Subject, Value>) -> ((Value) -> Setter<Subject>) {
        var subject = self.subject
        return { value in
            subject[keyPath: keyPath] = value
            return Setter(subject)
        }
    }
    
    public func excute(_ callback: (Subject) -> ()) -> Setter<Subject> {
        callback(self.subject)
        return Setter(subject)
    }
    
    public func apply() {
    }
}

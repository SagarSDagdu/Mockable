//
//  AccessModifierTests.swift
//
//
//  Created by Nayanda Haberty on 29/5/24.
//

import MacroTesting
import XCTest
import SwiftSyntax
@testable import Mockable

final class AccessModifierTests: MockableMacroTestCase {
    func test_public_modifier() {
        assertMacro {
            """
            @Mockable
            public protocol Test {
                init(id: String)
                var foo: Int { get }
                func bar(number: Int) -> Int
            }
            """
        } expansion: {
            """
            public protocol Test {
                init(id: String)
                var foo: Int { get }
                func bar(number: Int) -> Int
            }

            #if MOCKING
            public final class MockTest: Test, MockableService {
                private let mocker = Mocker<MockTest>()
                @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
                public func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
                public func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
                public func verify(with assertion: @escaping MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                public func reset(_ scopes: Set<MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                public init(policy: MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                public init(id: String) {
                }
                public func bar(number: Int) -> Int {
                    let member: Member = .m2_bar(number: .value(number))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> Int
                        return producer(number)
                    }
                }
                public var foo: Int {
                    get {
                        let member: Member = .m1_foo
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                public enum Member: Matchable, CaseIdentifiable {
                    case m1_foo
                    case m2_bar(number: Parameter<Int>)
                    public func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        case (.m2_bar(number: let leftNumber), .m2_bar(number: let rightNumber)):
                            return leftNumber.match(rightNumber)
                        default:
                            return false
                        }
                    }
                }
                public struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    public init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    public var foo: FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m1_foo)
                    }
                    public func bar(number: Parameter<Int>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, Int, (Int) -> Int> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
                public struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    public init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    public var foo: FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                    public func bar(number: Parameter<Int>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
                public struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    public init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    public var foo: FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo, assertion: assertion)
                    }
                    public func bar(number: Parameter<Int>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_bar(number: number), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_private_access_modifier() {
        assertMacro {
          """
          @Mockable
          private protocol Test {
              var foo: Int { get }
              func bar(number: Int) -> Int
          }
          """
        } expansion: {
            """
            private protocol Test {
                var foo: Int { get }
                func bar(number: Int) -> Int
            }

            #if MOCKING
            private final class MockTest: Test, MockableService {
                private let mocker = Mocker<MockTest>()
                @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
                func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
                func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
                func verify(with assertion: @escaping MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                func reset(_ scopes: Set<MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                init(policy: MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                func bar(number: Int) -> Int {
                    let member: Member = .m2_bar(number: .value(number))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> Int
                        return producer(number)
                    }
                }
                var foo: Int {
                    get {
                        let member: Member = .m1_foo
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_foo
                    case m2_bar(number: Parameter<Int>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        case (.m2_bar(number: let leftNumber), .m2_bar(number: let rightNumber)):
                            return leftNumber.match(rightNumber)
                        default:
                            return false
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    var foo: FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m1_foo)
                    }
                    func bar(number: Parameter<Int>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, Int, (Int) -> Int> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    var foo: FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                    func bar(number: Parameter<Int>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    var foo: FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo, assertion: assertion)
                    }
                    func bar(number: Parameter<Int>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_bar(number: number), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_mutating_modifier_filtered() {
        assertMacro {
            """
            @Mockable
            public protocol Test {
                mutating nonisolated func foo()
            }
            """
        } expansion: {
            """
            public protocol Test {
                mutating nonisolated func foo()
            }

            #if MOCKING
            public final class MockTest: Test, MockableService {
                private let mocker = Mocker<MockTest>()
                @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
                public func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
                public func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
                public func verify(with assertion: @escaping MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                public func reset(_ scopes: Set<MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                public init(policy: MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                public nonisolated func foo() {
                    let member: Member = .m1_foo
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as () -> Void
                        return producer()
                    }
                }
                public enum Member: Matchable, CaseIdentifiable {
                    case m1_foo
                    public func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        }
                    }
                }
                public struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    public init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    public func foo() -> FunctionReturnBuilder<MockTest, ReturnBuilder, Void, () -> Void> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                public struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    public init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    public func foo() -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                public struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    public init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    public func foo() -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo, assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }
}

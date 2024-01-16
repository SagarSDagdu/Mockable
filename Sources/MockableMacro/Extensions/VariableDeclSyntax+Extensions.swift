//
//  VariableDeclSyntax+Extensions.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 10..
//

import SwiftSyntax

extension VariableDeclSyntax {
    var name: TokenSyntax {
        get throws {
            .identifier(try binding.pattern.trimmedDescription)
        }
    }

    var isComputed: Bool { setAccessor == nil }

    var isThrowing: Bool {
        get throws { try getAccessor.effectSpecifiers?.throwsSpecifier != nil }
    }

    var resolvedType: TypeSyntax {
        get throws {
            let type = try type
            if let type = type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
                return type.wrappedType
            }
            return type
        }
    }

    var type: TypeSyntax {
        get throws {
            guard let typeAnnotation = try binding.typeAnnotation else {
                throw MockableMacroError.invalidVariableRequirement
            }
            return typeAnnotation.type.trimmed
        }
    }

    var getAccessor: AccessorDeclSyntax {
        get throws {
            let getAccessor = try accessors.first { $0.accessorSpecifier.tokenKind == .keyword(.get) }
            guard let getAccessor else { throw MockableMacroError.invalidVariableRequirement }
            return getAccessor
        }
    }

    var setAccessor: AccessorDeclSyntax? {
        try? accessors.first { $0.accessorSpecifier.tokenKind == .keyword(.set) }
    }

    var closureType: FunctionTypeSyntax {
        get throws {
            return FunctionTypeSyntax(
                parameters: TupleTypeElementListSyntax(),
                effectSpecifiers: .init(
                    throwsSpecifier: try isThrowing ? .keyword(.throws) : nil
                ),
                returnClause: .init(type: try resolvedType)
            )
        }
    }

    var binding: PatternBindingSyntax {
        get throws {
            guard let binding = bindings.first else {
                throw MockableMacroError.invalidVariableRequirement
            }
            return binding
        }
    }
}

// MARK: - Helpers

extension VariableDeclSyntax {
    private var accessors: AccessorDeclListSyntax {
        get throws {
            guard let accessorBlock = try binding.accessorBlock,
                  case .accessors(let accessorList) = accessorBlock.accessors else {
                throw MockableMacroError.invalidVariableRequirement
            }
            return accessorList
        }
    }
}

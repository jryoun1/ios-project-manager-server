//
//  CreateTodo.swift
//  
//
//  Created by Yeon on 2021/03/18.
//

import Fluent

struct CreateTodo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Todo.schema)
            .id()
            .field("title", .string, .required)
            .field("description", .string)
            .field("deadline", .datetime)
            .field("status", .int, .required)
            .field("status_index", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Todo.schema).delete()
    }
}

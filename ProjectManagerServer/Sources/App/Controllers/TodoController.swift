//
//  TodoController.swift
//  
//
//  Created by Yeon on 2021/03/18.
//

import Fluent
import Vapor

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos")
        todos.get(use: readAll)
        
        let todo = routes.grouped("todo")
        todo.post(use: create)
        todo.group(":id") { todo in
            todo.patch(use: update)
            todo.get(use: read)
            todo.delete(use: delete)
        }
    }
    
    func readAll(req: Request) throws -> EventLoopFuture<[Todo]> {
        return Todo.query(on: req.db).all()
    }
    
    func read(req: Request) throws -> EventLoopFuture<Todo> {
        return Todo.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func create(req: Request) throws -> EventLoopFuture<Todo> {
        let todo = try req.content.decode(Todo.self)
        return todo.save(on: req.db).map { todo }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Todo.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
    
    private func checkContentType(_ req: Request) throws {
        guard let contentType = req.headers.contentType,
              contentType == .json else {
            throw Abort(.unsupportedMediaType)
        }
    }
}


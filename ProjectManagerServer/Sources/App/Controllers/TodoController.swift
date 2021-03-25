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
        let todoRoutes = routes.grouped("todos")
        todoRoutes.post(use: createHandler)
        todoRoutes.get(use: getAllHandler)
        todoRoutes.get(":todoID", use: getHandler)
        todoRoutes.patch(":todoID", use: updateHandler)
        todoRoutes.delete(":todoID", use: deleteHandler)
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Todo> {
        let todo = try req.content.decode(Todo.self)
        return todo.save(on: req.db).map { todo }
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Todo]> {
        Todo.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<Todo> {
        Todo.find(req.parameters.get("todoID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Todo> {
        let updatedTodo = try req.content.decode(Todo.self)
        return Todo.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { todo in
                todo.title = updatedTodo.title
                todo.description = updatedTodo.description
                todo.deadline = updatedTodo.deadline
                todo.status = updatedTodo.status
                
                return todo.save(on: req.db).map {
                    todo
                }
            }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Todo.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { todo in
                todo.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
}


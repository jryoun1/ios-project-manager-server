import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.post("todo") { req -> EventLoopFuture<Todo> in
        let exist = try req.content.decode(Todo.self)
        
        return exist.create(on: req.db).map { (result) -> Todo in
            return exist
        }
    }

    app.get("todos") { req -> EventLoopFuture<[Todo]> in
        Todo.query(on: req.db).all()
    }
    
    app.get("todos", ":todoID") { req -> EventLoopFuture<Todo> in
        Todo.find(req.parameters.get("todoID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    app.patch("todos", ":todoID") { req -> EventLoopFuture<Todo> in
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
    
    app.delete("todos", ":todoID") { req -> EventLoopFuture<HTTPStatus> in
        Todo.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { todo in
                todo.delete(on: req.db).transform(to: .noContent)
            }
    }
    
    //try app.register(collection: TodoController())
}

import Vapor
import HTTP
import VaporPostgreSQL

let drop = Droplet()
drop.preparations.append(Friend.self)

do {
    try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
    assertionFailure("Error adding provider: \(error)")
}

// user pages routings

// home page
// http://0.0.0.0:8080
drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

// simple test for server  ( it is a REST JSON, to be moved .. )
// http://0.0.0.0:8080/data/1
drop.get("data", Int.self) { request, int in
    return try JSON(node: [
        "int": int,
        "name": request.data["name"]?.string ?? "no name"
    ])
}

// some test  ( hello page )
// http://0.0.0.0:8080/hello
drop.get("hello") { request in
  let name = request.data["name"]?.string ?? "stranger"

  return try drop.view.make("hello", [
    "name": name
  ])
}

// some test  ( page with image )
drop.get("html") { req in
  let response = Response(status: .ok, body: "<html><img src=http://www.w3schools.com/html/pic_mountain.jpg></html>")
  response.headers["Content-Type"] = "text/html"
  return response
}

//===========================
//  REST JSON
//===========================

//===========================
// GET all
// http://0.0.0.0:8080/all
drop.get("all") { req in
    let friends = try Friend.all().makeNode()
    let friendsDictionary = ["friends": friends]
    return try JSON(node: friendsDictionary)
}

//===========================
// GET single record
// http://0.0.0.0:8080/friend/1     GET method
drop.get("friend", Int.self) { req, userID in

  // what is UserID
  drop.log.info("get  req:   userID=\(userID)")
    guard let friend = try Friend.find(userID) else {
        throw Abort.notFound
    }
    return try friend.makeJSON()
}

//===========================
// POST a new record
/*
  curl -X POST -H "Content-Type: application/json" -d '{ "age": 60, "email": "OSZ99@e.com", "id": 3333, "name": "Yet Other Other brother"  }' http://0.0.0.0:8080/friend
*/
drop.post("friend") { req in
    //drop.log.info("post  req:\(req.json)")
    var friend = try Friend(node: req.json)
    try friend.save()
    return try friend.makeJSON()
}

//::::: the same !!!! different page name ...  with trace
drop.post("user") { req in
    let json = req.json

    //
    drop.log.info("post  req:\(json)")

    var friend = try Friend(node: req.json)
    try friend.save()
    return try friend.makeJSON()
}
//:::::

//===========================
// DELETE a new record
// http://0.0.0.0:8080/friend/1     DELETE method
drop.delete("friend", Int.self) { req, userID in

  // what is UserID
  drop.log.info("delete  req:   userID=\(userID)")
  // should test and delete here....

  // what to return ? here indicate userID that has been deleted ?
  return try JSON(node: [
      "userID": userID
    ])
  }

//===========================
// PUT in order to change a record
// shouldl test a PUT for changing a record ?
// http://0.0.0.0:8080/friends/1     PUT method
drop.put("friend", Int.self) { req, userID in

  // what is UserID
  drop.log.info("put  req:   userID=\(userID)")
  // should test and delete here....

  // what to return ? here indicate userID that has been deleted ?
  return try JSON(node: [
      "userID": userID
    ])
  }

// ------ end of REST JSON
//===========================


//  Vapor incantations....

drop.resource("posts", PostController())

drop.run()

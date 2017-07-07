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

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.get("all") { req in
    let friends = try Friend.all().makeNode()
    let friendsDictionary = ["friends": friends]
    return try JSON(node: friendsDictionary)
}

drop.get("friends", Int.self) { req, userID in
    guard let friend = try Friend.find(userID) else {
        throw Abort.notFound
    }
    return try friend.makeJSON()
}

drop.get("hello") { request in
  let name = request.data["name"]?.string ?? "stranger"

  return try drop.view.make("hello", [
    "name": name
  ])
}


drop.post("friend") { req in
    var friend = try Friend(node: req.json)
    try friend.save()
    return try friend.makeJSON()
}

drop.get("html") { req in
  let response = Response(status: .ok, body: "<html><img src=http://www.w3schools.com/html/pic_mountain.jpg></html>")
  response.headers["Content-Type"] = "text/html"
  return response
}

drop.resource("posts", PostController())

drop.run()

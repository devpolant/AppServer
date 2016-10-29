import Vapor
import VaporMongo

let drop = Droplet()

do {
    try drop.addProvider(VaporMongo.Provider.self)
    debugPrint("Database initialized")
} catch {
    print(error)
}

//Socket failed with code 60 ("Device not a stream") [connectFailed] "Unknown error"

drop.addConfigurable(middleware: LoginMiddleware(), name: "login")

let usersController = UsersController()
drop.get("login", handler: usersController.userLogin)



drop.get { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "title"]
        ])
}
debugPrint("Run droplet")
drop.run()

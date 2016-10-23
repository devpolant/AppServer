import Vapor
import VaporMongo

let drop = Droplet()

do {
    try drop.addProvider(VaporMongo.Provider.self)
} catch {
    print(error)
}

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.run()

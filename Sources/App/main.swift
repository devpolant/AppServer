import Foundation
import Vapor
import VaporMongo
import Auth
import Cookies


let drop = Droplet()


//MARK: - Providers

do {
    try drop.addProvider(VaporMongo.Provider.self)
    debugPrint("Database initialized")
} catch {
    print(error)
}
drop.preparations = [
    Customer.self,
    Merchant.self,
    MenuCategory.self,
    MenuItem.self
]


//MARK: - Controllers

let userController = CustomerController(droplet: drop)
userController.setup()

let merchantController = MerchantController(droplet: drop)
merchantController.setup()

let menuController = MenuController(droplet: drop)
menuController.setup()

let ordersController = OrdersController(droplet: drop)
ordersController.setup()

let placesController = PlacesController(droplet: drop)
placesController.setup()


//MARK: - Routing

drop.get { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "title"]
        ])
}

debugPrint("Run Droplet")

drop.run()


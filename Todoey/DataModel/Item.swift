//
//  Item.swift
//  Todoey
//
//  Created by Marcin Miasko on 06/07/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

//klasa musi spełniać protokół Encodable żeby można było ją serializować w celu
//zapisania obiektów w pliku
//oraz protokół Decodable, żeby można było do obiektu dekodować/deserializować
//dane z pliku.
//Wymogiem Encodable jest by korzystać wewnątrz ze zmiennych podstawowych typów danych
// Encodable + Decodable   ===>>> Codable
class Item : Codable {
    var title : String = ""
    var done: Bool = false
}

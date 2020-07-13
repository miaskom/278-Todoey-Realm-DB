//
//  Category.swift
//  Todoey
//
//  Created by Marcin Miasko on 11/07/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

//klasa dla danych w Realm - musi dzidziczyć po Object
class Category: Object{
    //dynamic oznacza, że Realm może dynamicznie aktualizować zmiany w bazie
    //gdy zmieni się warość zmiennej (@objc - bo to własciwość z Objectove-C)
    @objc dynamic var name: String = ""
    //lista Itemsów (inicjalizacja pustej listy)
    let items = List<Item>()
}

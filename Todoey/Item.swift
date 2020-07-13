//
//  Item.swift
//  Todoey
//
//  Created by Marcin Miasko on 11/07/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

//klasa dla danych w Realm - musi dzidziczyć po Object
class Item: Object{
    //dynamic oznacza, że Realm może dynamicznie aktualizować zmiany w bazie
    //gdy zmieni się warość zmiennej (@objc - bo to własciwość z Objectove-C)
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var createdDate: Date?
    
    //zmienna do relacji odwrotnej - w Category jest lista Items'ów a w Itemsach
    //dodajemy relację do rodzica jako LinkingObject  Category to tylko klasa a nie typ
    //aby uzyskać typ klasy trzeba użyć .self;  property - nazwa pola listy z Category
    //które zawiera listę powiązanych Itemsów
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}

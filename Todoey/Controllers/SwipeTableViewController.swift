//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Marcin Miasko on 13/07/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    var cell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }

    //MARK: - metody TableView Datasource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      //funkcja powinna zwróicić obiekt klasy UITableViewCell dla podanego indexPath (numeru wiersza)
      //w tym celu powinniśmy wykorzytać prototypowy wiersz o zdefiniowanym w storyboadrzie
      //identyfikatorze, którego nazwę "CategoryItemCell" wpisaliśmy we właściwościach komórkiw
        
        //przenosząc poniższe do klasy bazowej zmieniam Identifier komóri protoypowej na uniwersalny "Cell"
        //i taki sam "Cell" ustawiam w StoryBoard na wszystkich TVC mających dzidziczyć z SwipeTVC
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
      cell.delegate = self
      return cell
    }
    
    
    //obsługa przesuwalnej komórki TVC - przesuń w praw aby pojawiło się menu Delete, itp.
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
            
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            //co ma się stać gdy user przesunie komórkę w prawo
            //print("delete item .....")
//            if let categoryToDelete = self.categories?[indexPath.row] {
//                do {
//                    try self.realm.write{
//                        self.realm.delete(categoryToDelete)
//                    }
//                } catch {
//                    print("Błąd usuwania kategorii z bazy, \(error)")
//                }
//
//            print("delete cell")
//
//            }//if let...
            //zastępujemy kod do-try-realm.write-relam.delete wywołaniem nowej pistej metody UpdatModel(),
            //którą definiujemy poniżej w kodzie klasy SwipeTVC a następnie w kodzie klas
            //dziedziczących (CategoryTVC, ItemTVC) nadpisujemy (override) własną implementacją metody zależną już
            //od konkretnych klas danych w danym TVC. W SwipeTVC metoda UpdateModel jest tylko taką wydmuszką, żeby
            //tableView editActionsForRowAt wiedziała, że ma wykonać metodę UpdateModel a własciwa implementacja
            //tej metody jest potem już konkretnie zaimplementowana w poszczególnych TVC
            self.updateModel(at: indexPath)
            
            
        }
        //do Assetów dodać ikonkę usuwania i poniżej wpisać jej nazwę
        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
      }

    func updateModel(at indexPath: IndexPath){
        //nadpisać tą metodę w klasie dziedziczącej czyli we własciwym TVC aby poprawnie obłużyć delete
        //z odpowiedniej klasy (caterories, items, czy innej)
        print("SwipeTVC updateModel wiersz = \(indexPath.row)")
    }
    
    
        
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        //options.transitionStyle = .border
        return options
    }


}

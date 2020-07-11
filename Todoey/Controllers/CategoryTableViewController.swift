//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Marcin Miasko on 10/07/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    var categories = [Category]()
    
    //Data PERSISTENCE v3: CoreData - referencja do viewContext ze  zmiennej persistentContainer z AppDelegate:
    let context_CoreData = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        loadItemsFromCoreData()
    }


//MARK: - tableView metody do    t. Datasources
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ile wierszy zarezerować w tabView -  tyle ile wiadomości chcemy wyświetlić
        return categories.count
    }

  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //funkcja powinna zwróicić obiekt klasy UITableViewCell dla podanego indexPath (numeru wiersza)
    //w tym celu powinniśmy wykorzytać prototypowy wiersz o zdefiniowanym w storyboadrzie
    //identyfikatorze, którego nazwę "CategoryItemCell" wpisaliśmy we właściwościach komórkiw
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryItemCell", for: indexPath)
    cell.textLabel?.text = self.categories[indexPath.row].name
    return cell
  }
    
    
   
//MARK: - tableview metody delegowane
    //metoda wołana przez iOS po kliknięciu wybranego wiersza tabeli
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //odpal segue - przejście do listy elementów - nastepneg viewContollera
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    //metoda wołana przez iOS bezpośrednio przed przejściem/wykonaniem segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            //wskaźnik na docelowy VC - wiemy, że dla przejścia "goToList" będzie
            //to klasa ToDoListViewController
            let destinationVC = segue.destination as! TodoListViewController
            
            //ustal nr zaznaczonego/klikniętego wiersza VC i przekaż rekord klikniętej
            //kategori do VC listy elementów, żeby wyświetlić tam tylko elementy z bieżącej kat.
            if let indexPath = tableView.indexPathForSelectedRow {
                //przekazuję do VC całą encję/rekord danej kategorii a nie tylko text klikniętej komórki
                destinationVC.selectedCategory = categories[indexPath.row]
            }
        }
    }
    
    
    //MARK: - Dodaj nowe elem listy
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField() //zmienna pola tekstowego do której przypiszemy pole txt alertu
        
        //okienko pop-up typu Alertu
        let alert = UIAlertController(title: "Dodaj nową kategorię do listy", message: "", preferredStyle: .alert)

        //dodaj jeszcze pole tekstowe do alertu
        alert.addTextField { (poleTextowe) in
            textField = poleTextowe
            textField.placeholder = "Utwórz nową kategorię"
        }
        
        //utworzenie akcji jaka ma się zadziać po naciśnięciu przycisku
        let action = UIAlertAction(title: "Dodaj nowy", style: .default) { (akcja) in
            //co ma się zadziać gdy user kliknie na przycisk dodania "Dodaj nowy" na naszym alercie
            if let txt  = textField.text {
                let newCategory = Category(context: self.context_CoreData)
                
                newCategory.name = txt
                self.categories.append(newCategory)

                self.saveItemsToCoreData()
            }
        }
        
        //powiąż w/w akcję z alertem - dodaj do okna alertu powyższą akcję
        alert.addAction(action)

        //wyświetl w/w alert - zaprezentuj go - Presents a view controller modally
        present(alert, animated: true)
        
    }
    
//MARK: - zapis/odczyt danych z bazy danych CoreData - DataPersistence v3
    
    func saveItemsToCoreData(){
            do {
                try context_CoreData.save()
            } catch {
            print("Bład zapisu kontekstu do bazy danych, \(error)")
            }
            
            self.tableView.reloadData()
            }
    
    
    func loadItemsFromCoreData(with request : NSFetchRequest<Category> = Category.fetchRequest()){
        do {
            categories = try context_CoreData.fetch(request)
        } catch {
            print("Błąd odczytu danych z bazy danych CoreData, \(error)")
        }
        tableView.reloadData()
    } //loadItemsFromCoreData
    
}

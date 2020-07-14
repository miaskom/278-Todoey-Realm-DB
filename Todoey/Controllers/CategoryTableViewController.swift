//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Marcin Miasko on 10/07/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift



class CategoryTableViewController: SwipeTableViewController {
    //  var categories = [Category]()
    //dane odczytywane z bazy przez realm.objects() zwracają listę Results<Category>
    //a nie Array[Category] wiec nie można tak wprost podstawić tego wyniku to zmiennej 'categories'
    //dlatego zmieniamy typ z [Category]() na Results<Category> która jest autoupdeowalna
    //czyli automatycznie aktualizowana w oparciu o zawartość bazy danych
    //Dodaję opcjonalność ? bo lista może być pusta
    var categories: Results<Category>?
    
    //zainicjuj połączenie do bazy Realm (używając ! nie potrzeba do-catch
    let realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //pokaż lokalizację bazy danych Realm
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        loadItemsFromRealmDB()
        
        tableView.rowHeight = 80
    }


//MARK: - tableView metody do    t. Datasources
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ile wierszy zarezerować w tabView -  tyle ile wiadomości chcemy wyświetlić
        return categories?.count ?? 1
    }

    
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //wywyołaj tą samą metodę z klasy bazowej
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    //i dodatkowo ustaw tekst komórki
    cell.textLabel?.text = self.categories?[indexPath.row].name ?? "Nie wybrano jeszcze żadnej kategorii"

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
                destinationVC.selectedCategory = categories?[indexPath.row] 
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
                //utworzenie noweg obiektu/rekordu Categories
                let newCategory = Category()
                newCategory.name = txt
                
                //self.categories.append(newCategory)
                //po zmianie typu 'categories' z [Category]() na Results<Category>,
                //która jest autoupdateowalna nie potrzeba już robić append
                //jak było to w zwykłaej macierzy - tu wystarczy wykomnać zapis
                //do bazy danych i zmienna 'categories' od razu sama zaczyta dane z bazy
                
                self.saveItemsToRealmDB(category: newCategory)
            }
        }
        
        //powiąż w/w akcję z alertem - dodaj do okna alertu powyższą akcję
        alert.addAction(action)

        //wyświetl w/w alert - zaprezentuj go - Presents a view controller modally
        present(alert, animated: true)
        
    }
    
//MARK: - zapis/odczyt danych z bazy danych Realm
    func saveItemsToRealmDB(category: Category){
        do { //zapisz w bazie Realm NOWY rekord kategori
            try realm.write() {
                realm.add(category)
            }
        } catch {
        print("Bład zapisu kontekstu do bazy danych, \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    
    func loadItemsFromRealmDB(){
        //pobierz wszystkie obiekty z bazy Realm typu 'Category'
        //Category to tylko klasa a nie typ aby uzyskać Object.Type klasy trzeba użyć .self;
        categories = realm.objects(Category.self)
        //powyższe realm.objects() zwraca listę Results<Category> a nie Array[Category] wiec
        //nie można tak wprost podstawić tego wyniku to zmiennej 'categories'
        //dlatego zminieliśmy typ z [Category]() na Results<Category>
        
        tableView.reloadData()
    } //loadItemsFromRealmDB
    
    
    //MARK: - DELETE z bazy danych
    //nadpisana metoda updateModel z klasy bazowej SwipeTVC
    override func updateModel(at indexPath: IndexPath) {
        //gdybyśmy potrzebowali wywołać najpierw pierwotną metodę z klasy bazowej to
        //można ją wywołać tak
        //  super.updateModel(at: indexPath)
        
        print("Category updateModel wiersz = \(indexPath.row)")
        if let categoryToDelete = self.categories?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(categoryToDelete)
                }
            } catch {
                print("Błąd usuwania kategorii z bazy, \(error)")
            }
        }//if let...
    }
    
    
    
}

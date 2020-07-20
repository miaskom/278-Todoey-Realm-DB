//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class TodoListViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var toDoItems: Results<Item>?
    
    //zainicjuj połączenie do bazy Realm (używając ! nie potrzeba do-catch
    let realm = try! Realm()
    
    //wartość selectedCategory jest ustawiana wcześniej przez CategoryTableViewController
    //i jest tu wstawiony rekord/encja wskazana na tamtej liście przez usera
    var selectedCategory : Category? {
        didSet{  //po ustawieniu wartości zmiennej wykonaj akcję!!!!
            loadItemsFromRealmDb()
        }
    }
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title  = selectedCategory!.name
        
        if let kolorHex = selectedCategory?.colour {
            if let kolor = UIColor(hexString: kolorHex) {
                //kolor całego NavBara
                navigationController?.navigationBar.barTintColor = kolor
                //kolor przycisku Wstecz
                navigationController?.navigationBar.tintColor = ContrastColorOf(kolor, returnFlat: true)
                
                searchBar.barTintColor = kolor
                }
            }
    }
    
   //MARK: - tableView metody do	t. Datasources
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ile wierszy zarezerować w tabView -  tyle ile wiadomości chcemy wyświetlić
        return toDoItems?.count ?? 1
    }

  //dla każdego wiersza system zapyta nas poniższą funkcją o rodzaj komórki UITabViewCell
  //jaką ma mieć dany wiersz -  można np ustawić inny rodzaj komórki dla pierwszego wiersza
  //a inny dla pozostałych. Jesli tabview ma np 10 wierszy to poniższa metoda
  //zostanie wywołana 10 razy
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //funkcja powinna zwróicić obiekt klasy UITableViewCell dla podanego indexPath (numeru wiersza)
    //w tym celu powinniśmy wykorzytać prototypowy wiersz o zdefiniowanym w storyboadrzie
    //identyfikatorze, którego nazwę "ToDoItemCell" wpisaliśmy we właściwościach komórki
    //Możemy mieć w storyboardzie więcej takich prototypowych komórek o różnych id i różnych ustawieniach
    //więc tutaj musimy zwrócić tą, którą chcemy by posłużyła się jako wzorcema nasza tableView
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
    if  let item = self.toDoItems?[indexPath.row] {
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        //ustaw kolor komórki korzystając z metod biblioteki Chamelon
        //każdy kolejny wiersz przyciemniony o %
        if let kolor =  UIColor(hexString: selectedCategory!.colour!)?.darken(byPercentage:
                                        //ile % przyciemnić
            CGFloat( CGFloat(indexPath.row) / CGFloat(toDoItems!.count) )){
            cell.backgroundColor = kolor
            cell.textLabel?.textColor = ContrastColorOf(kolor, returnFlat: true)
            
        }
        
    } else {
        cell.textLabel?.text = "Brak elementów w kategorii!"
    }
    
    return cell
  }
    
    
    
  //MARK: - tableview metody delegowane
    //metoda wołana przez iOS po zaznaczeniu/kliknięciu wybraneg wiersza tabeli
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //błyśnij tylko podświetleniem zaznaczonego wiersza i wygaś go
        tableView.deselectRow(at: indexPath, animated: true)

        if let item = self.toDoItems?[indexPath.row] {
            do{
                try realm.write{
                    item.done = !item.done
                }
            } catch {
                print("Błąd zapisu/update w bazie danych, \(error)")
            }
            
            tableView.reloadData()
        }
    }
    
    
    //MARK: - Dodaj nowe elem listy
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField() //zmienna pola tekstowego do której przypiszemy pole txt alertu
        
        //okienko pop-up typu Alertu
        let alert = UIAlertController(title: "Dodaj nowe zadanie do listy", message: "", preferredStyle: .alert)

        //dodaj jeszcze pole tekstowe do alertu
        alert.addTextField { (poleTextowe) in
            //TEN CLOSURE JEST WYKONYWANY TYLKO RAZ W CHWILI DODAWANIA POLA TXT DO ALERTU
            //przypisujemy w nim zmienną lokalną closure'a do zmiennej textFiled dostępnej
            //w całej metodzie, aby móc potem odczytać jej wartość. bo poleTextowe jest
            //dostępne tyko wewnątrz tego closure
            textField = poleTextowe
            textField.placeholder = "Utwórz nowe zadanie"
        }
        
        //utworzenie akcji jaka ma się zadziać po naciśnięciu przycisku
        let action = UIAlertAction(title: "Dodaj nowy", style: .default) { (akcja) in
            //co ma się zadziać gdy user kliknie na przycisk dodania "Dodaj nowy" na naszym alercie
            //print(textField.text)
            if let txt  = textField.text {
                if let currCategory = self.selectedCategory {
                     //self.saveItemsToCoreData()
                    
                    do {
                        try self.realm.write{
                            let newItem = Item()
                            newItem.title = txt
                            newItem.done = false
                            newItem.createdDate = Date()
                            
                            //dodaj element do listy kategorii
                            currCategory.items.append(newItem)
                        }
                    } catch {
                        print("Błąd zapisu elementu do bazy, \(error)")
                    }
                   
                } //if let currCtegory
            } //if let txt
            
            self.tableView.reloadData()
        }
        
        //powiąż w/w akcję z alertem - dodaj do okna alertu powyższą akcję
        alert.addAction(action)

        //wyświetl w/w alert - zaprezentuj go - Presents a view controller modally
        present(alert, animated: true)
        
    }

    
//MARK: - odczyt danych z bazy danych

    func loadItemsFromRealmDb(){
        //załaduj liste elementów z przekazanej selected Category z listy 'items' i posortuj
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "createdDate", ascending: true)
        tableView.reloadData()
    } //loadItemsFromRealmDb(
    
    
    //MARK: - DELETE z bazy danych
    //nadpisana metoda updateModel z klasy bazowej SwipeTVC
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = self.toDoItems?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(itemToDelete)
                }
            } catch {
                print("Błąd usuwania elementu z bazy, \(error)")
            }
        }//if let...
    }
}



//MARK: - obsługa SearchBar'a
//rozszerzenie VC o protokół obsługi searchBar
extension TodoListViewController:  UISearchBarDelegate {
    //metoda wołana przez iOS po naciśnięciu przycisku szukaj na SearchBarze
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text!.count > 0 {
            //do warunków wyszukowania NSPREDICATE i w nim definiuje się warunki i podstawia argumenty
            //do warunków odpowiednio dla %@
            //szczegółowa instrukacja na https://academy.realm.io/posts/nspredicate-cheatsheet/
            //CONTAINS - zawiera, ale jest wrażliwe na wielkie/małe litery (c) i znaki diakrytyczne (d)
            //żeby NIE było wrażliwe na [c]ase i [d]iacritic dodajemy [cd]
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            toDoItems = toDoItems?.filter(predicate).sorted(byKeyPath: "createdDate", ascending: true)
            
            tableView.reloadData()
        }

        //i wyłącz klawiaturę - czyli spraw, by searchBar nie był pierwszym responderem
        //otrzymującym zdarzenia z iOS -  coś jakby "setFocus =false"
        //zrezygnuj z bycia pierwszym responderem - ale trzeba to zrobić w GŁÓWNYM WĄTKU APLIKACJI
        DispatchQueue.main.async {
            //rezygnacja z bycia pierwszym responderem zamknie też klawiaturę
            searchBar.resignFirstResponder()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //jeśli user kliknie X żeby wykasować wszystko w searchbar'ze
        //czyli gdy tekst po zmianie będzie pusty
        if searchBar.text?.count == 0 {
            loadItemsFromRealmDb()

            //i wyłącz klawiaturę - czyli spraw, by searchBar nie był pierwszym responderem
            //otrzymującym zdarzenia z iOS -  coś jakby "setFocus =false"
            //zrezygnuj z bycia pierwszym responderem - ale trzeba to zrobić w GŁÓWNYM WĄTKU APLIKACJI
            DispatchQueue.main.async {
                //rezygnacja z bycia pierwszym responderem zamknie też klawiaturę
                searchBar.resignFirstResponder()
            }
        }
    }


}

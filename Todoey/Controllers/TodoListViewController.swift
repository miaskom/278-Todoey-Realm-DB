//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData


class TodoListViewController: UITableViewController {

    //var itemArray = ["Find Mike",  "drugi tekst", "jeszcze jeden"]
    var itemArray = [Item]()
    
    //wartość selectedCategory jest ustawiana wcześniej przez CategoryTableViewController
    //i jest tu wstawiony rekord/encja wskazana na tamtej liście przez usera
    var selectedCategory : Category? {
        didSet{  //po ustawieniu wartości zmiennej wykonaj akcję!!!!
            loadItemsFromCoreData()
        }
    }
    
    //Data PERSISTENCE v1:  UserDeafauts
    // zapamiętywanie danych obiektów/zmiennych w UserDefaults - plik w urządzeniu
//  let defaults = UserDefaults.standard
    
    //Data PERSISTENCE  v2: NSCoder
    //ścieżka - filemanger dla procesu (singleton) w home'ie bieżacego usera (.userDomainMask)
    //   FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    //zwraca ten sam folder co wczesniej używane NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last, tj: /Users/marcinmiasko/Library/Developer/CoreSimulator/Devices/9BA8808E-A203-4A9B-AFB5-030A5217B319/data/Containers/Data/Application/3E01AFD3-9F81-4F85-AB9E-F7C6DFC7A81A/Documents/
    //w podfolderze Library/Preferences znajduje się plik com.miaskom.todoey-ios13.Todoey.plist
    //zapisany wcześniej podczas używania UserDefaults
    //
    //notomiast w folderze ./Documents/  metoda appending...() otworzy istnieący plik o podanej nazwie
    //lub przy próbie zapisu utworzy nowy plik jesli wcześniej nie istniał
//  let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    
    //Data PERSISTENCE v3: CoreData
    //referencja do viewContext ze  zmiennej persistentContainer z AppDelegate:
    let context_CoreData = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //wyświetl folder aplikacji, w którym apka zapisuje dane UserDefaults
        // print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
         //
         //u mnie przy odpalaniu na symulatorze jest to folder: /Users/marcinmiasko/Library/Developer/CoreSimulator/Devices/9BA8808E-A203-4A9B-AFB5-030A5217B319/data/Containers/Data/Application/3E01AFD3-9F81-4F85-AB9E-F7C6DFC7A81A/Documents
         //i potem podfolder Library/Preferences i tam znajdzie się plik com.miaskom.todoey-ios13.Todoey.plist
         //zawierający zapisane defaults
        
      /*  let newItem  = Item()
        newItem.title = "FindMike"
        itemArray.append(newItem)
        
        let newItem2  = Item()
        newItem2.title = "FindMike22222"
        itemArray.append(newItem2)
        
        let newItem3 = Item()
        newItem3.title = "FindMike33333"
        itemArray.append(newItem3)
        */
        //Data PERSISTENCE v1 - UserDefaults - zainicjuj wartości zmiennych z UserDefaults'ów
 //       if let items = defaults.array(forKey: "ToDoList") as? [String]{
 //           itemArray = items
//         }
        
        //Data PERSISTENCE v2 - NSCoder
 //       loadItemsFromFile()
 //       print(dataFilePath)
        
        //ścieżka do bazy danych SQLite:
         print(FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first)
        //np. /Users/marcinmiasko/Library/Developer/CoreSimulator/Devices/9BA8808E-A203-4A9B-AFB5-030A5217B319/data/Containers/Data/Application/C9B309F4-7C18-4505-A71E-CD3915D40A87/Library/
        //w podfolderze ./Application Support/ są pliki SQLite
       // loadItemsFromCoreData() ---usuwam tu bo loadData jest ładowane teraz na podst selectedCategory
        
    }
    
    
   //MARK: - tableView metody do	t. Datasources
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ile wierszy zarezerować w tabView -  tyle ile wiadomości chcemy wyświetlić
        return itemArray.count
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
    cell.textLabel?.text = self.itemArray[indexPath.row].title
    
   // print("cellForRowAt")
    
    //zaznacz checkboxa w klikniętej komórce
/*    if  self.itemArray[indexPath.row].done == false {
        cell.accessoryType = .none
     } else {
        cell.accessoryType = .checkmark
     } */
    
    //Ternary Operator:   value = condition ? valueIfTrue : valueIfFalse
    //cell.accessoryType = (self.itemArray[indexPath.row].done == false) ? .none : .checkmark
    //cell.accessoryType = self.itemArray[indexPath.row].done ? .checkmark : .none
    let item = self.itemArray[indexPath.row]
    cell.accessoryType = item.done ? .checkmark : .none
    
       
    
    return cell
  }
    
    
    
  //MARK: - tableview metody delegowane
    //metoda wołana przez iOS po zaznaczeniu/kliknięciu wybraneg wiersza tabeli
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //błyśnij tylko podświetleniem zaznaczonego wiersza i wygaś go
        tableView.deselectRow(at: indexPath, animated: true)
      
        //zaznacz checkboxa w klikniętej komórce
        /*if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }*/
    
        /*if self.itemArray[indexPath.row].done == false {
            self.itemArray[indexPath.row].done = true
        } else {
            self.itemArray[indexPath.row].done = false
        }*/
        
        //self.itemArray[indexPath.row].setValue("nowa wartość", forKey: "title")
        
        self.itemArray[indexPath.row].done = !self.itemArray[indexPath.row].done
        
        //tableView.reloadData()
        
        //self.saveItemsToFile()
        self.saveItemsToCoreData()
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
                
                 
                //let newItem  = Item()
                
                //obiekt Item na podst klasy encji Item utwrznej w CoreData,
                //gdzie context to referencja do viewContext zmiennej persistentContainer z obiektu klasy AppDelegate.swift
                //  czyli contextCoreData = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                //zatem tworzymy nowy obiekt/rekord w kontekście/kontenerze CoreData ale jeszcze bez fizycznego zapisu w bazie
                let newItem = Item(context: self.context_CoreData)
                
                newItem.title = txt
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)

                
                //Data Persistence  - UserDefaults- zapamiętaj w defaults'ach tablice itemArray
                //w obiekcie defaults klasy UserDefaults nadając jej klicz ToDoList
                //klucza tego użyemy potem do pobrania danych podczas ładowania aplikacji
  //              self.defaults.set(self.itemArray, forKey: "ToDoList")
                
               // self.saveItemsToFile()
                self.saveItemsToCoreData()
            }
        }
        
        //powiąż w/w akcję z alertem - dodaj do okna alertu powyższą akcję
        alert.addAction(action)

        //wyświetl w/w alert - zaprezentuj go - Presents a view controller modally
        present(alert, animated: true)
        
    }
/*
 //MARK: - zapis/odczyt danych z pliku w ramach NSCoder - DataPersistence v2
    func saveItemsToFile(){
        //Data Persistence  v2:  NSCoder -
        //PropertyListEncoder - tworzy obiekt potrafiący zakodować dowolny obiekt jako plist
        let encoder = PropertyListEncoder()
        do {
            //data - zakdowana/zserializowana jako plist macież obiektów itemArray
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!) //zapisz zserializowane dane w pliku
            
        } catch {
            print("Bład zapisu macierzy do pliku, \(error)")
        }

        self.tableView.reloadData()
    }//saveItemsToFile
    
    
    
    func loadItemsFromFile(){
        //Data Persistence  v2:  NSCoder -
        //odczytaj zserializowane dane z pliku
        if let data = try? Data(contentsOf: dataFilePath!) {
            //dekoder potrafiący zdeserializować dane do obiektu
            let decoder  = PropertyListDecoder()
            do {  //zdekoduj dane do obiktu spod podanej referencji obiket.self
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Błąd odczytu danych z pliku, \(error)")
            }
        }
    } //loadItemsFromFile
*/
    
//MARK: - zapis/odczyt danych z bazy danych CoreData - DataPersistence v3
    
    func saveItemsToCoreData(){
            do {
                try context_CoreData.save()
            } catch {
            print("Bład zapisu kontekstu do bazy danych, \(error)")
            }
            
            self.tableView.reloadData()
            }
    
    
    func loadItemsFromCoreData(with request : NSFetchRequest<Item> = Item.fetchRequest(),
                                   predicate: NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            //złożony predicate z 2 warunków/predictów i AND'a
            let zlozonyPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            request.predicate = zlozonyPredicate
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            //pobierz do macierzy itemArray wszystkie Item'sy pobrane z naszego kontekstu CoreData
            //używając w/w requestu dla Item'sów
            itemArray = try context_CoreData.fetch(request)
        } catch {
            print("Błąd odczytu danych z bazy danych CoreData, \(error)")
        }
        tableView.reloadData()
    } //loadItemsFromCoreData
    
}


//MARK: - obsługa SearchBar'a
//rozszerzenie VC o protokół obsługi searchBar
extension TodoListViewController:  UISearchBarDelegate {
    //metoda wołana przez iOS po naciśnięciu przycisku szukaj na SearchBarze
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()

        if searchBar.text!.count > 0 {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

            loadItemsFromCoreData(with: request)
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
            loadItemsFromCoreData()
            
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

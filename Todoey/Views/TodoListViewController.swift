//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit



class TodoListViewController: UITableViewController {

    //var itemArray = ["Find Mike",  "drugi tekst", "jeszcze jeden"]
    var itemArray = [Item]()
    
    //Data PERSISTENCE v1: UserDeafauts - zapamiętywanie danych obiektów/zmiennych w UserDefaults - plik w urządzeniu
   // let defaults = UserDefaults.standard
    
    //Data PERSISTENCE  v2: NSCoder
    //ścieżka - filemanger dla procesu (singleton) w home'ie bieżacego usera (.userDomainMask)
    //   FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    //zwraca ten sam folder co wczesniej używane NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last, tj: /Users/marcinmiasko/Library/Developer/CoreSimulator/Devices/9BA8808E-A203-4A9B-AFB5-030A5217B319/data/Containers/Data/Application/3E01AFD3-9F81-4F85-AB9E-F7C6DFC7A81A/Documents/
    //w podfolderze Library/Preferences znajduje się plik com.miaskom.todoey-ios13.Todoey.plist
    //zapisany wcześniej podczas używania UserDefaults
    //
    //notomiast w folderze ./Documents/  metoda appending...() otworzy istnieący plik o podanej nazwie
    //lub przy próbie zapisu utworzy nowy plik jesli wcześniej nie istniał
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    
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
        //Data PERSISTENCE - UserDefaults - zainicjuj wartości zmiennych z UserDefaults'ów
 //       if let items = defaults.array(forKey: "ToDoList") as? [String]{
 //           itemArray = items
//         }
        
        loadItemsFromFile()

        print(dataFilePath)
       
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
    
    print("cellForRowAt")
    
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
        
        self.itemArray[indexPath.row].done = !self.itemArray[indexPath.row].done
        
        //tableView.reloadData()
        
        self.saveItemsToFile()
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
                
                let newItem  = Item()
                newItem.title = txt
                self.itemArray.append(newItem)

                
                //Data Persistence  - UserDefaults- zapamiętaj w defaults'ach tablice itemArray
                //w obiekcie defaults klasy UserDefaults nadając jej klicz ToDoList
                //klucza tego użyemy potem do pobrania danych podczas ładowania aplikacji
  //              self.defaults.set(self.itemArray, forKey: "ToDoList")
                
                self.saveItemsToFile()
            }
        }
        
        //powiąż w/w akcję z alertem - dodaj do okna alertu powyższą akcję
        alert.addAction(action)

        //wyświetl w/w alert - zaprezentuj go - Presents a view controller modally
        present(alert, animated: true)
        
    }
    
    
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
    
    
}



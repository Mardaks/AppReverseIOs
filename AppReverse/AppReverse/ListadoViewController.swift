import UIKit
import CoreData

class ListadoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //componentes
    @IBOutlet weak var tbReverse: UITableView!
    
    var reverseData = [Reverse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "ReverseTableViewCell", bundle: nil)
        tbReverse.register(nib, forCellReuseIdentifier: "ReverseTableViewCell") // inicializamos el nib de la celda
        configurateView() //configuramos la tabla
        showData() //mostramos los datos de la bd
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tbReverse.reloadData() // actualizamos la tabla
    }
    
    //funcion para configurar la tabla
    func configurateView() {
        tbReverse.delegate = self
        tbReverse.dataSource = self
        tbReverse.rowHeight = 100
    }
    
    //funcion para conectar a la bd
    func connectBD() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    //funcion para mostrar las reversas de un usuario
    func showData() {
        let context = connectBD()
        let fethRequest: NSFetchRequest<Reverse> = Reverse.fetchRequest()
        
        if let loggedInUser = (UIApplication.shared.delegate as! AppDelegate).loggedInUser {
            fethRequest.predicate  = NSPredicate(format: "user == %@", loggedInUser) //validamos al usuario para mostrar sus reservas creadas
        }
        
        do {
            reverseData = try context.fetch(fethRequest)
            print("Se mostraron los datos en la tabla")
        } catch let error as NSError {
            print("Error al mostrar: \(error.localizedDescription)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reverseData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReverseTableViewCell", for: indexPath) as? ReverseTableViewCell
        let reverse = reverseData[indexPath.row]
        cell?.configureReverse(reverse: reverse, viewcontroller: self)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let context = connectBD()
        let reverse = reverseData[indexPath.row]
        if editingStyle == .delete {
            context.delete(reverse)
            do {
                try context.save()
                print("Se elimino la reserva")
            } catch let error as NSError {
                print("Error al eliminar la reserva: \(error.localizedDescription)")
            }
        }
        showData()
        tbReverse.reloadData()
    }
}

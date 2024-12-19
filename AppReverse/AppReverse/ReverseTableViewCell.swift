import UIKit

class ReverseTableViewCell: UITableViewCell {

    //componentes
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    //variables
    var reverse: Reverse?
    var viewcontroller: ListadoViewController?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureReverse(reverse: Reverse, viewcontroller: ListadoViewController) {
        self.lblRoom.text = "Salon N: \(reverse.room)"
        if let date = reverse.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            formatter.locale = Locale.current
            self.lblDate.text = "Fecha: \(formatter.string(from: date))"
        }
        self.reverse = reverse
        self.viewcontroller = viewcontroller
    }
    
}

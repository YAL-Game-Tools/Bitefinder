package table;
import js.html.TableRowElement;

class TableValue {
	public var name:String;
	public var row:TableRowElement;
	
	public function new(name) {
		this.name = name;
		row = js.Browser.document.createTableRowElement();
	}
}
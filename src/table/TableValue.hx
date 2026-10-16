package table;
import js.html.TableRowElement;

class TableValue {
	public var name:String;
	public var row:TableRowElement;
	
	public function new(name) {
		this.name = name;
		init();
	}
	public function init() {
		row = js.Browser.document.createTableRowElement();
	}
}
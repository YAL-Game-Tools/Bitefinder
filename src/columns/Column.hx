package columns;

import js.Browser;
import table.TableFilter;
import js.html.Element;
import js.html.TableCellElement;

class Column<T:table.TableValue> extends TableFilter<T> {
	public var show = true;
	public var fullName:String = null;
	public var canSort = false;
	public var canFilter = false;
	public var header:Element;
	override function getFullName():String {
		return fullName ?? name;
	}
	public function buildHeader(th:Element) {
		var fullName = getFullName();
		if (fullName != name) {
			var abbr = Browser.document.createElement("abbr");
			abbr.title = fullName;
			abbr.append(name);
			th.append(abbr);
		} else th.append(name);
	}
	public function buildValue(td:TableCellElement, q:T) {
		//
	}
	public function compare(a:T, b:T) {
		return 0;
	}
}

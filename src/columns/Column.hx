package columns;

import table.TableFilter;
import js.html.Element;
import js.html.TableCellElement;

class Column<T:table.TableValue> extends TableFilter<T> {
	public var filterName:String = null;
	public var canSort = false;
	public var canFilter = false;
	public var header:Element;
	override function getFilterName():String {
		return filterName ?? name;
	}
	public function buildHeader(th:Element) {
		th.append(name);
	}
	public function buildValue(td:TableCellElement, q:T) {
		//
	}
	public function compare(a:T, b:T) {
		return 0;
	}
	public function ready(items:Array<T>) {
		
	}
}

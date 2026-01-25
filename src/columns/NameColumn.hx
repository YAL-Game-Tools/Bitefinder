package columns;

import js.html.TableCellElement;

class NameColumn<T:table.TableValue> extends Column<T> {
	override function buildValue(td:TableCellElement, q:T) {
		td.append(q.name);
	}
}
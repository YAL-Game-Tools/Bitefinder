package columns;

import table.*;
import columns.*;

class OrderColumn<T:TableValue> extends Column<T> {
	public var order:Map<T, Int> = new Map();
	public function new(table:Table<T>) {
		super("Order");
		for (i => item in table.items) {
			order[item] = i;
		}
		canSort = true;
		header = js.Browser.document.createElement("span");
	}
	override function compare(a:T, b:T):Int {
		var ai = order[a] ?? -1;
		var bi = order[b] ?? -1;
		return ai - bi;
	}
}
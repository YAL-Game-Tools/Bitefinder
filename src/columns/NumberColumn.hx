package columns;

import haxe.DynamicAccess;
import js.html.InputElement;
import js.html.SelectElement;
import js.html.Element;
import table.Table;
import js.html.TableCellElement;
import js.Browser.document;
using tools.HtmlTools;

class NumberColumn<T:table.TableValue> extends Column<T> {
	public var getter:T->Int;
	public var prefix = "";
	public function new(name, getter) {
		super(name);
		this.getter = getter;
		canSort = true;
		canFilter = true;
	}
	override function compare(a:T, b:T) {
		return getter(a) - getter(b);
	}
	override function buildValue(td:TableCellElement, q:T) {
		td.append(prefix + getter(q));
	}
	override function buildFilter(ctr:Element, table:Table<T>) {
		var opSelect = document.createSelectElement();
		opSelect.appendOption("Is at least", "ge");
		opSelect.appendOption("Is at most", "le");
		opSelect.appendOption("Is exactly", "eq");
		opSelect.appendOption("Is not", "ne");
		opSelect.classList.add("op");
		table.updateFiltersOn(opSelect);
		//
		var fdNumber = document.createInputElement();
		fdNumber.type = "number";
		fdNumber.classList.add("value");
		table.updateFiltersOn(fdNumber);
		//
		ctr.appendMixed(opSelect, " ", fdNumber);
	}
	inline function getOpSelect(ctr:Element) {
		return ctr.querySelectorAuto("& > select.op", SelectElement);
	}
	inline function getValueField(ctr:Element) {
		return ctr.querySelectorAuto("& > input.value", InputElement);
	}
	override function matchesFilter(ctr:Element, table:Table<T>, item:T):Bool {
		var op = getOpSelect(ctr).value;
		var filterValue = getValueField(ctr).valueAsNumber;
		var itemValue = getter(item);
		if (!Math.isFinite(filterValue)) return true;
		switch (op) {
			case "ge": return itemValue >= filterValue;
			case "le": return itemValue <= filterValue;
			case "eq": return itemValue == filterValue;
			case "ne": return itemValue != filterValue;
		}
		return true;
	}
	override function saveFilter(ctr:Element, table:Table<T>):DynamicAccess<Any> {
		var q = createFilterObject(ctr);
		q["op"] = getOpSelect(ctr).value;
		q["value"] = getValueField(ctr).value;
		return q;
	}
	override function loadFilter(ctr:Element, table:Table<T>, q:DynamicAccess<Any>) {
		super.loadFilter(ctr, table, q);
		getOpSelect(ctr).value = q["op"];
		getValueField(ctr).value = q["value"];
	}
}
package table;

import js.html.InputElement;
import haxe.DynamicAccess;
import js.html.Element;
import js.Browser.document;
using tools.HtmlTools;

class TableFilter<T:table.TableValue> {
	public var name:String;
	public function new(name:String) {
		this.name = name;
	}
	public function getFullName() {
		return name;
	}
	
	public function ready(items:Array<T>) {
		
	}
	public function buildFilter(ctr:Element, table:Table<T>) {
		
	}
	public function createSection(table:Table<T>) {
		var section = document.createFieldSetElement();
		section.classList.add("filter");
		//
		var legend = document.createLegendElement();
		//
		var enable = document.createInputElement();
		enable.type = "checkbox";
		enable.classList.add("enable");
		enable.checked = true;
		table.updateFiltersOn(enable);
		//
		legend.appendMixed(enable, " ", getFullName());
		//
		TableTools.addOrderControls(section, legend, () -> { table.updateFilters(); });
		section.append(legend);
		//
		buildFilter(section, table);
		(cast section).yalTableFilter = this;
		return section;
	}
	public inline function getEnableCheckbox(ctr:Element) {
		return ctr.querySelectorAuto("& > legend > input.enable", InputElement);
	}
	public function matchesFilter(ctr:Element, table:Table<T>, item:T):Bool {
		return true;
	}
	public static inline var typeKey = "$type";
	public static inline var enableKey = "$enable";
	function createFilterObject(ctr:Element) {
		var q = new DynamicAccess<Any>();
		q[typeKey] = name;
		q[enableKey] = getEnableCheckbox(ctr).checked;
		return q;
	}
	public function saveFilter(ctr:Element, table:Table<T>):DynamicAccess<Any> {
		return null;
	}
	public function loadFilter(ctr:Element, table:Table<T>, q:DynamicAccess<Any>) {
		getEnableCheckbox(ctr).checked = q[enableKey] ?? true;
	}
}
package table;

import haxe.DynamicAccess;
import js.html.SelectElement;
import js.html.Element;
import js.Browser.document;
using tools.HtmlTools;

class TableFilterGroup<T:TableValue> extends TableFilter<T> {
	public function new() {
		super("Filter Group");
	}
	override function buildFilter(ctr:Element, table:Table<T>) {
		var modeSelect = document.createSelectElement();
		modeSelect.classList.add("mode");
		modeSelect.appendOption("Any of these", "any");
		modeSelect.appendOption("All of these", "all");
		modeSelect.appendOption("None of these", "none");
		table.updateFiltersOn(modeSelect);
		ctr.append(modeSelect, table.createFilterPicker());
	}
	inline function getModeSelect(ctr:Element):SelectElement {
		return ctr.querySelectorAuto("& > select.mode");
	}
	inline function getFilterPicker(ctr:Element):Element {
		return ctr.querySelectorAuto("& > .filter-picker");
	}
	override function matchesFilter(ctr:Element, table:Table<T>, item:T):Bool {
		var subFilters = TableTools.getFilters(table, ctr);
		switch (getModeSelect(ctr).value) {
			case "any": {
				if (subFilters.length == 0) return true;
				for (pair in subFilters) {
					if (pair.filter.matchesFilter(pair.section, table, item)) return true;
				}
				return false;
			};
			case "all": {
				for (pair in subFilters) {
					if (!pair.filter.matchesFilter(pair.section, table, item)) return false;
				}
				return true;
			};
			case "none": {
				for (pair in subFilters) {
					if (pair.filter.matchesFilter(pair.section, table, item)) return false;
				}
				return true;
			};
		}
		return true;
	}
	override function saveFilter(ctr:Element, table:Table<T>):DynamicAccess<Any> {
		var q = createFilterObject(ctr);
		q["mode"] = getModeSelect(ctr).value;
		var subFilters = TableTools.getFilters(table, ctr);
		q["filters"] = subFilters.map(pair -> pair.filter.saveFilter(pair.section, table));
		return q;
	}
	override function loadFilter(ctr:Element, table:Table<T>, q:DynamicAccess<Any>) {
		getModeSelect(ctr).value = q["mode"];
		for (pair in TableTools.getFilters(table, ctr, true)) pair.section.remove();
		var picker = getFilterPicker(ctr);
		var filters:Array<DynamicAccess<Any>> = q["filters"];
		for (obj in filters) {
			var section = table.parseFilter(obj);
			if (section != null) picker.before(section);
		}
	}
}
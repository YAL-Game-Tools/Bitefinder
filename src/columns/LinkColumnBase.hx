package columns;

import haxe.DynamicAccess;
import js.html.SelectElement;
import js.html.TableCellElement;
import table.TableTools;
import js.html.Element;
import table.Table;
import js.Browser.document;
using tools.HtmlTools;

class LinkColumnBase<T:table.TableValue> extends Column<T> {
	public var isMulti = false;
	//
	public var knownValues:Array<String> = [];
	public var knownValuesMap:Map<String, WikiLink> = new Map();
	//
	public function new(name) {
		super(name);
		canFilter = true;
	}
	//
	function addKnownValue(link:WikiLink) {
		if (link == null) return;
		var name = link.name;
		var curr = knownValuesMap[name];
		if (curr == null) {
			knownValuesMap[name] = link;
			knownValues.push(name);
		} else if (curr.url == null && link.url != null) {
			knownValuesMap[name] = link;
		}
	}
	override function ready(items:Array<T>) {
		knownValues.sort((a, b) -> (a < b ? -1 : 1));
	}
	//
	function getLinks(item:T):Array<WikiLink> {
		return [];
	}
	override function buildValue(td:TableCellElement, q:T) {
		var links = getLinks(q);
		for (i => link in links) {
			if (i > 0) td.append(", ");
			td.append(link.toElement());
		}
	}
	//
	static final emptyValue = "(empty)";
	override function buildFilter(ctr:Element, table:Table<T>) {
		var controlsCtr = document.createDivElement();
		controlsCtr.classList.add("controls");
		var valueCtr = document.createDivElement();
		valueCtr.classList.add("values");
		//
		var modeSelect = document.createSelectElement();
		modeSelect.classList.add("mode");
		function addMode(kind:String, label:String) {
			var option = document.createOptionElement();
			option.value = kind;
			option.append(label);
			modeSelect.append(option);
		}
		addMode("any", "Any of these");
		if (isMulti) addMode("all", "All of these");
		addMode("none", "None of these");
		//
		var valueSelect = document.createSelectElement();
		function addValueOption(name:String) {
			var option = document.createOptionElement();
			option.append(name);
			valueSelect.append(option);
		}
		addValueOption(emptyValue);
		for (value in knownValues) addValueOption(value);
		valueSelect.addEventListener("change", (_) -> {
			table.updateFilters();
		});
		//
		var valueSelectButton = document.createInputElement();
		valueSelectButton.type = "button";
		valueSelectButton.value = "Add";
		valueSelectButton.addEventListener("click", (e) -> {
			addFilterValue(ctr, table, valueSelect.value);
		});
		//
		controlsCtr.appendMixed(modeSelect, " ", valueSelect, " ", valueSelectButton, valueCtr);
		ctr.append(controlsCtr, valueCtr);
	}
	function addFilterValue(ctr:Element, table:Table<T>, name:String) {
		var button = document.createInputElement();
		button.type = "button";
		button.classList.add("value");
		button.value = name;
		button.dataset.value = name;
		button.addEventListener("click", (_) -> {
			button.remove();
			table.updateFilters();
		});
		getValueCtr(ctr).append(button);
		table.updateFilters();
	}
	static function setContains(itemValues:Array<String>, value:String) {
		if (value == emptyValue) {
			return itemValues.length == 0;
		} else {
			return itemValues.contains(value);
		}
	}
	inline function getModeSelect(ctr:Element) {
		return ctr.querySelectorAuto("& > .controls > select.mode", SelectElement);
	}
	inline function getValueCtr(ctr:Element):Element {
		return ctr.querySelectorAuto("& > .values");
	}
	inline function getValueNodes(ctr:Element):ElementList {
		return ctr.querySelectorEls("& > .values > .value");
	}
	override function matchesFilter(ctr:Element, table:Table<T>, item:T):Bool {
		if (matchesFilterSkip(ctr, table, item)) return true;
		var valueNodes = getValueNodes(ctr);
		var filterValues = [for (node in valueNodes) node.dataset.value];
		var itemValues = getLinks(item).map((link) -> link.name);
		switch (getModeSelect(ctr).value) {
			case "any": {
				if (filterValues.length == 0) return true;
				for (val in filterValues) {
					if (setContains(itemValues, val)) return true;
				}
				return false;
			}
			case "all": {
				for (val in filterValues) {
					if (!setContains(itemValues, val)) return false;
				}
				return true;
			}
			case "none": {
				for (val in filterValues) {
					if (setContains(itemValues, val)) return false;
				}
				return true;
			}
		}
		return true;
	}
	override function saveFilter(ctr:Element, table:Table<T>):DynamicAccess<Any> {
		var q = createFilterObject();
		q["mode"] = getModeSelect(ctr).value;
		q["values"] = [for (node in getValueNodes(ctr)) node.dataset.value];
		return q;
	}
	override function loadFilter(ctr:Element, table:Table<T>, q:DynamicAccess<Any>) {
		super.loadFilter(ctr, table, q);
		getModeSelect(ctr).value = q["mode"];
		for (node in getValueNodes(ctr)) node.remove();
		var names:Array<String> = q["values"];
		for (name in names) {
			addFilterValue(ctr, table, name);
		}
	}
}
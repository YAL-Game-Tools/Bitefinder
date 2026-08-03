package columns;

import haxe.DynamicAccess;
import js.html.SelectElement;
import js.html.TableCellElement;
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
	public var complexValues:Map<String, LinkColumnComplexValue> = new Map();
	public var hiddenValues:Map<String, Bool> = new Map();
	public var prepareValueForComparison:String->String = null;
	//
	public function addComplexValue(name:String, values:Array<String>, ?title:String, displayName = "Multi") {
		var joined = values.join(", ");
		if (title == null) {
			title = joined;
		} else {
			title = StringTools.replace(title, "<values>", joined);
		}
		var cv = new LinkColumnComplexValue();
		cv.text = displayName;
		cv.title = title;
		cv.values = values;
		complexValues[name] = cv;
		knownValues.remove(name);
	}
	public function addValueAbbr(name:String, label:String, ?classNames:Array<String>, ?title:String) {
		var cv = new LinkColumnComplexValue();
		cv.text = label ?? name;
		cv.values = [name];
		if (title != null) {
			cv.title = title;
		} else if (label != null) {
			cv.title = name;
		}
		if (classNames != null) cv.classNames = classNames;
		complexValues[name] = cv;
	}
	public function hideValue(name:String) {
		hiddenValues[name] = true;
	}
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
		var sep = false;
		for (link in links) {
			if (hiddenValues[link.name]) continue;
			//
			if (sep) {
				td.append(", ");
			} else sep = true;
			//
			var complex = complexValues[link.name];
			if (complex != null) {
				var abbr = document.createElement("abbr");
				abbr.title = complex.title;
				abbr.append(complex.text);
				for (className in complex.classNames) abbr.classList.add(className);
				td.append(abbr);
			} else td.append(link.toElement());
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
		modeSelect.appendOption("Any of these", "any");
		if (isMulti) modeSelect.appendOption("All of these", "all");
		modeSelect.appendOption("None of these", "none");
		modeSelect.addEventListener("change", (_) -> {
			table.updateFilters();
		});
		//
		var valueSelect = document.createSelectElement();
		valueSelect.appendOption(emptyValue);
		for (value in knownValues) valueSelect.appendOption(value);
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
		var valueNodes = getValueNodes(ctr);
		var filterValues = [for (node in valueNodes) node.dataset.value];
		
		var itemValues = [];
		for (link in getLinks(item)) link.gatherNames(itemValues);
		if (prepareValueForComparison != null) {
			for (i => v in itemValues) itemValues[i] = prepareValueForComparison(v);
		}
		for (i in 0 ... itemValues.length) {
			var complex = complexValues[itemValues[i]];
			if (complex != null) {
				for (val in complex.values) itemValues.push(val);
			}
		}
		
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
		var q = createFilterObject(ctr);
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
class LinkColumnComplexValue {
	public var text:String;
	public var title:String;
	public var values:Array<String>;
	public var classNames:Array<String> = [];
	public function new() {
		
	}
}
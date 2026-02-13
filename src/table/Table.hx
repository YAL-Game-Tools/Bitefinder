package table;

import js.html.MouseEvent;
import haxe.DynamicAccess;
import js.html.Element;
import js.html.TableRowElement;
import columns.*;
import js.html.TableElement;
import js.Browser;
import js.Browser.document;
using tools.HtmlTools;

class Table<T:TableValue> {
	public var table:TableElement;
	public var header:TableRowElement;
	public var filterContainer:Element;
	public var rootFilterPicker:Element;
	public var counterElement:Element;
	public var resetOrderElement:Element;
	var resetSorter:OrderColumn<T>;
	//
	public var columns:Array<Column<T>> = [];
	public var filters:Array<TableFilter<T>> = [];
	public var items:Array<T>;
	//
	public function new(table, items, filterContainer, counterElement, resetOrderElement) {
		this.table = table;
		this.items = items;
		this.filterContainer = filterContainer;
		this.counterElement = counterElement;
		this.resetOrderElement = resetOrderElement;
		if (resetOrderElement != null) {
			resetSorter = new OrderColumn(this);
			resetOrderElement.onclick = function() {
				resetSorter.header.setAttribute("data-sort", "");
				sort(resetSorter);
				resetOrderElement.style.display = "none";
			}
		}
		build();
	}
	function initColumns() {
		for (column in columns) column.ready(items);
	}
	//
	function initBaseFilters() {
		filters.push(new TableFilterGroup());
	}
	function initFilters(items) {
		initBaseFilters();
		for (filter in filters) filter.ready(items);
		for (column in columns) if (column.canFilter) filters.push(column);
	}
	public function createFilterPicker() {
		var ctr = document.createDivElement();
		ctr.classList.add("filter-picker");
		//
		var select = document.createSelectElement();
		select.appendOption("");
		for (filter in filters) select.appendOption(filter.getFullName(), filter.name);
		//
		var button = document.createInputElement();
		button.type = "button";
		button.value = "Add Filter";
		button.addEventListener("click", (e) -> {
			var name = select.value;
			if (name == "") return;
			var filter = filters.filter(f -> f.name == name)[0];
			if (filter == null) return;
			var section = filter.createSection(this);
			ctr.before(section);
		});
		//
		ctr.append(select);
		ctr.append(" ");
		ctr.append(button);
		return ctr;
	}
	public function updateFilters() {
		var even = true;
		var found = 0;
		for (item in items) {
			var ok = true;
			for (pair in TableTools.getFilters(this, filterContainer)) {
				if (!pair.filter.matchesFilter(pair.section, this, item)) {
					ok = false;
					break;
				}
			}
			if (ok) {
				item.row.style.display = "";
				if (even) {
					item.row.classList.add("visibly-even");
				} else item.row.classList.remove("visibly-even");
				even = !even;
				found += 1;
			} else item.row.style.display = "none";
		}
		if (counterElement != null) counterElement.innerText = found + "/" + items.length;
	}
	public function updateFiltersOn(el:Element, event = "change") {
		el.addEventListener(event, (_) -> {
			updateFilters();
		});
	}
	public function saveFilters() {
		var result = [];
		for (pair in TableTools.getFilters(this, filterContainer, true)) {
			result.push(pair.filter.saveFilter(pair.section, this));
		}
		return result;
	}
	public function parseFilter(obj:DynamicAccess<Any>) {
		var type = obj[TableFilter.typeKey];
		if (type == null) return null;
		var filter = filters.filter(f -> f.name == type)[0];
		if (filter == null) return null;
		var section = filter.createSection(this);
		filter.loadFilter(section, this, obj);
		return section;
	}
	public function loadFilters(arr:Array<DynamicAccess<Any>>) {
		for (pair in TableTools.getFilters(this, filterContainer, true)) {
			pair.section.remove();
		}
		for (obj in arr) {
			var section = parseFilter(obj);
			if (section != null) {
				rootFilterPicker.before(section);
			}
		}
	}
	function sort(by:Column<T>) {
		resetOrderElement.style.display = "";
		var curr = header.querySelector("th[data-sort]");
		if (curr != null && curr != by.header) {
			curr.removeAttribute("data-sort");
		}
		var desc = by.header.getAttribute("data-sort") == "asc";
		by.header.setAttribute("data-sort", desc ? "desc" : "asc");
		//
		var sorted = items.copy();
		if (desc) {
			sorted.sort((a, b) -> by.compare(a, b));
		} else {
			sorted.sort((a, b) -> -by.compare(a, b));
		}
		for (item in sorted) {
			header.after(item.row);
		}
	}
	function afterBuild() {
		updateFilters();
	}
	public function build() {
		table = cast document.getElementById("table");
		//
		initColumns();
		//
		initFilters(items);
		filterContainer.append(rootFilterPicker = createFilterPicker());
		//
		header = document.createTableRowElement();
		header.classList.add("header");
		for (col in columns) if (col.show) {
			var th = document.createElement("th");
			col.buildHeader(th);
			col.header = th;
			if (col.canSort) {
				th.classList.add("can-sort");
				if (th.title != "") {
					th.title += "\nClick to sort";
				} else th.title = "Click to sort";
				th.addEventListener("click", (e:MouseEvent) -> {
					sort(col);
					e.preventDefault();
					return false;
				});
			}
			header.append(th);
		}
		table.append(header);
		//
		for (attack in items) {
			var tr = attack.row;
			for (col in columns) if (col.show) {
				var td = document.createTableCellElement();
				col.buildValue(td, attack);
				tr.append(td);
			}
			table.append(tr);
		}
		//
		afterBuild();
	}
}
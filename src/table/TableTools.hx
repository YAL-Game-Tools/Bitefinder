package table;

import js.html.Element;
import js.Browser.document;
using tools.HtmlTools;

class TableTools {
	static function add(to:Element, label:String, fn:Void->Void) {
		var button = document.createAnchorElement();
		button.href = "javascript:void(0)";
		button.classList.add("order-control");
		button.append(label);
		button.addEventListener("click", (e) -> {
			fn();
		});
		to.append(button);
	}
	public static function addOrderControls(subject:Element, to:Element, ?then:Void->Void) {
		add(to, "↑", () -> {
			var prev = subject.previousElementSibling;
			if (prev.className == subject.className) {
				prev.before(subject);
			}
		},);
		add(to, "↓", () -> {
			var next = subject.nextElementSibling;
			if (next.className == subject.className) {
				next.after(subject);
			}
		});
		add(to, "x", () -> {
			subject.remove();
			if (then != null) then();
		});
	}
	public static function getFilters<T:TableValue>(
		table:Table<T>, el:Element, includeDisabled = false
	):Array<{ section: Element, filter: TableFilter<T> }> {
		var found = [];
		for (section in el.querySelectorEls("& > .filter")) {
			var filter:TableFilter<T> = (cast section).yalTableFilter;
			if (filter != null
				&& (includeDisabled || filter.getEnableCheckbox(section).checked)
			) {
				found.push({ section: section, filter: filter });
			}
		}
		return found;
	}
}
package columns;

import js.html.TableCellElement;

class MultiLinkColumn<T:table.TableValue> extends LinkColumnBase<T> {
	public var getter:T->Array<WikiLink>;
	public function new(name, getter) {
		super(name);
		isMulti = true;
		this.getter = getter;
	}
	override function ready(items:Array<T>) {
		for (item in items) {
			for (link in getter(item)) {
				addKnownValue(link);
			}
		}
		super.ready(items);
	}
	override function getLinks(item:T):Array<WikiLink> {
		return getter(item);
	}
}
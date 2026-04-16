package columns;

import js.html.TableCellElement;

class MultiLinkColumn<T:table.TableValue> extends LinkColumnBase<T> {
	public var getter:T->Array<WikiLink>;
	public function new(name, getter) {
		super(name);
		isMulti = true;
		this.getter = getter;
	}
	public static function createForNames<T:table.TableValue>(name, getter:T->Array<String>) {
		return new MultiLinkColumn(name, function(item) {
			var arr = getter(item);
			return arr.map(name -> WikiLink.parseOne(name));
		});
	}
	public static function createForEnums<T:table.TableValue, E:String>(name, getter:T->Array<E>) {
		return new MultiLinkColumn(name, function(item) {
			var arr = getter(item);
			return arr.map(name -> WikiLink.parseOne(name));
		});
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
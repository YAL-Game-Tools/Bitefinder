package columns;

class LinkColumn<T:table.TableValue> extends LinkColumnBase<T> {
	public var getter:T->WikiLink;
	public function new(name, getter) {
		super(name);
		this.getter = getter;
		canSort = true;
	}
	override function compare(a:T, b:T):Int {
		var av = getter(a)?.name;
		var bv = getter(b)?.name;
		return (av == bv) ? 0 : (av < bv ? -1 : 1);
	}
	override function ready(items:Array<T>) {
		for (item in items) addKnownValue(getter(item));
		super.ready(items);
	}
	override function getLinks(item:T):Array<WikiLink> {
		var link = getter(item);
		return link != null ? [link] : [];
	}
}
package columns;

class LinkColumn<T:table.TableValue> extends LinkColumnBase<T> {
	public var getter:T->WikiLink;
	public function new(name, getter) {
		super(name);
		this.getter = getter;
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
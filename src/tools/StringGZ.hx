package tools;

import js.lib.Uint8Array;
import js.lib.Promise;

@:native("StringGZ")
extern class StringGZ {
	static function compress(str:String):Promise<Uint8Array>;
	static function decompress(bytes:Uint8Array):Promise<String>;
}
import haxe.io.Bytes;
import haxe.io.Path;
import sys.io.File;
import haxe.macro.Context;
import haxe.macro.Compiler;
import sys.FileSystem;
using StringTools;

class PostBuild {
	public static macro function run():Void {
		Context.onAfterGenerate(() -> {
			var inDir = "data";
			var outDir = "bin/data";
			if (!FileSystem.exists(outDir)) {
				FileSystem.createDirectory(outDir);
			}
			for (rel in FileSystem.readDirectory(inDir)) {
				var name = Path.withoutExtension(rel);
				var md = File.getContent('$inDir/$rel').replace("\r", "");
				var js = [
					'window.AutoData ??= {};',
					'AutoData.$name = `$md`;',
				].join("\n");
				var jsRel = Path.withExtension(rel, "js");
				var jsBytes = Bytes.ofString(js);
				var jsBytesBOM = Bytes.alloc(jsBytes.length + 3);
				for (i => b in [0xEF, 0xBB, 0xBF]) {
					jsBytesBOM.set(i, b);
				}
				jsBytesBOM.blit(3, jsBytes, 0, jsBytes.length);
				File.saveBytes('$outDir/$jsRel', jsBytesBOM);
			}
		});
	}
}
package refactor.discover;

import haxe.io.Path;

class File {
	public var name:String;
	public var packageIdentifier:Null<Identifier>;
	public var importHxFile:Null<File>;
	public var importList:Array<Import>;
	public var typeList:Array<Type>;
	public var importInsertPos:Int;

	public function new(name:String) {
		this.name = name;
	}

	public function init(packageIdent:Null<Identifier>, imports:Array<Import>, types:Array<Type>, posForImport:Int) {
		packageIdentifier = packageIdent;
		importList = imports;
		typeList = types;
		importInsertPos = posForImport;
	}

	public function getPackage():String {
		if (packageIdentifier != null) {
			return packageIdentifier.name;
		}
		return "";
	}

	public function importsPackage(packName:String):ImportStatus {
		if (packName.length <= 0) {
			return Global;
		}
		if (packName == getPackage()) {
			return SamePackage;
		}
		for (importEntry in importList) {
			if (importEntry.moduleName.name == packName) {
				if (importEntry.alias != null) {
					return ImportedWithAlias(importEntry.alias.name);
				}
				return Imported;
			}
		}

		if (importHxFile == null) {
			return None;
		}
		return importHxFile.importsPackage(packName);
	}

	public function getMainModulName():String {
		var path:Path = new Path(name);

		return path.file;
	}

	public function getIdentifier(pos:Int):Null<Identifier> {
		if (packageIdentifier != null && packageIdentifier.containsPos(pos)) {
			return packageIdentifier;
		}
		for (imp in importList) {
			if (imp.alias != null && imp.alias.containsPos(pos)) {
				return imp.alias;
			}
			if (imp.moduleName.containsPos(pos)) {
				return imp.moduleName;
			}
		}
		for (type in typeList) {
			var identifier:Identifier = type.findIdentifier(pos);
			if (identifier != null) {
				return identifier;
			}
		}
		return null;
	}

	public function findAllIdentifiers(matcher:IdentifierMatcher):Array<Identifier> {
		var results:Array<Identifier> = [];
		if (packageIdentifier != null && matcher(packageIdentifier)) {
			results.push(packageIdentifier);
		}
		for (imp in importList) {
			if (imp.alias != null && matcher(imp.alias)) {
				results.push(imp.alias);
			}
			if (matcher(imp.moduleName)) {
				results.push(imp.moduleName);
			}
		}
		for (type in typeList) {
			results = results.concat(type.findAllIdentifiers(matcher));
		}
		return results;
	}
}

typedef Import = {
	var moduleName:Identifier;
	@:optional var alias:Null<Identifier>;
	var starImport:Bool;
}

typedef ImportAlias = {
	var name:String;
	var pos:IdentifierPos;
}

enum ImportStatus {
	None;
	Global;
	SamePackage;
	Imported;
	ImportedWithAlias(alias:String);
}

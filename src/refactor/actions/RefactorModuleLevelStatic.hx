package refactor.actions;

import refactor.actions.Refactor.RefactorResult;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.discover.IdentifierPos;
import refactor.edits.Changelist;

class RefactorModuleLevelStatic {
	public static function refactorModuleLevelStatic(context:RefactorContext, file:File, identifier:Identifier):RefactorResult {
		var changelist:Changelist = new Changelist(context);

		var packageName:String = file.getPackage();
		var mainModulName:String = file.getMainModulName();

		var filesWithStaticImport:Array<String> = [];
		// all uses with module.identifier
		var withModul:String = '$mainModulName.${identifier.name}';
		var newWithModul:String = '$mainModulName.${context.what.toName}';
		refactorIdentifier(context, changelist, withModul, newWithModul, filesWithStaticImport);

		if (packageName.length > 0) {
			// all uses with pack.module.identifier
			var fullQualified:String = '$packageName.$mainModulName.${identifier.name}';
			var newFullQualified:String = '$packageName.$mainModulName.${context.what.toName}';
			refactorIdentifier(context, changelist, fullQualified, newFullQualified, filesWithStaticImport);
		}
		// all uses without module in own file or files with static import
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers(identifier.name);
		for (use in allUses) {
			if ((use.pos.fileName != file.name) && (!filesWithStaticImport.contains(use.pos.fileName))) {
				continue;
			}
			changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos));
		}
		return changelist.execute();
	}

	static function refactorIdentifier(context:RefactorContext, changelist:Changelist, searchName:String, replaceName:String,
			filesWithStaticImport:Array<String>) {
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers(searchName);
		for (use in allUses) {
			if (use.type.match(ImportModul)) {
				filesWithStaticImport.push(use.pos.fileName);
			}
			changelist.addChange(use.pos.fileName, ReplaceText(replaceName, use.pos));
		}
		var searchNameDot:String = '$searchName.';
		var replaceNameDot:String = '$replaceName.';
		allUses = context.nameMap.getStartsWith(searchNameDot);
		for (use in allUses) {
			var pos:IdentifierPos = {
				fileName: use.pos.fileName,
				start: use.pos.start,
				end: use.pos.start + searchNameDot.length
			}
			changelist.addChange(use.pos.fileName, ReplaceText(replaceNameDot, pos));
		}
	}
}

package refactor.discover;

typedef UsageContext = {
	var file:Null<File>;
	var fileName:String;
	var usageCollector:UsageCollector;
	var nameMap:NameMap;
	var fileList:FileList;
	var type:Null<Type>;
}

window.onload = function() {
	var preElements = document.getElementsByTagName('pre');
	for(var i = 0; i < preElements.length; ++ i)
	{
		var element = preElements[i];
		element.innerHTML = element.innerHTML.replace(/^#/gm,'<tt>#</tt>').replace(/^\$/gm,'<tt>$</tt>');
	}
}

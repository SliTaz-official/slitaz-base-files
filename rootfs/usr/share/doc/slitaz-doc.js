window.onload = function() {
	var preElements = document.getElementsByTagName('pre');
	for(var i = 0; i < preElements.length; ++ i)
	{
		var element = preElements[i];
		element.innerHTML = element.innerHTML.replace(/^#/gm,'<tt>#</tt>').replace(/^\$/gm,'<tt>$</tt>');
	}

	// <details> html element not supported in the current SliTaz gtk-webkit
	// use custom <x-details> instead
	var detailsElements = document.getElementsByTagName('x-details');
	for(var i = 0; i < detailsElements.length; ++ i)
	{
		var element = detailsElements[i];
		element.innerHTML = '<input type="checkbox" id="details' + i +
			'"/><label for="details' + i + '"><span>' +
			element.innerHTML + '</span></label>';
	}

	var sections = document.getElementsByTagName('section');
	for(var i = 0; i < sections.length; ++ i)
	{
		sections[i].dataset.title = sections[i].firstElementChild.innerHTML;
	}
}

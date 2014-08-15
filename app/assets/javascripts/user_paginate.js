function user_paginate(target) {
	$.ajax({
		url: target, 
		dataType: 'html',
	}).
	success(function(data) {
		var html = $.parseHTML(data);
		var pagination = $(html).find('div.pagination').html();
		var results = $(html).find('ul.users').html();
		$('div.pagination').html(pagination);
		$('ul.users').html(results);
	});
	event.preventDefault();
}

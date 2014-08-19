function ajax_paginate(target) {
	$.ajax({
		url: target, 
		dataType: 'html',
	}).
	success(function(data) {
		var html = $.parseHTML(data);
		var pagination = $(html).find('div.pagination').html();
		var results = $(html).find('.apaginate_container').html();
		$('div.pagination').html(pagination);
		$('.apaginate_container').html(results);
	});
	event.preventDefault();
}

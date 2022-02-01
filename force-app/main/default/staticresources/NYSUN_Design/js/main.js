$('.popper').popover({
	container: 'body',
	html: true,
	//placement: popover_placement,
	content: function () {
		return $(this).next('.popover-content').html();
	}
});

//var popover_placement = {
//	placement: function (context, source) {
//		var position = $(source).position();
//
//		if (position.left > 515) {
//			return "left";
//		}
//		if (position.left < 515) {
//			return "right";
//		}
//		if (position.top < 110){
//			return "bottom";
//		}
//		return "top";
//	}, trigger: "click"
//};

// Turn on all tooltips
$(function () {
	$('[data-toggle="tooltip"]').tooltip();
});

$(function () {
	$('[data-toggle="popover"]').popover();
});

// Destroy the popover when anything is clicked
$('html').on('mouseup', function(e) {
	if(!$(e.target).closest('.popover').length) {
		$('.popover').each(function(){
			$(this.previousSibling).popover('hide');
		});
	}
});

// Destroy the popover when another is shown
$('body').popover({
	selector: '[rel=popover]',
	trigger: "hover"
}).on("show.bs.popover", function(e){
	$("[rel=popover]").not(e.target).popover("destroy");
	$(".popover").remove();
});

// Rollup after scrolling
$(function(){
	var rollup = 440;
	$(window).scroll(function() {
		var scroll = getCurrentScroll();
		if ( scroll >= rollup ) {
			$('body').addClass('scrolled');
		}
		else {
			$('body').removeClass('scrolled');
		}
	});
	function getCurrentScroll() {
		return window.pageYOffset || document.documentElement.scrollTop;
	}
});

$('.select2').select2();

$(".select2-tags").select2({
	tags: true,
	width: 'resuolve'
});

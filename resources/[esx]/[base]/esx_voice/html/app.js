window.addEventListener('message', function(event) {
	$("#container").stop(false, true);

    if (event.data.displayWindow == 'true') {
        $("#container").css('display', 'flex');
        $("#container").animate({
        	bottom: "25%",
        	opacity: "1.0"
        }, 700, function() {
        });
    } else {
    	$("#container").animate({
        	bottom: "-50%",
        	opacity: "0.0"
        }, 700, function() {
        	$("#container").css('display', 'none');
        });
    }
});
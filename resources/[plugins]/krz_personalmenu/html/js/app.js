$(document).ready(function () {
	window.addEventListener('message', function (event) {
		var item = event.data;

		if (item.openCinema == true) {
			$("html").css("display", "block");
		}

		if (item.openCinema == false) {
			$("html").css("display", "none");
		}
	});
});
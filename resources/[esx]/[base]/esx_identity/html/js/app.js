$("#prenom").focus(function () {
	$(".prenom-help").slideDown(500);
}).blur(function () {
	$(".prenom-help").slideUp(500);
});

$("#nom").focus(function () {
	$(".nom-help").slideDown(500);
}).blur(function () {
	$(".nom-help").slideUp(500);
});

$("#date").focus(function () {
	$(".date-help").slideDown(500);
}).blur(function () {
	$(".date-help").slideUp(500);
});

$("#taille").focus(function () {
	$(".taille-help").slideDown(500);
}).blur(function () {
	$(".taille-help").slideUp(500);
});

$(function() {
	window.addEventListener('message', function(event) {
		if (event.data.type == "enableui") {
			document.body.style.display = event.data.enable ? "block" : "none";
		}
	});

	document.onkeyup = function (data) {
		if (data.which == 27) { // Escape key
			$.post('http://esx_identity/escape', JSON.stringify({}));
		}
	};
	
	$("#register").submit(function(event) {
		event.preventDefault();

		$.post('http://esx_identity/register', JSON.stringify({
			firstname: $("#prenom").val(),
			lastname: $("#nom").val(),
			dateofbirth: $("#date").val(),
			sex: $("input[type='radio'][name='radioFruit']:checked").val(),
			height: $("#taille").val()
		}));
	});
});
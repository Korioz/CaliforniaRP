$(function () {
	window.addEventListener('message', function (event) {
		var data = event.data;

		if (data.action === "hideUi") {
			if (data.value === true) {
				$("#ui").hide();
			} else {
				$("#ui").show();
			}
		} else if (data.action === "fadeUi") {
			if (data.value === true) {
				$("#ui").hide(500);
			} else {
				$("#ui").show(500);
			}
		} else if (data.action === "hideComponent") {
			if (data.value === true) {
				$("#" + data.component).hide();
			} else {
				$("#" + data.component).show();
			}
		} else if (data.action === "setStatuts") {
			for (i = 0; i < data.statuts.length; i++) {
				$(".statut .container #" + data.statuts[i].name + ".state").width(data.statuts[i].value + '%');
			}
		} else if (data.action === "setInfos") {
			$.each(data.infos, function (index, value) {
				$(".info .container #" + value.name + ".state").fadeTo(500, 0, function () {
					$(".info .container #" + value.name + ".state").html(value.value);
					$(".info .container #" + value.name + ".state").fadeTo(500, 1);
				});
			})
		}
	})
})
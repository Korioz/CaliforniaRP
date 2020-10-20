$(function () {
	window.addEventListener('message', function (event) {
		var data = event.data;

		if (data.action == 'open') {
			var userData = data.array['user'];
			var licenseData = data.array['licenses'];

			if (data.type == 'driver') {
				$('img').show();
				$('#name').css('color', '#282828');

				if (userData.sex.toLowerCase() == 'm') {
					$('img').attr('src', 'img/male.png');
					$('#sex').text('homme');
				} else {
					$('img').attr('src', 'img/female.png');
					$('#sex').text('femme');
				}

				$('#name').text(userData.firstname + ' ' + userData.lastname);
				$('#dob').text(userData.dateofbirth);
				$('#height').text(userData.height);
				$('#signature').text(userData.lastname);

				if (licenseData != null) {
					Object.keys(licenseData).forEach(function (key) {
						var type2 = licenseData[key].type;

						if (type == 'drive_bike') {
							type2 = 'bike';
						} else if (type2 == 'drive_truck') {
							type2 = 'truck';
						} else if (type2 == 'drive') {
							type2 = 'car';
						}

						if (type2 == 'bike' || type2 == 'truck' || type2 == 'car') {
							$('#licenses').append('<p>' + type2 + '</p>');
						}
					});
				}

				$('#id-card').css('background', 'url(img/license.png)');
			} else if (data.type == 'weapon') {
				$('img').show();
				$('#name').css('color', '#d9d9d9');
				$('#name').text(userData.firstname + ' ' + userData.lastname);
				$('#dob').text(userData.dateofbirth);
				$('#signature').text(userData.lastname);
				$('#id-card').css('background', 'url(img/firearm.png)');
			} else {
				$('img').show();
				$('#name').css('color', '#282828');

				if (userData.sex.toLowerCase() == 'm') {
					$('img').attr('src', 'img/male.png');
					$('#sex').text('homme');
				} else {
					$('img').attr('src', 'img/female.png');
					$('#sex').text('femme');
				}

				$('#name').text(userData.firstname + ' ' + userData.lastname);
				$('#dob').text(userData.dateofbirth);
				$('#height').text(userData.height);
				$('#signature').text(userData.lastname);
				$('#id-card').css('background', 'url(img/idcard.png)');
			}

			$('#id-card').fadeTo(500, 1);
		} else if (data.action == 'close') {
			$('#id-card').fadeTo(500, 0);
		}
	});
});
$(function() {
	particlesJS('header',
		{
			"particles": {
				"number": {
					"value": 50,
					"density": {
						"enable": true,
						"value_area": 800
					}
				},
				"color": {
					"value": "#ffffff"
				},
				"shape": {
					"type": "circle",
					"stroke": {
						"width": 0,
						"color": "#000000"
					},
					"polygon": {
						"nb_sides": 5
					},
					"image": {
						"src": "img/github.svg",
						"width": 100,
						"height": 100
					}
				},
				"opacity": {
					"value": 0.12626362266116362,
					"random": false,
					"anim": {
						"enable": false,
						"speed": 1,
						"opacity_min": 0.1,
						"sync": false
					}
				},
				"size": {
					"value": 3,
					"random": true,
					"anim": {
						"enable": false,
						"speed": 40,
						"size_min": 0.1,
						"sync": false
					}
				},
				"line_linked": {
					"enable": true,
					"distance": 150,
					"color": "#ffffff",
					"opacity": 0.14204657549380909,
					"width": 1
				},
				"move": {
					"enable": true,
					"speed": 6,
					"direction": "none",
					"random": false,
					"straight": false,
					"out_mode": "out",
					"bounce": false,
					"attract": {
						"enable": false,
						"rotateX": 600,
						"rotateY": 1200
					}
				}
			},
			"interactivity": {
				"detect_on": "canvas",
				"events": {
					"onhover": {
						"enable": true,
						"mode": "repulse"
					},
					"onclick": {
						"enable": true,
						"mode": "push"
					},
					"resize": true
				},
				"modes": {
					"grab": {
						"distance": 400,
						"line_linked": {
							"opacity": 1
						}
					},
					"bubble": {
						"distance": 400,
						"size": 40,
						"duration": 2,
						"opacity": 8,
						"speed": 3
					},
					"repulse": {
						"distance": 200,
						"duration": 0.4
					},
					"push": {
						"particles_nb": 4
					},
					"remove": {
						"particles_nb": 2
					}
				}
			},
			"retina_detect": true
		}
	);

	easy_background(".background-image",
		{
			slide: ["img/1.png", "img/2.jpg", "img/3.jpg", "img/4.jpg", "img/5.jpg", "img/6.jpg"],
			delay: [4400, 4400, 4400, 4400, 4400]
		}
	);

	easy_background("#slider",
		{
			slide: ["img/1.png", "img/2.jpg", "img/3.jpg", "img/4.jpg", "img/5.jpg", "img/6.jpg"],
			delay: [4400, 4400, 4400, 4400, 4400]
		}
	);

	$('audio#song1')[0].play()

	window.addEventListener('keydown', function (event) {
		switch (event.keyCode) {
			case 32:
				event.preventDefault();
				audio_element.paused ? audio_element.play() : audio_element.pause();
				break
			case 38:
				event.preventDefault();
				audio_vol = audio_element.volume;

				if (audio_vol != 1) {
					try {
						audio_element.volume = audio_vol + 0.02;
					} catch (err) {
						audio_element.volume = 1;
					}

				}

				break;
			case 40:
				event.preventDefault();
				audio_vol = audio_element.volume;

				if (audio_vol != 0) {
					try {
						audio_element.volume = audio_vol - 0.02;
					} catch (err) {
						audio_element.volume = 0;
					}

				}

				break;
		}
	});
});
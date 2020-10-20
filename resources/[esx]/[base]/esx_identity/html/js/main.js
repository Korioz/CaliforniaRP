$(document).ready(function () {
	Date.prototype.toShortDateString = function () {
		return (this.getMonth() + 1) + "/" + this.getDate() + "/" + this.getFullYear();
	}

	function isTextSelected(input) {
		if (typeof input.selectionStart == "number" && input.selectionStart != input.value.length && input.selectionStart != input.selectionEnd) {
			return true;
		} else if (typeof document.selection != "undefined") {
			input.focus();
			return document.selection.createRange().text == input.value;
		}
		return false;
	}

	function isNumber(e) {
		var allowedKeys = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105];
		if ($.inArray(e.keyCode, allowedKeys) != -1 && !e.originalEvent.shiftKey) {
			return true;
		}
		return false;
	}

	function isBackspace(keyCode) {
		var allowedKeys = [8];
		if ($.inArray(keyCode, allowedKeys) != -1) {
			return true;
		}
		return false;
	}

	function isAllowedKey(keyCode) {
		var allowedKeys = [9, 13, 16, 37, 38, 39, 40]; //191,111];
		if ($.inArray(keyCode, allowedKeys) != -1) {
			return true;
		}
		return false;
	}

	$.fn.extend({
		allowMMDDYYYY: function (validate) {
			$(this).keydown(function (e) {
				var that = this;
				if (!isNumber(e) && !isBackspace(e.keyCode) && !isAllowedKey(e.keyCode)) {
					e.preventDefault();
				} else if ($(that).val().length == 10 && !isBackspace(e.keyCode) && !isAllowedKey(e.keyCode)) { // && !isTextSelected(e.target) && isNumber(e.keyCode)) {
					if (!isTextSelected(e.target) && isNumber(e))
						e.preventDefault();
				}
			});
			$(this).keyup(function (e) {
				var that = this;
				var value = $(that).val();
				if (e.keyCode != 8 && !isAllowedKey(e.keyCode)) {
					switch (value.length) {
						case 2:
							$(that).val(value + "/");
							break;
						case 3:
							if (value.indexOf("/") == -1) {
								$(that).val(value.substr(0, 2) + "/" + value.substr(2, 1));
							}
							break;
						case 4:
							if (value.substr(0, 3).indexOf("/") == -1) {
								$(that).val(value.substr(0, 2) + "/" + value.substr(2, 2));
							}
							break;
						case 5:
							if (e.target.selectionStart == value.length) {
								if (e.target.selectionStart != 1) {
									$(that).val(value + "/");
								}
							}
							break;
						case 6:
							if (e.target.selectionStart == value.length) {
								if (value.substr(5).indexOf("/") == -1) {
									$(that).val(value.substr(0, 5) + "/" + value.substr(5, 1));
								}
							} else if (e.target.selectionStart == 2) {
								$(that).val(value.substr(0, 2) + "/" + value.substr(2))
								e.target.selectionStart = 3;
								e.target.selectionEnd = 3;
							}
							break;
						case 7:
							if (e.target.selectionStart == value.length) {
								if (value.substr(5).indexOf("/") == -1) {
									$(that).val(value.substr(0, 6) + "/" + value.substr(5, 2));
								}
							} else if (e.target.selectionStart == 2) {
								$(that).val(value.substr(0, 2) + "/" + value.substr(2));
								e.target.selectionStart = 3;
								e.target.selectionEnd = 3;
							}
							break;
						case 9:
							if (value.substr(3, 5).indexOf("/") == -1) {
								$(that).val(value.substr(0, 5) + "/" + value.substr(5))
							} else if (value.substr(0, 3).indexOf("/") == -1) {
								$(that).val(value.substr(0, 2) + "/" + value.substr(2))
							}
							break;
						case 10:
							if (!isTextSelected(e.target)) {
								validate();
							}
							break;
					}
				}
			});
		}
	});

	$("input[data-role='datepicker']").each(function (i, o) {
		var jqueryElement = $(o);
		jqueryElement.allowMMDDYYYY(function () {});
	});
});
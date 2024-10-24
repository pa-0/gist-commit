var stopwatch = function(my_element_id) {
	var $time = document.getElementById(my_element_id)
	if(!$time) return

	var api = {}
	var duration = 50
	var time = 0
	var clocktimer
	var h, m, s, ms

	function pad(num, size) {
	    var s = "0000" + String(num)
	    return s.substr(s.length - size)
	}

	function formatTime() {
	    time += duration
	    h = Math.floor( time / (60 * 60 * 1000) )
	    m = Math.floor( time / (60 * 1000) % 60)
	    s = Math.floor(  time / 1000 % 60 )
	    ms = time % 1000 / 10
	    return pad(h, 2) + ':' + pad(m, 2) + ':' + pad(s, 2) + ':' + pad(ms, 2)
	}

	function update() {
	    $time.innerHTML = formatTime()
	}

	api.start = function() {
	    clocktimer = setInterval(update, duration)
	}

	api.stop = function() {
	    clearInterval(clocktimer)
	}

	api.formatTime = formatTime

	return api
}


// ==UserScript==
// @name        github.gists
// @namespace   http://mikedamage.github.com
// @description Adds a few site specific dock menu items to Github Gists.
// @include     http://gist.github.com/*
// @author      Mike Green
// ==/UserScript==

(function () {
    if (window.fluid) {
			function dockJump(name, path) {
				window.fluid.addDockMenuItem(name, function() {
					window.location = path;
				});
			}
			dockJump("My Gists", "http://gist.github.com/mine");
			dockJump("New Gist", "http://gist.github.com/");
			dockJump("All Gists", "http://gist.github.com/gists");
    }

		if (window.location.href == "http://gist.github.com/mine") {
			$('<div id="gist_floater"><h4>My Gists</h4><ul></ul></div>').appendTo("body");
			
			$('#gist_floater').css({
				position: 'fixed',
				top: '100px',
				right: '20px',
				width: '200px',
				border: '1px solid #000',
				textAlign: 'left',
				padding: '10px',
				fontSize: '10px',
				color: '#aaa',
				'-webkit-border-radius': '8px'
			})
			.hide();
				
			var titles = $("div.meta > .info");
			titles.each(function(i) {
				var link = $(this).children("span").eq(0).html();
				var desc = $(this).children("span").eq(1).html();
				
				if (desc == "") {
					$("#gist_floater").append('<li>'+link+'</li>');
				} else {
					$("#gist_floater").append('<li>'+link+'<em>('+desc+')</em></li>');
				}
			});
			$("#gist_floater").show('fast');
		}
})();
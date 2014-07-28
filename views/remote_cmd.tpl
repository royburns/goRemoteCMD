<html>
	<head>
		<title>termlib Remote Terminal</title>
		<script language="JavaScript" type="text/javascript" src="static/js/termlib.js"></script>
		<script language="JavaScript" type="text/javascript" src="static/js/jquery-1.11.1.min.js"></script>

		<script type="text/javascript">
		<!--

		// use strict;
		// path to server script goes here
		var remotePath = '/cmd';

		// a var to stor the last transfered content
		var lastResponse = '';

		var term;

		var help = [
			'%+r **** remote terminal sample **** %-r',
			' ',
			'* use "exit" to quit.',
			'* use "rlogin <username>" for remote login.',
			'* use "rlogout" to clear any rlogin data.',
			'* use "clear" to clear the screen.',
			'* use "help" to see this page.',
			'* any other command will be executed on the remote host.',
			' '
		];

		function termOpen() {
			if ((!term) || (term.closed)) {
				term = new Terminal(
					{
						x: 220,
						y: 70,
						termDiv: 'termDiv',
						bgColor: '#232e45',
						greeting: help.join('\n'),
						handler: termHandler,
						exitHandler: termExitHandler
					}
				);
				// set up some instance properties for server-client communication
				// we use the private namespace "env" of our Terminal instance
				term.env.myHistPtr = 0;
				term.env.dir = '';
				term.env.userid = 'royburns';
				term.env.password = '123123';
				// and open the terminal
				term.open();
				
				// some UI tasks
				var lastResponseLink = (document.getElementById)?
					document.getElementById('lastResponseLink') : document.all.lastResponseLink;
				if (lastResponseLink) lastResponseLink.style.display = 'inline';
				var mainPane = (document.getElementById)?
					document.getElementById('mainPane') : document.all.mainPane;
				if (mainPane) mainPane.className = 'lh15 dimmed';
			}
		}

		function termExitHandler() {
			// reset the UI
			var lastResponseLink = (document.getElementById)?
				document.getElementById('lastResponseLink') : document.all.lastResponseLink;
			if (lastResponseLink) lastResponseLink.style.display = 'none';
			var mainPane = (document.getElementById)?
				document.getElementById('mainPane') : document.all.mainPane;
			if (mainPane) mainPane.className = 'lh15';
		}

		// terminal main loop

		function termHandler() {
			this.newLine();

			// check for raw mode first
			if (this.rawMode) {
				this.rawMode = false;
				if (this.env.getPassword) {
					// we just recieved the password of "rlogin"
					// first store password 
					this.env.password = this.lineBuffer;
					this.env.getPassword = false;
					// store the local terminal history position for later
					term.env.myHistPtr = this.histPtr;
					// send an initial request to verify and get the working dir
					this.send(
						{
							url: remotePath,
							method: 'post',
							callback: socketCallback,
							data: {
								command: 'echo "connection up and ready."',
								dir: '',
								user: this.env.userid,
								pass: this.env.password
							}
						}
					);
					// done, leave without prompt (this will come from the callback)
					return;
				}
				// we shouldn't end here
				this.prompt(); return;
			}

			// clear heading white space from input line
			this.lineBuffer = this.lineBuffer.replace(/^\s+/, '');
			
			// evaluate commands (split to words first)
			var argv = this.lineBuffer.split(/\s+/);
			var cmd = argv[0];
			
			switch (cmd) {
				case 'rlogin':
					if (argv.length<2 || argv[1]=='') {
						this.type('usage: rlogin <username>');
					}
					else {
						this.env.getPassword = true;
						this.env.userid = argv[1];
						this.type('Password: ');
						// exit in raw mode for password (blind input)
						this.rawMode = true;
						this.lock = false;
						return;
					}
					break;

				case 'rlogout':
					// just forget username and password, reset prompt-string
					this.env.dir = '';
					this.env.userid = '';
					this.env.password = '';
					this.ps = '>';
					// reset the local terminal's history to login-state
					this.histPtr = this.env.myHistPtr;
					this.history.length = this.histPtr;
					// clear stored last response
					lastResponse='';
					break;

				case 'clear':
					this.clear();
					break;

				case 'help':
					this.clear();
					this.write(help);
					break;

				case 'exit':
					this.env.dir = '';
					this.env.userid = '';
					this.env.password = '';
					this.close();
					lastResponse='';
					return;

				default:
					// no local command
					if (this.lineBuffer != '') {
						if (!this.env.userid) {
							this.write('Not logged in, sorry.'); // not logged in
						}
						else {
							// send (unparsed) line to server-backend
							this.send(
								{
									url: remotePath,
									// url: remotePath + "/" + this.lineBuffer,
									method: 'post',
									callback: socketCallback,
									data: {
										command: this.lineBuffer,
										dir: this.env.dir,
										// user: this.env.userid,
										// pass: this.env.password,
									}
								}
							);
							// leave without prompt (this will come from the callback)

							// jQuery.ajax
							// $.ajax({
							// 	url: remotePath,
							// 	type: 'POST',
							// 	dataType: 'json',
							// 	data: {
							// 		command: this.lineBuffer,
							// 		dir: this.env.dir,
							// 		user: this.env.userid,
							// 		pass: this.env.password
							// 	},
							// 	success: function(data) {
							// 		console.log(data);
							// 	},
							// 	// success: socketCallback,
							// })
							// .done(function() {
							// 	console.log("success");
							// })
							// .fail(function() {
							// 	console.log("error");
							// })
							// .always(function() {
							// 	console.log("complete");
							// });
							
							return;
						}
					}
			}
			this.prompt();
		}


		// callback for server-client communication

		function socketCallback() {
			var response = this.socket;
			if (response.success) {
				// split the responseText to lines
				// console.log(response.responseText);
				var lines = response.responseText.split('\n');
				// get the last valid line and check it
				if (lines.length > 1 && lines[lines.length-1] == '') lines.length--;
				var lastline = lines[lines.length-1];
				if (lastline.indexOf('dir:') == 0) {
					// if last line starts with "dir:", store this as working dir
					this.env.dir = lastline.substring(4);
					// shorten output
					lines.length--;
					if (lines[lines.length-1] == '') lines.length--;
					// and set the prompt-string of the terminal
					this.ps = '[' + this.env.dir + ']$';
				}
				else if (lines.length == 1 && lastline == 'Sorry.') {
					// autorization failed, clear login properties
					this.env.dir = '';
					this.env.userid = '';
					this.env.password = '';
					this.ps = '>';
					// reset the local terminal's history to login-state
					this.histPtr = this.env.myHistPtr;
					this.history.length = this.histPtr;
				}
				// escape any '%' markups for write
				for (var i=0; i<lines.length; i++) lines[i] = lines[i].replace(/%/g, '%%');
				// write the remaining content to the terminal in more-mode
				this.write(lines, true);
				// store it in a var for later use
				lastResponse = lines.join('\n');
			}
			else {
				var s = 'Request failed: ' + response.status + ' ' + response.statusText;
				if (response.errno) s += '\n'+response.errstring;
				this.write(s);
				// reset any authorization properties
				this.env.dir = '';
				this.env.userid = '';
				this.env.password = '';
				this.ps = '>';
				this.prompt();
			}
		}


		// a function to show the last transfered content in a textarea for copy etc

		function showLastResponse() {
			if ((!term) || (term.closed)) return;
			var d = (document.getElementById)?
				document.getElementById('lastResponseDiv') : document.all.lastResponseDiv;
			if (!d) {
				d = document.createElement('div');
				var s= '<form method="get" onsubmit="return false;">';
				s+= '<table border="0" cellspacing="0" cellpadding="12" style="background-color: #808080; border-style: solid; border-width: 1px; border-color: #999 #555 #555 #999;">';
				s+= '<tr><td style="color: #000; text-align: center;">Last transfered content<\/td><\/tr>';
				s+= '<tr><td><textarea cols="80" rows="24" name="lastResponseDisplay" id="lastResponseDisplay" style="color: #000; background-color: #fff;"><\/textarea><\/td><\/tr>';
				s+= '<tr><td style="color: #000; text-align: right;"><input type="button" value="close" onclick="hideLastResponse()"><\/td><\/tr>';
				s+= '<\/table>';
				s+= '<\/form>';
				d.innerHTML = s;
				d.id = 'lastResponseDiv';
				d.style.display = 'block';
				d.style.position = 'absolute';
				d.style.left = '10px';
				d.style.top = '10px';
				d.style.zIndex = 1000;
				document.body.appendChild(d);
			}
			// lock the terminal's keyHandler in order to release keyboard capture
			TermGlobals.keylock=true;
			// insert the last stored Response
			var f = (document.getElementById)?
				document.getElementById('lastResponseDisplay') : document.all.lastResponseDisplay;
			if (f) f.value = lastResponse;
		}

		function hideLastResponse() {
			var d = (document.getElementById)?
				document.getElementById('lastResponseDiv') : document.all.lastResponseDiv;
			if (d) {
				d.style.display = 'none';
				d.parentNode.removeChild(d);
			}
			// reset the terminal's keyboard lock
			TermGlobals.keylock = false;
		}

		//-->
		</script>

		<style type="text/css">
		body,p,a,td {
			font-family: courier,fixed,swiss,sans-serif;
			font-size: 12px;
			color: #cccccc;
		}
		.lh15 {
			line-height: 15px;
		}

		.term {
			font-family: "Courier New",courier,fixed,monospace;
			font-size: 12px;
			color: #94aad6;
			background: none;
			letter-spacing: 1px;
		}
		.term .termReverse {
			color: #232e45;
			background: #95a9d5;
		}

		a,a:link,a:visited {
			text-decoration: none;
			color: #77dd11;
		}
		a:hover {
			text-decoration: underline;
			color: #77dd11;
		}
		a:active {
			text-decoration: underline;
			color: #eeeeee;
		}

		a.termopen,a.termopen:link,a.termopen:visited {
			text-decoration: none;
			color: #77dd11;
			background: none;
		}
		a.termopen:hover {
			text-decoration: none;
			color: #222222;
			background: #77dd11;
		}
		a.termopen:active {
			text-decoration: none;
			color: #222222;
			background: #eeeeee;
		}

		table.inventory td {
			padding-bottom: 20px !important;
		}

		tt {
			font-family: courier,fixed,monospace;
			color: #ccffaa;
			font-size: 12px;
			line-height: 15px;
		}

		.scriptexample {
			font-family: courier,fixed,swiss,sans-serif;
			font-size: 12px;
			color: #222222;
			background-color: #bbbbbb;
			padding: 12px;
		}

		.dimmed,.dimmed *,.dimmed * * {
			background-color: #222222 !important;
			color: #333333 !important;
		}

		@media print {
			body { background-color: #ffffff; }
			body,p,a,td,li,tt {
				color: #000000;
			}
			pre,.prop {
				color: #000000;
			}
			h1 {
				color: #000000;
			}
			a,a:link,a:visited {
				color: #000000;
			}
			a:hover {
				color: #000000;
			}
			a:active {
				color: #000000;
			}
			table.inventory {
				display: none;
			}
			.scriptexample {
				background-color: #eeeeee !important;
				color: #000000 !important;
			}
		}

		</style>
	</head>


	<body bgcolor="#222222" link="#77dd11" text="#cccccc" alink="#eeeeee" vlink="#77dd11"
	topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" marginheight="0" marginwidth="0">

	<table border="0" cellspacing="20" cellpadding="0" align="center">
	<tr>
		<td nowrap><a href="index.html">termlib.js home</a></td>
		<td>|</td>
		<td nowrap><a href="multiterm_test.html">multiple terminals</a></td>
		<td>|</td>
		<td nowrap><a href="parser_sample.html">parser</a></td>
		<td>|</td>
		<td nowrap><a href="faq.html">faq</a></td>
		<td>|</td>
		<td nowrap><a href="readme.txt" title="readme.txt (text/plain)">documentation</a></td>
		<td>|</td>
		<td nowrap><a href="samples.html" style="color: #cccccc;">samples</a></td>
	</tr>
	</table>

	<table border="0" cellspacing="20" cellpadding="0">
		<tr valign="top">
		<td nowrap>
			<table border="0" cellspacing="0" cellpadding="0" width="190" class="inventory">
			<tr><td nowrap>
				<a href="javascript:termOpen()" onfocus="if(this.blur)this.blur();" onmouseover="window.status='open terminal'; return true" onmouseout="window.status=''; return true" class="termopen">&gt; open terminal&nbsp;</a>
			</td></tr>
			<tr><td nowrap height="34" valign="bottom">
				<a href="javascript:showLastResponse()" onfocus="if(this.blur)this.blur();" onmouseover="window.status='show last transfer document'; return true" onmouseout="window.status=''; return true" class="termopen" id="lastResponseLink" style="display: none;">&gt; show last response&nbsp;</a>
			</td></tr>
			<tr><td nowrap>
				&nbsp;
			</td></tr>
			<tr><td nowrap class="lh15">
				&nbsp;<br>
				remote terminal sample<br>
				(c) mass:werk,<br>N. Landsteiner 2005-2007<br>
				<a href="http://www.masswerk.at/" target="_blank">http://www.masswerk.at</a>
			</td></tr>
			</table>
		</td>
		
		</td>
		</tr>
	</table>

	<div id="termDiv" style="position:absolute; visibility: hidden; z-index:1;"></div>

	</body>
</html>
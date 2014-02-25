
$(function(){
    var test_canvas = $('#host_canvas')[0];
    var ctx = test_canvas.getContext('2d');


	// Purple : '#c1bad9', '#a79fcb'
    // Green  : '#A6CE8D', '#81BA6B'
    // Blue   : '#DEF3F5', '#89C3C6'
    // Red    : '#dc4950', '#e05e65'
    // Orange : '#F1B16E', '#EC9054'
    var main_colors = {'UNKNOWN' : '#c1bad9', 'OK' : '#A6CE8D', 'UP' : '#A6CE8D', 'WARNING' : '#F1B16E', 'CRITICAL' : '#dc4950', 'DOWN' : '#dc4950'};
    var huge_colors = {'UNKNOWN' : '#a79fcb', 'OK' : '#81BA6B', 'UP' : '#81BA6B', 'WARNING' : '#EC9054', 'CRITICAL' : '#e05e65', 'DOWN' : '#e05e65'};
    
    var global_state = $('#host_canvas').data('global-state');
    var main_color = main_colors[global_state];
    var huge_color = huge_colors[global_state];
    var line_color = huge_color;

    var line_s = 2;
    // Inner circle
    draw_arc(ctx, 80, 80, 32, 0, 2*Math.PI, true, main_color, 40, 0.5);
    draw_arc(ctx, 80, 80, 33, 0, 2*Math.PI, true, huge_color, 2, 0.5);

    // Middle one
    draw_arc(ctx, 80, 80, 45, 0, 2*Math.PI, true, main_color, 2, 0.3);
    draw_arc(ctx, 80, 80, 46, 0, 2*Math.PI, true, main_color, 2, 0.3);
    // The left part of the middle
    draw_arc(ctx, 80, 80, 44, 0.7*Math.PI, 1.1*Math.PI, false, huge_color, 4, 0.5);
    //Top rigth art of the middle
    draw_arc(ctx, 80, 80, 44, 1.5*Math.PI, 2*Math.PI, false, huge_color, 4, 0.5);
  

    // Before last one
    // Middle one
    draw_arc(ctx, 80, 80, 60, Math.PI, 0.4*Math.PI, false, main_color, 2, 0.5);
    draw_arc(ctx, 80, 80, 61, Math.PI, 0.4*Math.PI, false, main_color, 2, 0.5);
    // The left part of the before last 
    draw_arc(ctx, 80, 80, 59, Math.PI, 1.7*Math.PI, false, huge_color, 5);
    //Top rigth art of the middle
    draw_arc(ctx, 80, 80, 59, 0, 0.4*Math.PI, false, huge_color, 5);


    /////////////// The status icon
    var img_status = document.createElement('img');
    img_status.onload=function(){
		// Image ratio
		var f = img_status.height / img_status.width;
		var newHeight = ($('#donutWindowsCPU').width() - 20) * f;
        ctx.drawImage(img_status, 50, 40, $('#donutWindowsCPU').width() - 40, ($('#donutWindowsCPU').width() - 40) * f);
    };
    img_status.src = '/static/cv_windows/img/'+$('#host_canvas').data('host-state-image');
    
    //////////////// Lines part
    // Now the line from the left part to down, in 3 parts
    draw_line(ctx, 20, 80, 20, 100, line_color, 1, 0.5);
    draw_line(ctx, 20, 100, 50, 140, line_color, 1, 0.5);
    draw_line(ctx, 50, 140, 50, 200, line_color, 1, 0.5);


    /////////////// The network icon
	var linePos = 150;
	if ($('#host_canvas').data('host-network-state') != 'unknown') {
		// Now a small step down
		draw_line(ctx, 50, linePos, 50, linePos+150, line_color, 1, 0.5);
		linePos += 150;
		// And a small vertical line for disks
		draw_line(ctx, 50, linePos, 100, linePos, line_color, 1, 0.5);

		var img_network = document.createElement('img');
		var img_size = 64;
		img_network.onload=function(){
			ctx.drawImage(img_network, 75, linePos-30, img_size, img_size);
		};
		img_network.src = '/static/cv_windows/img/'+$('#host_canvas').data('host-network-image');
		
		var ip = $('#host_canvas').data('host-network-address');
		ctx.font      = "bold 10px Verdana";
		ctx.fillStyle = "#555";
		ctx.textAlign = 'center';
		ctx.fillText(ip, 105, linePos);
	}

    /////////////// The printer icon
	if ($('#host_canvas').data('host-printer-state') != 'unknown') {
		// Now a small step down
		draw_line(ctx, 50, linePos, 50, linePos+150, line_color, 1, 0.5);
		linePos += 150;
		// And a small vertical line for disks
		draw_line(ctx, 50, linePos, 100, linePos, line_color, 1, 0.5);

		var img_printer = document.createElement('img');
		var img_size = 64;
		img_printer.onload=function(){
			ctx.drawImage(img_printer, 75, linePos-30, img_size, img_size);
		};
		img_printer.src = '/static/cv_windows/img/'+$('#host_canvas').data('host-printer-image');
	}


    // Now a small step on the right, before disks
    draw_line(ctx, 50, 200, 70, 200, line_color, 1, 0.5);
    // And a small vertical line for disks
    draw_line(ctx, 70, 180, 70, 220, line_color, 1, 0.5);


    /////////////// The disks part ...
    var img_disks = document.createElement('img');
    var dsk_x = 75;
    var dsk_y = 190;
    img_disks.onload=function(){
		for(var i=0; i<all_disks.length; i++){
			ctx.drawImage(img_disks, 0, 0, 70, 18, dsk_x, dsk_y, 70, 18);
			var d_name = all_disks[i][0];
			var d_value = all_disks[i][1]/100;
			var offset = 70*d_value;
			ctx.drawImage(img_disks, 0, 18, offset, 18, dsk_x, dsk_y, offset, 18);

			// And draw the disk name
			d_name=d_name+' '+(d_value*100)+'%';
			ctx.font      = "bold 10px Verdana";
			ctx.textAlign = 'left';
			ctx.fillStyle = "#222";
			ctx.fillText(d_name, dsk_x + 5, dsk_y + 13);

			// Now prepare the next disk
			dsk_y += 25;
		}
    };
	// An img for disks image background ...
    img_disks.src = '/static/cv_windows/img/bar_horizontal.png';

    // And a small vertical line for disks
    draw_line(ctx, 150, 180, 150, 220, line_color, 1, 0.5);
	
    // Now a small line to go to the sub-systems
    draw_line(ctx, 150, 200, 200, 200, line_color, 1, 0.5);
	
    // A line that go to the CPU on the top
    draw_line(ctx, 200, 200, 240, 160, line_color, 1, 0.5);
	
    // A line that go to the Memory on the bottom
    draw_line(ctx, 200, 200, 240, 240, line_color, 1, 0.5);
	
    // Now a big line to the right
    draw_line(ctx, 200, 200, 340, 200, line_color, 1, 0.5);

    // And a vertical line for peripherals
    draw_line(ctx, 340, 10, 340, 600, line_color, 1, 0.5);
	
    // Draw the services.
	var sources = {
		ok:				'/static/cv_windows/img/service_ok.png',
		warning:		'/static/cv_windows/img/service_warning.png',
		critical:		'/static/cv_windows/img/service_critical.png',
		unknown:		'/static/cv_windows/img/service_unknown.png',
		pending:		'/static/cv_windows/img/service_pending.png',
		downtime:		'/static/cv_windows/img/service_downtime.png',
		flapping:		'/static/cv_windows/img/service_flapping.png',
		uninstalled:	'/static/cv_windows/img/service_uninstalled.png'
	};
	function loadImages(sources, callback) {
		var images = {};
		var loadedImages = 0;
		var numImages = 0;
		// get num of sources
		for(var src in sources) {
			numImages++;
		}
		for(var src in sources) {
			images[src] = new Image();
			images[src].onload = function() {
				if(++loadedImages >= numImages) {
					callback(images);
				}
			};
			images[src].src = sources[src];
		}
	}
	
	var img_peripheral = document.createElement('img');
    var dev_x = 360;
    var dev_y = 10;
    var img_size = 64;
    var img_spacing = 100;
	var packagesPerColumn = 5;
	var img_src=$('#host_canvas').data('icon-package');
	loadImages(sources, function(images){
		var p_prefix="";
		for (var i=0, column=1, line=1; i<all_packages.length; i++, line++){
			var p_name = all_packages[i][0];
			var p_status = all_packages[i][1];
			// console.log("Service : "+p_name+", status : "+p_status);

			// Next column for the package 
			if ((column != 0) && (line % (packagesPerColumn+1) == 0)) {
				column += 1; line = 1;
				dev_x += img_spacing;
				dev_y = 10;
			}
			
			// Draw package icon
			ctx.drawImage(images[p_status.toLowerCase()], dev_x, dev_y, img_size, img_size);
			
			// And draw the package name
			ctx.font      = "bold 10px Verdana";
			ctx.fillStyle = "#222";
			ctx.textAlign = 'center';
			wrapText(ctx, p_name, dev_x + (img_size/2), dev_y+5, 20, 15)

			var span = $(document.createElement('span'));
			span.html('');
			span.attr('name', p_name);
			span.css('width', img_size+'px');
			span.css('height',img_size+'px');
			span.css('display','inline-block');
			span.css('position', 'absolute');
			span.css('left', dev_x);
			span.css('top', dev_y);
			span.css('cursor', 'pointer');
			span.css('border', 'red');
			span.on('click', function(){
				window.location.href="/service/"+$('#host_canvas').data('name')+"/"+$(this).attr('name');
			});
			$('#host_windows_bloc').append(span);

			// Now prepare the next package
			dev_y += img_spacing;
		}
	});

    // Terminate with the host name and the IP address
    var hname = $('#host_canvas').data('name');
    if (hname.length>=20) hname = hname.substr(0, 17)+'...';
    ctx.font      = "bold 22px Verdana";
    ctx.fillStyle = "#555";
	ctx.textAlign = 'left';
    ctx.fillText(hname, 120, 30);

});
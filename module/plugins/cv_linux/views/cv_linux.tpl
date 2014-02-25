%import json

<script>
	console.log('cv_linux');

	all_perfs = {{json.dumps(all_perfs)}}
	console.log(all_perfs);
	all_disks = all_perfs['all_disks'];
	console.log(all_disks);
	all_states = {{! json.dumps(all_states)}};
	console.log(all_states);
	all_packages = {{! json.dumps(all_perfs['all_packages'])}};
	console.log(all_packages);

	loadjscssfile('/static/cv_linux/js/host_canvas.js', 'js');
	loadjscssfile('/static/cv_linux/css/host_canvas.css', 'css');
</script>

<div id='host_linux_bloc' class='container'>
	<canvas id='host_canvas' width='800' height='480' 
		data-global-state="{{all_states['global']}}" 
		data-name='{{elt.get_name()}}' 
		data-host-state-image="host_{{all_states['global'].lower()}}.png"
		data-host-network-state="{{all_states['network'].lower()}}"
		data-host-network-image="network_{{all_states['network'].lower()}}.png"
		data-host-network-address='{{elt.address}}' 
		data-host-printer-state="{{all_states['printer'].lower()}}"
		data-host-printer-image="printer_{{all_states['printer'].lower()}}.png"
		>
	</canvas>

  %pct_cpu = all_perfs['cpu']
	<div class="donutContainer" id='donut_cpu'>
		<canvas id="donutLinuxCPU" data-value={{pct_cpu}} data-state="{{all_states['cpu']}}" class='donut_canvas' width="100" height="110"></canvas>
		<span class="donut_value">{{pct_cpu}}%</span>
		<span class="donut_label">CPU</span>
	</div>

	<div id='linux_memory_cylinders'>
		%pct_memory = all_perfs['memory']
		<canvas id="cylinder_linux_mem" data-value={{pct_memory}} data-state="{{all_states['memory']}}" class='cylinder_canvas' width="30" height="100"></canvas>
		<span class="cylinder_label mem_label">Mem</span>
		<span class="cylinder_value mem_value">{{pct_memory}}%</span>
		%pct_swap = all_perfs['swap']
		<canvas id="cylinder_linux_swap" data-value={{pct_swap}} data-state="{{all_states['swap']}}" class='cylinder_canvas' width="30" height="100"></canvas>
		<span class="cylinder_label swap_label">Swap</span>
		<span class="cylinder_value swap_value">{{pct_swap}}%</span>
	</div>
</div>


<script>
	$('document').ready(function() {
		register_all_donuts();
		register_all_cylinders();
	});
</script>

extends Game


func _physics_process(delta):
	super._physics_process(delta)


func _process(delta):
	super._process(delta)
	
	# Debug
	
	var states_strings = """Velocity: %s
		Max Distance: %s
		"""
	$Debug/Label.text = states_strings % [$Player.velocity, $Player._max_distance]

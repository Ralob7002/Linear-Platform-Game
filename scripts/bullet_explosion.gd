extends GPUParticles2D

# Variables.
var direction 

# States.
var ON_SCREEN: bool
  

func _ready():
	process_material.direction = Vector3(-1, 0,0)
	$Timer.wait_time = lifetime
	$Timer.start()
	emitting = true
	if ON_SCREEN:
		$ImpactSound.play()


func _on_timer_timeout():
	queue_free()

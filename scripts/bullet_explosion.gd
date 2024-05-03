extends GPUParticles2D

# Variables.
var direction 

# States.
var ON_SCREEN: bool
  

func _ready():
	# Synchronizes the timer with the particle’s lifetime.
	$ParticleDeathTime.wait_time = lifetime 
	$ParticleDeathTime.start()
	
	# Start the particle.
	emitting = true
	
	if ON_SCREEN:
		$ImpactSound.play()


func _on_timer_timeout():
	queue_free()

extends GPUParticles2D

# Variables.
var direction 

# States.
var ON_SCREEN: bool

# References.
@onready var particleDeathTime = $ParticleDeathTime
@onready var impactSound = $ImpactSound
  

func _ready():
	# Synchronizes the timer with the particle’s lifetime.
	particleDeathTime.wait_time = lifetime 
	particleDeathTime.start()
	
	# Start the particle.
	emitting = true
	
	if ON_SCREEN:
		impactSound.play()


func _on_timer_timeout():
	queue_free()

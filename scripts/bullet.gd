extends Area2D

# Scenes.
var explosion: PackedScene = preload("res://scenes/particles/bullet_explosion.tscn")

# Constants.
const speed = 300

# Variables.
var direction = 1

# States.
var ON_SCREEN: bool = true

# References.
@onready var selfDestructionTimer = $SelfDestructionTimer
@onready var impactParticlePosition = $ImpactParticlePosition


func _ready():
	# Time for the bullet to self-destruct.
	selfDestructionTimer.start()


func _physics_process(delta):
	# Move the bullet on the x-axis.
	position.x += direction * speed * delta


func _on_body_entered(_body):
	# Adds impact particle at bullet impact site.
	var new_explosion = explosion.instantiate()
	new_explosion.position = impactParticlePosition.global_position
	new_explosion.ON_SCREEN = ON_SCREEN # If the bullet is on the visible screen.
	get_parent().add_child(new_explosion) # Adds impact particle at current level.
	queue_free()


func _on_death_timer_timeout():
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	ON_SCREEN = false

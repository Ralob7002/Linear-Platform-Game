extends Area2D

# Scenes.
var explosion: PackedScene = preload("res://scenes/bullet_explosion.tscn")

# Constants.
const speed = 300

# Variables.
var direction = 1

# States.
var ON_SCREEN: bool = true


func _ready():
	$DeathTimer.start()

func _physics_process(delta):
	position.x += direction * speed * delta
	
	print(ON_SCREEN)


func _on_body_entered(_body):
	var new_explosion = explosion.instantiate()
	new_explosion.position = $ParticleImpactPosition.global_position
	new_explosion.ON_SCREEN = ON_SCREEN
	get_parent().add_child(new_explosion)
	queue_free()


func _on_death_timer_timeout():
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	ON_SCREEN = false

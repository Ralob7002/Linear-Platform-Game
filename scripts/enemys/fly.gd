extends CharacterBody2D

# Constants.
const speed = 50
const max_life = 3

# Variables.
@export var direction: int = 1 # Right.
var life = max_life

# References.
@onready var wall_detect = $Detectors/WallDetect
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var player_detect = $Detectors/PlayerDetect
@onready var detectors = $Detectors
@onready var collision_shape_2d = $CollisionShape2D
@onready var death_particle = $DeathParticle
@onready var death_timer = $DeathTimer
@onready var visible_on_screen_notifier_2d = $VisibleOnScreenNotifier2D


func _physics_process(_delta):
	if visible_on_screen_notifier_2d.is_on_screen():
		velocity.x = speed * direction
		
		move_and_slide()


func flipH():
	wall_detect.position.x = abs(wall_detect.position.x) * direction
	animated_sprite_2d.flip_h = bool(direction - 1)


func takeDamage(damage):
	life -= damage
	if life <= 0:
		toDie() 
	else:
		modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		modulate = Color.WHITE


func toDie():
	detectors.queue_free()
	collision_shape_2d.queue_free()
	animated_sprite_2d.queue_free()
	death_particle.emitting = true
	death_timer.wait_time = death_particle.lifetime
	death_timer.start()


func _on_wall_detect_body_entered(_body):
	direction = -direction
	flipH()


func _on_player_detect_body_entered(body):
	body.call_deferred("toDie")


func _on_death_timer_timeout():
	queue_free()


func _on_wall_detect_area_entered(_area):
	direction = -direction
	flipH()

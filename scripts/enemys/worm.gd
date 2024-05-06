extends CharacterBody2D

# Cosntants.
var gravity = 980

# States.
var HUNTING: bool = false
var SLEEPING: bool = true

# Variables.
var idle_speed = 25
var hunting_speed = 50
var speed = idle_speed
var direction = 1 # Right or Left.
var max_life = 5
var life = max_life

# References.
@onready var animatedSprite2D = $AnimatedSprite2D
@onready var playerCheck = $DetectNodes/PlayerCheck
@onready var huntingTimer = $HuntingTimer
@onready var deathTimer = $DeathTimer
@onready var deathParticle = $DeathParticle
@onready var collisionShape2D = $CollisionShape2D
@onready var smashDetect = $DetectNodes/SmashDetect
@onready var wallCheck = $DetectNodes/WallCheck
@onready var playerDetect = $DetectNodes/PlayerDetect
@onready var groundCheck = $DetectNodes/GroundCheck


func _physics_process(delta):
	if $VisibleOnScreenNotifier2D.is_on_screen():
		# Applies gravity.
		velocity.y += gravity * delta
		
		# Worm movements.
		movement()
		
		# Move the worm.
		move_and_slide()


func movement():
	if wallCheck.get_collider():
		print("wall")
		direction = -direction
		flipToDirection()
	
	if not groundCheck.get_collider():
		direction = -direction
		flipToDirection()
	
	# Flip the AnimatedSprite2D according to direction.
	$AnimatedSprite2D.flip_h = bool(direction - 1)
	
	# Checks if the Player is in the worm's field of vision.
	if playerCheck.get_collider() and not HUNTING:
		HUNTING = true
		huntingTimer.start()
	
	# Changes the speed according to HUNTING state.
	if HUNTING:
		speed = hunting_speed
		animatedSprite2D.speed_scale = 2
	else:
		speed = idle_speed
		animatedSprite2D.speed_scale = 1
	
	# Movement on the x-axis.
	velocity.x = speed * direction


func takeDamage(damage):
	life -= damage
	if life <= 0:
		toDie()
	else:
		modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		modulate = Color.WHITE


func toDie():
	set_physics_process(false)
	animatedSprite2D.queue_free()
	collisionShape2D.queue_free()
	wallCheck.queue_free()
	smashDetect.queue_free()
	playerDetect.queue_free()
	
	
	deathParticle.emitting = true
	await get_tree().create_timer(deathParticle.lifetime).timeout
	queue_free()


func flipToDirection():
	groundCheck.position.x = abs(groundCheck.position.x) * direction
	wallCheck.target_position.x = abs(wallCheck.target_position.x) * direction
	playerDetect.position.x = abs(playerDetect.position.x) * direction
	playerCheck.target_position.x = abs(playerCheck.target_position.x) * direction


func _on_hunting_timer_timeout():
	HUNTING = false


func _on_smash_detect_body_entered(body):
	if body.IS_FALLING:
		toDie()


func _on_player_detect_body_entered(body):
	body.call_deferred("toDie")

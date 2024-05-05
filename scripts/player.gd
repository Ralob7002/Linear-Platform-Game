extends CharacterBody2D

# Constants.
const speed = 100
const jump_speed = -300
const max_jump_speed = -300
const gravity = 980

# Variables.
var player_direction = 1 # Right.

# Reference.
@onready var footstepSound = $Audio/FootstepSound
@onready var jumpSound = $Audio/JumpSound
@onready var label = $Label
@onready var coyoteTimer = $CoyoteTimer
@onready var animationPlayer = $AnimationPlayer
@onready var shootFlash = $Sprite2D/ShootFlash
@onready var sprite2D = $Sprite2D
@onready var shootTimer = $ShootTimer

# Player states.
var IS_MOVING: bool
var IS_JUMPING: bool
var IS_FALLING: bool
var IS_SHOOTING: bool
var CAN_COYOTE_TIMER: bool = false
var CAN_SHOOT: bool = true
var TAKE_AMMO: bool

# Player signals.
signal dropped_gun(direction)
signal shoot(direction)


func _process(_delta):
	if IS_MOVING and not footstepSound.playing and is_on_floor():
		footstepSound.play()
		
	if TAKE_AMMO:
		label.visible = true
	else:
		label.visible = false


func _physics_process(delta):
	# Applies gravity to the player.
	velocity.y += gravity * delta
	
	# Update player velocity according to the Input.
	movement(delta)
	
	# Weapon system.
	weapon_system()
	
	# Move the player.
	move_and_slide()
	
	# limit for velocity in the y-axis.
	if velocity.y < max_jump_speed:
		velocity.y = max_jump_speed


func movement(_delta):
	# Player Jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or CAN_COYOTE_TIMER):
		velocity.y = jump_speed
		jumpSound.play()
		
	# Player walk.
	var input_direction = Input.get_axis("left_move", "right_move")
	velocity.x = input_direction * speed
	
	# Update player states.
	IS_MOVING = bool(input_direction) # input_direction = 0 = false
	IS_JUMPING = not is_on_floor() and velocity.y < 0
	IS_FALLING = not is_on_floor() and not IS_JUMPING
	
	# Coyote Timer
	if is_on_floor():
		CAN_COYOTE_TIMER = true
		
	if IS_JUMPING:
		CAN_COYOTE_TIMER = false
	
	if IS_FALLING and coyoteTimer.time_left == 0 and CAN_COYOTE_TIMER:
		coyoteTimer.start()

	# Changes the player animation according to the state.
	change_animation(input_direction)


func change_animation(direction):
	# checks if the player is armed.
	var suffix = ""
	if Player.WITH_WEAPON:
		suffix = "_gun" # "animation" + "_gun"
	
	# Walking animation.
	if IS_MOVING and not IS_FALLING and not IS_JUMPING:
		animationPlayer.current_animation = "walk" + suffix
		
	# Idle and Falling animations.
	if (not IS_MOVING or IS_FALLING) and not IS_SHOOTING:
		animationPlayer.current_animation = "idle" + suffix
		
	# Jumping.
	if IS_JUMPING:
		animationPlayer.current_animation = "jump" + suffix
	
	# Shooting.
	if IS_SHOOTING and (not IS_MOVING or IS_FALLING):
		animationPlayer.current_animation = "shooting"
	
	# Change ShootFlash position according to player direction.
	shootFlash.position.x = 15 * player_direction
	
	# Flip animation.
	if direction:
		sprite2D.flip_h = bool(direction - 1)
		shootFlash.flip_h = bool(direction - 1)
		player_direction = direction


func weapon_system():
	if Player.WITH_WEAPON:
		# Drop the current weapon.
		if Input.is_action_just_released("drop_weapon"):
			Player.WITH_WEAPON = false
			dropped_gun.emit(player_direction)
		
		# Emit shoot signal.
		if Input.is_action_pressed("shoot") and Player.ammo > 0:
			IS_SHOOTING = true
			
			# Shoot when the ShootTimer is up
			if CAN_SHOOT:
				CAN_SHOOT = false
				shootTimer.start()
				shoot.emit(player_direction)
		else:
			IS_SHOOTING = false


func checkFlashVisibility(IS_VISIBLE):
	if IS_SHOOTING:
		shootFlash.visible = IS_VISIBLE
	else: 
		shootFlash.visible = false


func toDie():
	Player.reset()
	get_tree().reload_current_scene()


func _on_coyote_timer_timeout():
	CAN_COYOTE_TIMER = false


func _on_shoot_timer_timeout():
	CAN_SHOOT = true

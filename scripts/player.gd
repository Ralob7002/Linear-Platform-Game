extends CharacterBody2D

# Debug.
var _max_distance = 0

# Constants.
const speed = 100
const max_speed = 100
const jump_speed = -300
const max_jump_speed = -300
const gravity = 980
const max_platform_distance = 30

# Variables.
var player_direction = 1

# Player states.
var IS_MOVING: bool
var IS_JUMPING: bool
var IS_FALLING: bool
var WITH_WEAPON: bool
var IS_SHOOTING: bool
var CAN_COYOTE_TIMER: bool = false
var CAN_SHOOT: bool = true
var TAKE_AMMO: bool
var ON_PLATFORM: bool

# Player signals.
signal dropped_gun(direction)
signal shoot(direction)


func _process(_delta):
	WITH_WEAPON = Player.WITH_WEAPON
	
	if IS_MOVING and not $Audio/FootstepSound.playing and is_on_floor():
		$Audio/FootstepSound.play()
		
	if TAKE_AMMO:
		$Label.visible = true
	else:
		$Label.visible = false


func _physics_process(delta):
	# Applies gravity to the player.
	velocity.y += gravity * delta
	
	# Update player velocity according to the Input.
	movement(delta)
	
	# Weapon system.
	weapon_system()
	
	# Move the player.
	move_and_slide()
	
	if velocity.y < max_jump_speed:
		velocity.y = max_jump_speed


func movement(_delta):
	# Jump if the player is on the floor.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or CAN_COYOTE_TIMER):
		velocity.y = jump_speed
		$Audio/AudioStreamPlayer.play()
		
	# Player walk.
	var direction = Input.get_axis("left_move","right_move")
	velocity.x = direction * speed
	
	# Update player states.
	IS_MOVING = bool(direction)
	IS_JUMPING = not is_on_floor() and velocity.y < 0
	IS_FALLING = not is_on_floor() and not IS_JUMPING
	
	# Coyote Timer
	if is_on_floor():
		CAN_COYOTE_TIMER = true
		
	if IS_JUMPING:
		CAN_COYOTE_TIMER = false
	
	if IS_FALLING and $CoyoteTimer.time_left == 0 and CAN_COYOTE_TIMER:
		$CoyoteTimer.start()

	# Changes the player animation according to the state.
	change_animation(direction)


func change_animation(direction):
	# checks if the player is armed.
	var suffix = ""
	if WITH_WEAPON:
		suffix = "_gun"
	
	# Walking.
	if IS_MOVING and not IS_FALLING and not IS_JUMPING:
		$AnimationPlayer.current_animation = "walk" + suffix
		
	# Idle and Falling.
	if (not IS_MOVING or IS_FALLING) and not IS_SHOOTING:
		$AnimationPlayer.current_animation = "idle" + suffix
		
	# Jumping.
	if IS_JUMPING:
		$AnimationPlayer.current_animation = "jump" + suffix
	
	# Shooting.
	if IS_SHOOTING and (not IS_MOVING or IS_FALLING):
		$AnimationPlayer.current_animation = "shooting"
	
	# Change ShootFlash position according to player direction.
	$Sprite2D/ShootFlash.position.x = 15 * player_direction
	
	# Flip animation.
	if direction:
		$Sprite2D.flip_h = bool(direction - 1)
		$Sprite2D/ShootFlash.flip_h = bool(direction - 1)
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
				$ShootTimer.start()
				shoot.emit(player_direction)
		else:
			IS_SHOOTING = false


func checkFlashVisibility(IS_VISIBLE):
	if IS_SHOOTING:
		$Sprite2D/ShootFlash.visible = IS_VISIBLE
	else: 
		$Sprite2D/ShootFlash.visible = false


func _on_coyote_timer_timeout():
	CAN_COYOTE_TIMER = false


func _on_shoot_timer_timeout():
	CAN_SHOOT = true

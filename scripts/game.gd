extends Node2D
class_name Game

# Scenes.
var rifle: PackedScene = preload("res://scenes/weapon.tscn")
var bullet: PackedScene = preload("res://scenes/bullet.tscn")

# Variablesl.
var up_drop_force # -200 or -300
var max_drop_force = 200
var min_drop_force = 20
var drop_force = min_drop_force


func _process(delta):
	# switch between fullscreen and windowed.
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == 0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			
	# If the player is walking, the "up_drop_force" will be greater, 
	# preventing him from picking up the weapon immediately after dropping.
	if $Player.IS_MOVING:
		up_drop_force = -300
	else:
		up_drop_force = -200
	
	# Accumulates "drop_force" while pressing the drop action.
	if Input.is_action_pressed("drop_weapon") and Player.WITH_WEAPON:
		drop_force += 200 * delta
		
		# Limits the "drop_force".
		if drop_force > max_drop_force:
			drop_force = max_drop_force
			
	# Update ammo amount.
	$UI/Control/Label.text = "Ammo:" + str(Player.ammo)


func _on_player_dropped_gun(direction):
	var dropped_weapon = rifle.instantiate() as RigidBody2D
	
	dropped_weapon.position.x = $Player.position.x + 10 * direction
	dropped_weapon.position.y = $Player.position.y
	
	# Apply drop force on dropped weapon. 
	dropped_weapon.apply_impulse(Vector2(drop_force * direction, up_drop_force))
	
	# Update ammo amount of weapon.
	dropped_weapon.ammo = Player.ammo
	
	# Add dropped weapon on current scene.
	$Items.add_child(dropped_weapon) 
	Player.ammo = 0
	
	# Reset player TAKE_AMMO.
	$Player.TAKE_AMMO = false
	
	# Reset drop force to minimum.
	drop_force = min_drop_force
	
	# Play drop weapon sound.
	$Player/Audio/DropWeaponSound.play()


func _on_player_shoot(direction):
	var new_bullet = bullet.instantiate()
	
	# Defines the bullet direction according to the player direction.
	new_bullet.direction *= direction
	
	# Defines the origin of the shot according to the player's direction.
	if direction == -1:
		new_bullet.position = $Player/LeftShootPosition.global_position - Vector2(6,0)
	elif direction == 1:
		new_bullet.position = $Player/RightShootPosition.global_position + Vector2(6,0)
	
	# Flip the player according to the player's direction.
	new_bullet.get_node("Sprite2D").flip_h = bool(direction - 1)
	
	# Add bullet on game.
	$Projectiles.add_child(new_bullet)
	Player.ammo -= 1
	$Player/Audio/ShootSound.play()

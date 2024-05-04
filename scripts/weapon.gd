extends RigidBody2D

# Variables.
var ammo = 10
var current_body # Flag to control whether the player is within the area or not.

# References.
@onready var selfDestructTimer = $SelfDestructTimer
@onready var breakParticles = $BreakParticles
@onready var animationPlayer = $AnimationPlayer
@onready var area2D = $Area2D
@onready var sprite2D = $Sprite2D
@onready var breakSound = $BreakSoundEffect


func _ready():
	selfDestructTimer.wait_time = breakParticles.lifetime


func _process(_delta):
	# Player Take ammo of this weapon.
	if current_body:
		if current_body.TAKE_AMMO and Input.is_action_just_pressed("take_item"):
			Player.ammo += ammo
			current_body.get_node("Audio/GetAmmoSound").play()
			queue_free()
		elif not Player.WITH_WEAPON:
			getWeapon(current_body)


func getWeapon(body):
	Player.WITH_WEAPON = true
	Player.ammo += ammo # Adds weapon ammunition to "player ammunition".
	queue_free()
	body.get_node("Audio/GetWeaponSound").play() # Get weapon sound.


func selfDestruct():
	selfDestructTimer.start()
	animationPlayer.queue_free()
	area2D.queue_free()
	sprite2D.queue_free()
	set_process(false) # It is no longer necessary.
	breakParticles.emitting = true
	breakSound.play()


func _on_area_2d_body_entered(body):
	# Checks whether Player can pick up the weapon or its ammunition.
	if body.name == "Player":
		current_body = body 
		if not Player.WITH_WEAPON:
			getWeapon(body)
			
		elif Player.WITH_WEAPON:
			body.TAKE_AMMO = true
	else:
		if ammo == 0:
			selfDestruct()


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		current_body = null
		if Player.WITH_WEAPON:
			body.TAKE_AMMO = false
			# Disable the mensage "Take Ammo".
			body.get_node("Label").visible = false


func _on_self_destruct_timeout():
	queue_free() 

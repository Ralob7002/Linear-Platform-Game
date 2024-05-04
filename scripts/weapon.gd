extends RigidBody2D

# Variables.
var ammo = 10
var current_body


func _ready():
	$SelfDestruct.wait_time = $GPUParticles2D.lifetime


func _process(_delta):
	if $RayCast2D.get_collider():
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("idle")
	else:
		$AnimationPlayer.play("RESET")
		
		
	if ammo == 0:
		if $RayCast2D.get_collider():
			$SelfDestruct.start()
			$RayCast2D.queue_free()
			$AnimationPlayer.queue_free()
			$Area2D.queue_free()
			$Sprite2D.queue_free()
			set_process(false)
			$GPUParticles2D.emitting = true
			$BreakSoundEffect.play()
	
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
	Player.ammo += ammo
	queue_free()
	body.get_node("Audio/GetWeaponSound").play()


func _on_area_2d_body_entered(body):
	current_body = body
	if not Player.WITH_WEAPON:
		getWeapon(body)
		
	elif Player.WITH_WEAPON:
		body.TAKE_AMMO = true


func _on_area_2d_body_exited(body):
	current_body = null
	if Player.WITH_WEAPON:
		body.TAKE_AMMO = false
		body.get_node("Label").visible = false


func _on_self_destruct_timeout():
	queue_free()

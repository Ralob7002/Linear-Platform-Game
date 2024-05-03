extends Area2D


func _on_body_entered(body):
	# Checks whether the player has entered the death zone.
	if body.collision_layer == 1: # Player layer.
		var tween = create_tween()
		tween.tween_property(body, "modulate:a", 0, 0.3) # Fade effect.
		tween.tween_callback(func():
			$RestartTime.start())
	
	# Checks whether an item has entered the death zone.
	elif body.collision_layer == 4: # Item layer.
		body.queue_free()


func _on_timer_timeout():
	Player.reset() # Resets the player's global variables.
	get_tree().reload_current_scene() # Resets the current scene.

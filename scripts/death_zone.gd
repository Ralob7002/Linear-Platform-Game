extends Area2D


func _on_body_entered(body):
	if body.collision_layer == 1:
		var tween = create_tween()
		tween.tween_property(body, "modulate:a", 0, 0.3)
		tween.tween_callback(func():
			$Timer.start())
			
	elif body.collision_layer == 4: # Item.
		body.queue_free()
		print("Item deleted")


func _on_timer_timeout():
	Player.reset()
	get_tree().reload_current_scene()

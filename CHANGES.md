# Recent Changes!

1. Added a vertical speed limiter to the Player, preventing platforms with movement (move_platform) at high speed from applying a large amount of velocity to the Player when they leave it.

```gdscript
# Player.tsnc
func _physics_process(delta):
	# ...
	if velocity.y < max_jump_speed:
		velocity.y = max_jump_speed
```

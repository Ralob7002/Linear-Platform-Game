# Recent Changes!

## 1. Move platforms
Added a vertical speed limiter to the Player, preventing platforms with movement (move_platform) at high speed from applying a large amount of velocity to the Player when they leave it.

```gdscript
# Player.tsnc
func _physics_process(delta):
	# ...
	if velocity.y < max_jump_speed:
		velocity.y = max_jump_speed
```

## 2. Clean code
I removed useless parts ( I hope :| ), added more comments, and created variables that reference the nodes used in the code.

## 3. Organized folders
I organized the folders and files of the game, as they were quite messy and some had strange names.s
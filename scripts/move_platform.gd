extends AnimatableBody2D

# States.
var ON_SCREEN: bool = false
var ON_TARGET: bool = false
var ON_BEGIN: bool = true
var TO_TARGET: bool = false
var	TO_BEGIN: bool = false
var CARRYING_BODY: bool = false

# Export.
@export var targetPosition: Vector2 = Vector2.ZERO
@onready var beginPosition = $BeginPositionMarker.global_position
@export var showPositions: bool = false
@export var onWayCollision: bool = false

@export_subgroup("Start")
@export_enum("auto", "body_entered", "body_exited") var targetStart: String = "auto"
@export_enum("auto", "body_entered", "body_exited") var beginStart: String = "auto"

@export_subgroup("Loop")
@export var returnBegin: bool = false
@export var pingPong: bool = false

@export_subgroup("Time")
@export var toTargetTime: float = 2
@export var toBeginTime: float = 2

@export_subgroup("TweenTrans")
@export var targetTrans = Tween.TRANS_LINEAR
@export var beginTrans = Tween.TRANS_LINEAR

@export_subgroup("Sound")
@export var targetSound: bool = false
@export var beginSound: bool = false
@export var targetPitch: float = 1
@export var beginPitch: float = 1


func _ready():
	# Setup position markers.
	if showPositions or get_tree().debug_collisions_hint:
		$BeginPositionMarker.visible = true
		$TargetPositionMarker.visible = true
	
	$BeginPositionMarker.global_position = beginPosition
	$TargetPositionMarker.global_position = beginPosition + targetPosition
	$CollisionShape2D.one_way_collision = onWayCollision
	
	# Begin Movement.
	if targetStart == "auto":
		toTarget()
		moveSound(targetPitch, "target")


func _process(_delta):
	$BeginPositionMarker.global_position = beginPosition
	$TargetPositionMarker.global_position = beginPosition + targetPosition
	
	if beginStart == "body_exited" and ON_TARGET and not CARRYING_BODY and not TO_BEGIN and not TO_TARGET:
		toBegin()


func toTarget():
	TO_TARGET = true
	moveSound(targetPitch, "target")
	var tween = create_tween().set_trans(targetTrans)
	tween.tween_property($".", "position", beginPosition + targetPosition, toTargetTime)
	tween.tween_callback(func():
		TO_TARGET = false
		ON_TARGET = true
		ON_BEGIN = false
		if returnBegin or pingPong:
			if beginStart == "auto":
				toBegin())


func toBegin():
	TO_BEGIN = true
	moveSound(beginPitch, "begin")
	var tween = create_tween().set_trans(beginTrans)
	tween.tween_property($".", "position", beginPosition, toBeginTime)
	tween.tween_callback(func():
		TO_BEGIN = false
		ON_BEGIN = true
		ON_TARGET = false
		if pingPong:
			if targetStart == "auto":
				toTarget())


func moveSound(pitch, direction):
	var playTarget = (direction == "target" and targetSound)
	var playBegin = (direction == "begin" and beginSound)
	
	if ON_SCREEN:
		if playTarget or playBegin:
			$MoveSound.pitch_scale = pitch
			$MoveSound.play()


func _on_visible_on_screen_notifier_2d_screen_entered():
	ON_SCREEN = true


func _on_visible_on_screen_notifier_2d_screen_exited():
	ON_SCREEN = false


func _on_area_2d_body_entered(_body):
	CARRYING_BODY = true
	if not TO_TARGET and not TO_BEGIN:
		if ON_BEGIN and targetStart == "body_entered":
			toTarget()
		if ON_TARGET and beginStart == "body_entered":
			toBegin()


func _on_area_2d_body_exited(_body):
	CARRYING_BODY = false
	if not TO_TARGET and not TO_BEGIN:
		if ON_BEGIN and targetStart == "body_exited":
			toTarget()
		if ON_TARGET and beginStart == "body_exited":
			toBegin()

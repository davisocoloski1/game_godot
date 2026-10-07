extends Node2D


@onready var camera: Camera2D = $Player/Camera2D
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.zoom = Vector2(1, 1)
	camera.enabled = true
	camera.align()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	if camera.zoom == Vector2(4, 4):
		return

	camera.zoom.x += 0.2
	camera.zoom.y += 0.2

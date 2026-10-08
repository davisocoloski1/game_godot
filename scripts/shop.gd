extends Node2D


@onready var camera: Camera2D = $Player/Camera2D
@onready var timer: Timer = $Timer
@onready var boundaries: StaticBody2D = $Boundaries
@onready var chest_anim: AnimatedSprite2D = $Chest/AnimatedSprite2D
@onready var action_label: Label = $Player/CanvasLayer/ActionLabel
@onready var shop_menu: Control = $Player/CanvasLayer/ShopMenu


var _is_in_chest_area: bool = false
var _is_in_bonfire_area: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.zoom = Vector2(1, 1)
	camera.enabled = true
	camera.align()
	shop_menu.close.connect(_on_closed)


func _on_closed():
	shop_menu.visible = false


func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("interact"):
		if _is_in_chest_area:
			shop_menu.visible = true
			action_label.text = ""
		if _is_in_bonfire_area:
			Globals.next_round()
			get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_timer_timeout() -> void:
	if camera.zoom.x <= 4.0 and camera.zoom.y <= 4.0:
		camera.zoom.x += 0.01
		camera.zoom.y += 0.01


func _on_bonfire_interect_area_body_entered(body: Node2D) -> void:
	action_label.text = "Next round (E)"
	_is_in_bonfire_area = true	

func _on_chest_interect_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		action_label.text = "Open (E)"
		chest_anim.play("open")
		_is_in_chest_area = true


func _on_chest_interect_area_body_exited(body: Node2D) -> void:
	action_label.text = ""
	chest_anim.play("close")
	_is_in_chest_area = false
	shop_menu.visible = false


func _on_bonfire_interect_area_body_exited(body: Node2D) -> void:
	action_label.text = ""
	_is_in_bonfire_area = false

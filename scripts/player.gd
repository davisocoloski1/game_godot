extends CharacterBody2D

@export var data: PlayerData

const JUMP_VELOCITY = -400.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var attack_offset_x: float
var health: float
var speed: float
var damage: float
var state: PlayerData.State
var items: Array[ItemData]
signal health_changed(new_health: int)

func setup(p: PlayerData):
	health = p.health
	speed = p.speed
	state = p.state
	damage = p.damage
	items = p.items
	animated_sprite.sprite_frames = p.sprite_frames
	

func _ready() -> void:
	attack_offset_x = abs(attack_shape.position.x)
	setup(data)


func _get_health():
	return health


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):
		body.take_damage()


func attack():
	state = PlayerData.State.ATTACK
	attack_shape.set_deferred("disabled", false)


func _physics_process(_delta: float) -> void:
	if state == PlayerData.State.DEAD:
		return
	
	if Input.is_action_just_pressed("attack") and state != PlayerData.State.ATTACK:
		attack()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis("left", "right")
	var direction_y := Input.get_axis("up", "down")
	
	velocity.x = direction_x * speed if direction_x else move_toward(velocity.x, 0, speed)
	velocity.y = direction_y * speed if direction_y else move_toward(velocity.y, 0 ,speed)
	
	if direction_x < 0:
		animated_sprite.flip_h = true
		attack_shape.position.x = -attack_offset_x
	elif direction_x > 0:
		animated_sprite.flip_h = false
		attack_shape.position.x = attack_offset_x
	
	var moving := direction_x != 0 or direction_y != 0
	
	if state == PlayerData.State.ATTACK:
		var anim := "attack_walk" if moving else "attack"
		if animated_sprite.animation != anim:
			animated_sprite.play(anim)
			
	elif state == PlayerData.State.HURT:
		pass
			
	elif moving:
		state = PlayerData.State.WALK
		animated_sprite.play("walk")
	else:
		state = PlayerData.State.IDLE
		animated_sprite.play("idle")

	move_and_slide()
	
	
func take_damage(damage: float):
	if state == PlayerData.State.DEAD:
		return
	
	attack_shape.set_deferred("disabled", true)
	health -= damage
	health_changed.emit(health)
	if health <= 0:
		state = PlayerData.State.DEAD
		animated_sprite.play("dead")
	else:
		state = PlayerData.State.HURT
		animated_sprite.play("hit")


func _on_animated_sprite_2d_animation_finished() -> void:
	match state:
		PlayerData.State.ATTACK, PlayerData.State.HURT:
			state = PlayerData.State.IDLE
			attack_shape.set_deferred("disabled", true)
		PlayerData.State.DEAD:
			queue_free()
			get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
		
		
		
		
		

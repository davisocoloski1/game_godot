extends CharacterBody2D

enum State { IDLE, WALK, ATTACK, DEAD, HURT }

const SPEED = 120.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var attack_offset_x: float
var life: int = 10 : get = _get_life
var state := State.IDLE
signal health_changed(new_life: int)

func _ready() -> void:
	attack_offset_x = abs(attack_shape.position.x)


func _get_life():
	return life


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):
		body.take_damage()


func attack():
	state = State.ATTACK
	attack_shape.set_deferred("disabled", false)


func _physics_process(_delta: float) -> void:
	if state == State.DEAD:
		return
	
	if Input.is_action_just_pressed("attack") and state != State.ATTACK:
		attack()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis("left", "right")
	var direction_y := Input.get_axis("up", "down")
	
	velocity.x = direction_x * SPEED if direction_x else move_toward(velocity.x, 0, SPEED)
	velocity.y = direction_y * SPEED if direction_y else move_toward(velocity.y, 0 ,SPEED)
	
	if direction_x < 0:
		animated_sprite.flip_h = true
		attack_shape.position.x = -attack_offset_x
	elif direction_x > 0:
		animated_sprite.flip_h = false
		attack_shape.position.x = attack_offset_x
	
	var moving := direction_x != 0 or direction_y != 0
	
	if state == State.ATTACK:
		var anim := "attack_walk" if moving else "attack"
		if animated_sprite.animation != anim:
			animated_sprite.play(anim)
			
	elif state == State.HURT:
		pass
			
	elif moving:
		state = State.WALK
		animated_sprite.play("walk")
	else:
		state = State.IDLE
		animated_sprite.play("idle")

	move_and_slide()
	
	
func take_damage():
	if state == State.DEAD:
		return
	
	attack_shape.set_deferred("disabled", true)
	life -= 1
	health_changed.emit(life)
	if life <= 0:
		state = State.DEAD
		animated_sprite.play("dead")
	else:
		state = State.HURT
		animated_sprite.play("hit")


func _on_animated_sprite_2d_animation_finished() -> void:
	match state:
		State.ATTACK, State.HURT:
			state = State.IDLE
			attack_shape.set_deferred("disabled", true)
		State.DEAD:
			queue_free()
			get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
		
		
		
		
		

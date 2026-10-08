extends CharacterBody2D

enum State { CHASE, ATTACK, HURT, DEAD }

const SPEED := 60
const ATTACK_RANGE := 12.0

@onready var player: Node2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var health_bar: ProgressBar = $HealthBar

var life: int
var can_attack := false
var state := State.CHASE

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	attack_cooldown.start()

	life = 3
	health_bar.init_health(life)

func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	match state:
		State.CHASE:
			chase()
		State.ATTACK, State.HURT, State.DEAD:
			velocity = Vector2.ZERO
	move_and_slide()

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
	
func start_attack():
	attack_cooldown.start()
	state = State.ATTACK
	can_attack = false
	animated_sprite.play("attack")
	player.take_damage()

func chase():
	if not is_instance_valid(player):
		return
		
	var in_range := position.distance_to(player.position) <= ATTACK_RANGE
		
	if in_range:
		velocity = Vector2.ZERO
		if can_attack:
			start_attack()
		else:
			animated_sprite.play("idle")
		return
		
	var direction = (player.position - position).normalized()
	if direction:
		animated_sprite.play("walk")
	if not direction:
		animated_sprite.play("idle")
		
	if direction.x < 0:
		animated_sprite.flip_h = true
	elif direction.x > 0:
		animated_sprite.flip_h = false
		
	velocity = direction * SPEED
	

func take_damage():
	if state == State.DEAD:
		return
		
	life -= 1
	if life <= 0:
		state = State.DEAD
		animated_sprite.play("dead")
		Globals.player_coins += 1
	else:
		state = State.HURT
		animated_sprite.play("hart")
		attack_cooldown.start()

	health_bar.health = life


func _on_animated_sprite_2d_animation_finished() -> void:
	match state:
		State.ATTACK, State.HURT:
			state = State.CHASE
		State.DEAD:
			queue_free()
			Globals.enemies_alive -= 1

extends CharacterBody2D


var monster: MonsterData

@onready var player: Node2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var health_bar: ProgressBar = $HealthBar

var health: float
var damage: float
var can_attack: bool = true
var state: MonsterData.State
var attack_range: float
var speed: float
var initial_wave: int
var spawn_weight: int

func setup(data: MonsterData):
	monster = data
	animated_sprite.sprite_frames = monster.sprite_frames
	health = monster.health
	damage = monster.damage
	state = monster.state
	attack_range = monster.attack_range
	attack_cooldown.wait_time = monster.attack_cooldown
	speed = monster.speed
	initial_wave = monster.initial_wave
	spawn_weight = monster.spawn_weight
	
	health_bar.init_health(health)

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	attack_cooldown.start()
	

func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	match state:
		MonsterData.State.CHASE:
			chase()
		MonsterData.State.ATTACK, MonsterData.State.HURT, MonsterData.State.DEAD:
			velocity = Vector2.ZERO
	move_and_slide()

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
	
func start_attack():
	attack_cooldown.start()
	state = MonsterData.State.ATTACK
	can_attack = false
	animated_sprite.play("attack")
	player.take_damage(damage)

func chase():
	if not is_instance_valid(player):
		return
		
	var in_range := position.distance_to(player.position) <= attack_range 
		
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
		
	velocity = direction * speed
	

func take_damage():
	if state == MonsterData.State.DEAD:
		return
		
	health -= 1
	if health <= 0:
		state = MonsterData.State.DEAD
		animated_sprite.play("dead")
		Globals.player_coins += 1
	else:
		state = MonsterData.State.HURT
		animated_sprite.play("hurt")
		attack_cooldown.start()

	health_bar.health = health


func _on_animated_sprite_2d_animation_finished() -> void:
	match state:
		MonsterData.State.ATTACK, MonsterData.State.HURT:
			state = MonsterData.State.CHASE
		MonsterData.State.DEAD:
			queue_free()
			Globals.enemies_alive -= 1

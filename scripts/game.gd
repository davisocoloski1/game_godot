extends Node2D

@export var all_monsters: Array[MonsterData]

var mob_scene = preload("res://scenes/slime.tscn")
@onready var top_limit: CollisionShape2D = $MapBoundaries/TopLimit
@onready var bottom_limit: CollisionShape2D = $MapBoundaries/BottomLimit
@onready var left_limit: CollisionShape2D = $MapBoundaries/LeftLimit
@onready var right_limit: CollisionShape2D = $MapBoundaries/RightLimit
@onready var mob_spawn_cooldown: Timer = $MobSpawnCooldown
@onready var enemies_label: Label = $Player/HUD/EnemiesLabel
@onready var health_bar: ProgressBar = $Player/HUD/HealthBar
@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.init_health(player.health)
	player.health_changed.connect(_on_player_health_changed)

func _process(_delta: float) -> void:
	enemies_label.text = "Enemies: " + str(Globals.enemies_alive) + "\nTotal enemies: " + str(Globals.enemies_per_round) + "\nRound: " + str(Globals.current_round)


func random_monster() -> MonsterData:
	var available_monsters = all_monsters.filter(func(m): return m.initial_wave <= Globals.current_round)
	var total = 0
	for m in available_monsters:
		total += m.spawn_weight

	var draw = randi_range(1, total)
	for m in available_monsters:
		draw -= m.spawn_weight
		if draw <= 0:
			return m

	return available_monsters[0]

func _on_mob_spawn_cooldown_timeout() -> void:
	if Globals.enemies_this_round > 0:
		var rh = randi_range(int(top_limit.position.y), int(bottom_limit.position.y))
		var wh = randi_range(int(left_limit.position.x), int(right_limit.position.x))
		
		if mob_spawn_cooldown.timeout:
			var mob = mob_scene.instantiate()
			mob.position = Vector2(wh, rh)
			add_child(mob)
			mob.setup(random_monster())
			Globals.enemies_this_round -= 1
			Globals.enemies_alive += 1
			mob_spawn_cooldown.wait_time = 2
		
	Globals.finish_round()


func _on_player_health_changed(new_life: int):
	health_bar.health = new_life

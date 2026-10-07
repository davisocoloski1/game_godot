extends Node2D

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
	health_bar.init_health(player.life)
	player.health_changed.connect(_on_player_health_changed)

func _process(_delta: float) -> void:
	enemies_label.text = "Enemies: " + str(Globals.enemies_alive) + "\nTotal enemies: " + str(Globals.enemies_per_round) + "\nRound: " + str(Globals.current_round)

func _on_mob_spawn_cooldown_timeout() -> void:
	if Globals.enemies_this_round > 0:
		var rh = randi_range(int(top_limit.position.y), int(bottom_limit.position.y))
		var wh = randi_range(int(left_limit.position.x), int(right_limit.position.x))
		
		if mob_spawn_cooldown.timeout:
			var mob = mob_scene.instantiate()
			mob.position = Vector2(wh, rh)
			add_child(mob)
			Globals.enemies_this_round -= 1
			Globals.enemies_alive += 1
			mob_spawn_cooldown.wait_time = 2
		
	Globals.update_round()


func _on_player_health_changed(new_life: int):
	health_bar.health = new_life

class_name MonsterData
extends Resource

enum State { CHASE, ATTACK, HURT, DEAD }

@export var name: String
@export var health: float
@export var damage: float
@export var speed: float
@export var attack_range: float
@export var attack_cooldown: float
@export var state: State
@export var initial_wave: int
@export var spawn_weight: int
@export var sprite_frames: SpriteFrames

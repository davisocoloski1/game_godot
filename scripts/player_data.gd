class_name PlayerData
extends Resource

enum State { IDLE, WALK, ATTACK, DEAD, HURT }

@export var name: String
@export var health: float
@export var damage: float
@export var state: State
@export var speed: float
@export var items: Array[ItemData]
@export var sprite_frames: SpriteFrames

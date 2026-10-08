extends Control


signal close

@export var items: Array[ItemData]
@export var slot_scene: PackedScene

@onready var grid: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var coins_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CoinsLabel

func _ready() -> void:
	for item in items:
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		slot.setup(item)
		slot.buy.connect(_on_buy)
		coins_label.text = str(Globals.player_coins)


func _on_buy(item: ItemData):
	print("Item " + item.name + " purchased.")


func _on_button_pressed() -> void:
	close.emit()

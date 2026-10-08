extends Button

signal buy(item: ItemData)

var item: ItemData

func setup(data: ItemData):
	item = data
	$MarginContainer/VBoxContainer/TextureRect.texture = data.sprite_frames.get_frame_texture("idle", 0)
	$MarginContainer/VBoxContainer/Label.text = data.name
	$MarginContainer/VBoxContainer/Label2.text = str(data.price)

func _ready():
	pressed.connect(func(): buy.emit(item))

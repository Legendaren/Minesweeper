extends RichTextLabel
class_name WinText


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.game_win.connect(_on_game_win)
	visible = false


func _on_game_win():
	visible = true

extends RichTextLabel
class_name WinText


func _ready() -> void:
	EventBus.game_win.connect(_on_game_win)
	visible = false


func _on_game_win():
	visible = true

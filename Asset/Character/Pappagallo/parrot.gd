extends Node3D

@onready var dialog_ui = $"../HUD/DialogueUI"
func _ready() -> void:
	dialog_ui.dialog_ended.connect(_on_dialog_ended)


func _on_dialog_ended():
	print("Dialogo terminato")


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		dialog_ui.start_dialog("res://dialoghi/parrot.json", "start")

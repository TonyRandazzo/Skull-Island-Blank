extends CanvasLayer

@export var target: NodePath
@onready var player: Node3D = get_node(target)
@onready var minimap_camera: Node3D = $MinimapContainer/MinimapViewport/MinimapCamera
@onready var player_indicator = $MinimapContainer/MinimapViewport/PlayerIndicator
@onready var bussola = $MinimapContainer/MinimapViewport/Bussola



func _process(delta: float) -> void:
	minimap_camera.position = Vector3(player.position.x, 30, player.position.z)

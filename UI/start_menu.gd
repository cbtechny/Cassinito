extends Control

@onready var play_btn : Button = $margins/button_container/play_button
@onready var how_to_play_btn : Button = $margins/button_container/how_to_play_button
@onready var am : AnimationPlayer = $AnimationPlayer
@onready var bg_cont : Control = $bg_container

func _ready() -> void:
	am.play( "intro_drop" )
	await am.animation_finished

func _on_play_button_pressed() -> void:
	await get_tree().create_timer( 0.2 ).timeout
	SceneManager.go_to_scene_id( 3 )

func _on_how_to_play_button_pressed() -> void:
	SceneManager.go_to_scene_id( 1 )

extends Node3D
@onready var player: CharacterBody3D = $Player
@onready var time_label: Label = $HUD/Label
@onready var tracer: MeshInstance3D = $Tracer
@onready var beam: MeshInstance3D = $Beam

var targets: Array = []
var current: Area3D
var time := 0.0
var best := INF
var running := false
@export var tracer_thickness := 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	tracer.top_level = true
	tracer.global_transform = Transform3D.IDENTITY
	tracer.mesh = BoxMesh.new()
	targets = get_tree().get_nodes_in_group("targets")
	for t in targets:
		t.body_entered.connect(_on_target_entered.bind(t))
	start_round()


func start_round() -> void:
	var pool := targets.filter(func(t): return t != current)
	current = pool.pick_random()
	beam.global_position = current.global_position
	time = 0.0
	running = true
	tracer.visible = true
	beam.visible = true

func _on_target_entered(body: Node3D, area: Area3D) -> void:
	if not running or body != player or area != current:
		return
	running = false
	tracer.visible = false
	beam.visible = false
	best = min(best, time)
	time_label.text = "You Did It in %.2f s (Best time overall: %.2f s)" % [time, best]
	await get_tree().create_timer(3.0).timeout
	start_round()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var from := player.global_position + Vector3(0, 1, 0)
	var to := current.global_position
	var length := from.distance_to(to)
	if not running:
		return
	time += delta
	time_label.text = "%.2f s" % time
	if length > 0.1:
		tracer.global_position = (from + to) / 2.0
		tracer.look_at(to, Vector3.UP)
		tracer.scale = Vector3(tracer_thickness, tracer_thickness, length)




func _on_button_button_down() -> void:
	get_tree().change_scene_to_file("res://homescreen.tscn")

extends Control

@onready var _scoreText:Label = $score_text
@onready var _bar:ProgressBar = $ProgressBar
@onready var _goldMarker:Control = $ProgressBar/gold_marker
@onready var _silverMarker:Control = $ProgressBar/silver_marker
@onready var _bronzeMarker:Control = $ProgressBar/bronze_marker

@onready var _bronzeFireworks:GPUParticles2D = $ProgressBar/bronze_marker/GPUParticles2D
@onready var _silverFireworks:GPUParticles2D = $ProgressBar/silver_marker/GPUParticles2D
@onready var _goldFireworks:GPUParticles2D = $ProgressBar/gold_marker/GPUParticles2D

@onready var _markerStart:Control = $ProgressBar/bar_start
@onready var _markerEnd:Control = $ProgressBar/bar_end

var _goldTarget:int = 100000
var _silverTarget:int = 75000
var _bronzeTarget:int = 50000

var _goldFireworksRun:bool = false
var _silverFireworksRun:bool = false
var _bronzeFireworksRun:bool = false

var _score:int = 125000
var _tallyTarget:float = 0
var _tally:float = 0
var _tallyPointsPerSecond:float = 0
var _tallying:bool = false
var _tallyTime:float = 1.5

func _ready() -> void:
	_goldMarker.visible = false
	_silverMarker.visible = false
	_bronzeMarker.visible = false
	_test_run()

func run(newScore:int) -> void:
	_score = newScore
	_scoreText.text = str(_score)
	
	_bronzeFireworksRun = false
	_bronzeFireworks.emitting = false
	
	_silverFireworksRun = false
	_silverFireworks.emitting = false
	
	_goldFireworksRun = false
	_goldFireworks.emitting = false
	
	_tallying = true
	_tally = 0.0
	_tallyTarget = _score
	if _tallyTarget < _goldTarget:
		_tallyTarget = _goldTarget
	print("Tally target " + str(_tallyTarget))
	_tallyPointsPerSecond = _tallyTarget / _tallyTime
	
	_goldMarker.visible = true
	_silverMarker.visible = true
	_bronzeMarker.visible = true
	var a:Vector2 = _markerStart.position
	var b:Vector2 = _markerEnd.position
	var p:Vector2
	
	p = Vector2(lerpf(a.x, b.x, _bronzeTarget / _tallyTarget), a.y)
	_bronzeMarker.position = p
	
	p = Vector2(lerpf(a.x, b.x, _silverTarget / _tallyTarget), a.y)
	_silverMarker.position = p
	
	p = Vector2(lerpf(a.x, b.x, _goldTarget / _tallyTarget), a.y)
	_goldMarker.position = p

func _test_run() -> void:
	var newScore:int = ceil(randf_range(25000, _goldTarget * 1.5))
	run(newScore)

func _physics_process(_delta:float) -> void:
	if !_tallying:
		if Input.is_action_just_pressed("ui_select"):
			_test_run()
		return
	_tally += _tallyPointsPerSecond * _delta
	print(str(_tally))
	if _tally > _bronzeTarget && !_bronzeFireworksRun:
		_bronzeFireworksRun = true
		_bronzeFireworks.restart()
		_bronzeFireworks.one_shot = true
		_bronzeFireworks.emitting = true
	if _tally > _silverTarget && !_silverFireworksRun:
		_silverFireworksRun = true
		_silverFireworks.restart()
		_silverFireworks.one_shot = true
		_silverFireworks.emitting = true
	if _tally > _goldTarget && !_goldFireworksRun:
		_goldFireworksRun = true
		_goldFireworks.restart()
		_goldFireworks.one_shot = true
		_goldFireworks.emitting = true
	if _tally > _score:
		_tally = _score
		_tallying = false
	var percent:float = (_tally / _tallyTarget) * 100.0
	_bar.value = percent

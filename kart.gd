extends CharacterBody3D

@export var acceleration := 18.0
@export var reverse_speed := 7.0
@export var max_speed := 24.0
@export var steering_speed := 2.0
@export var drag := 9.0

var current_speed := 0.0

func _ready() -> void:
    _add_default_actions()

func _physics_process(delta: float) -> void:
    var throttle := Input.get_action_strength("accelerate")
    var brake := Input.get_action_strength("brake")
    var left := Input.get_action_strength("steer_left")
    var right := Input.get_action_strength("steer_right")
    throttle += Input.get_action_strength("ui_up")
    brake += Input.get_action_strength("ui_down")
    left += Input.get_action_strength("ui_left")
    right += Input.get_action_strength("ui_right")
    throttle = minf(throttle, 1.0)
    brake = minf(brake, 1.0)

    if throttle > 0.0:
        current_speed = move_toward(current_speed, max_speed, acceleration * throttle * delta)
    elif brake > 0.0:
        if current_speed > 1.0:
            current_speed = move_toward(current_speed, 0.0, acceleration * 1.5 * brake * delta)
        else:
            current_speed = move_toward(current_speed, -reverse_speed, acceleration * 0.55 * brake * delta)
    else:
        current_speed = move_toward(current_speed, 0.0, drag * delta)

    var steering := right - left
    if absf(current_speed) > 0.3:
        rotation.y -= steering * steering_speed * delta * clampf(absf(current_speed) / 8.0, 0.25, 1.0) * signf(current_speed)

    var forward := -global_transform.basis.z
    velocity.x = forward.x * current_speed
    velocity.z = forward.z * current_speed
    velocity.y -= 24.0 * delta
    move_and_slide()

func _add_default_actions() -> void:
    _ensure_action("accelerate", KEY_W)
    _ensure_action("brake", KEY_S)
    _ensure_action("steer_left", KEY_A)
    _ensure_action("steer_right", KEY_D)

func _ensure_action(action_name: String, keycode: Key) -> void:
    if not InputMap.has_action(action_name):
        InputMap.add_action(action_name)
    var event := InputEventKey.new()
    event.physical_keycode = keycode
    InputMap.action_add_event(action_name, event)

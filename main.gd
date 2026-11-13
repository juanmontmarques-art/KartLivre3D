extends Node3D

var kart: CharacterBody3D
var camera: Camera3D
var speed_label: Label
var timer_label: Label
var elapsed := 0.0
var started := false

func _ready() -> void:
    _make_world()
    _make_track()
    _make_kart()
    _make_camera()
    _make_ui()

func _process(delta: float) -> void:
    if started:
        elapsed += delta
    if is_instance_valid(kart):
        speed_label.text = "VELOCIDADE  %d" % int(kart.current_speed * 3.6)
    timer_label.text = "TEMPO  %05.1f" % elapsed

func _make_world() -> void:
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_SKY
    environment.sky = Sky.new()
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.75, 0.82, 0.92)
    environment.ambient_light_energy = 0.8
    env.environment = environment
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    sun.light_energy = 1.2
    add_child(sun)

func _mat(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    return m

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, name: String = "Prop") -> MeshInstance3D:
    var mesh_node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_node.mesh = mesh
    mesh_node.position = pos
    mesh_node.material_override = _mat(color)
    mesh_node.name = name
    parent.add_child(mesh_node)
    return mesh_node

func _make_track() -> void:
    _box(self, Vector3(100, 0.2, 100), Vector3(0, -0.25, 0), Color(0.22, 0.62, 0.25), "Grass")
    # Physical ground so the kart does not fall through the visual floor.
    var ground_body := StaticBody3D.new()
    ground_body.name = "GroundCollision"
    ground_body.position = Vector3(0, -0.25, 0)
    var ground_collision := CollisionShape3D.new()
    var ground_shape := BoxShape3D.new()
    ground_shape.size = Vector3(100, 0.2, 100)
    ground_collision.shape = ground_shape
    ground_body.add_child(ground_collision)
    add_child(ground_body)

    # Large, simple asphalt practice area for the first prototype.
    _box(self, Vector3(48, 0.15, 48), Vector3(0, -0.08, 0), Color(0.20, 0.21, 0.24), "Asphalt")
    # Colorful curb strips around the practice area.
    _box(self, Vector3(48, 0.22, 1.0), Vector3(0, 0.02, -24), Color(0.95, 0.25, 0.20), "NorthCurb")
    _box(self, Vector3(48, 0.22, 1.0), Vector3(0, 0.02, 24), Color(0.95, 0.91, 0.82), "SouthCurb")
    _box(self, Vector3(1.0, 0.22, 48), Vector3(-24, 0.02, 0), Color(0.95, 0.91, 0.82), "WestCurb")
    _box(self, Vector3(1.0, 0.22, 48), Vector3(24, 0.02, 0), Color(0.95, 0.25, 0.20), "EastCurb")

    # Track markings
    for i in range(8):
        _box(self, Vector3(0.35, 0.025, 2.0), Vector3(-18 + i * 5.1, 0.015, 0), Color(0.95, 0.93, 0.78), "Marking")

    # Simple trees around the outside.
    for p in [Vector3(-31, 0, -30), Vector3(-15, 0, -32), Vector3(7, 0, -31), Vector3(31, 0, -25), Vector3(31, 0, 18), Vector3(14, 0, 31), Vector3(-27, 0, 28), Vector3(-33, 0, 5)]:
        _box(self, Vector3(0.8, 2.3, 0.8), p + Vector3(0, 1.15, 0), Color(0.43, 0.25, 0.12), "TreeTrunk")
        var crown := MeshInstance3D.new()
        var sphere := SphereMesh.new()
        sphere.radius = 1.7
        sphere.height = 3.4
        crown.mesh = sphere
        crown.position = p + Vector3(0, 3.0, 0)
        crown.material_override = _mat(Color(0.12, 0.48, 0.22))
        add_child(crown)

func _make_kart() -> void:
    kart = CharacterBody3D.new()
    kart.name = "Kart"
    kart.position = Vector3(0, 0.55, 12)
    kart.set_script(load("res://kart.gd"))
    add_child(kart)

    # Body and cockpit are children of the controllable kart.
    _box(kart, Vector3(1.65, 0.45, 2.4), Vector3(0, 0.1, 0), Color(0.98, 0.24, 0.12), "KartBody")
    _box(kart, Vector3(1.0, 0.55, 0.8), Vector3(0, 0.48, -0.15), Color(0.12, 0.72, 0.92), "Cockpit")
    _box(kart, Vector3(1.9, 0.12, 0.28), Vector3(0, 0.25, -1.0), Color(1.0, 0.78, 0.12), "FrontBumper")
    for x in [-0.92, 0.92]:
        for z in [-0.72, 0.72]:
            var wheel := MeshInstance3D.new()
            var cylinder := CylinderMesh.new()
            cylinder.top_radius = 0.28
            cylinder.bottom_radius = 0.28
            cylinder.height = 0.2
            wheel.mesh = cylinder
            wheel.position = Vector3(x, -0.12, z)
            wheel.rotation_degrees.z = 90
            wheel.material_override = _mat(Color(0.07, 0.07, 0.08))
            kart.add_child(wheel)

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.7, 0.9, 2.4)
    collision.shape = shape
    collision.position = Vector3(0, 0.1, 0)
    kart.add_child(collision)

func _make_camera() -> void:
    camera = Camera3D.new()
    camera.name = "FollowCamera"
    camera.position = Vector3(0, 5, 8)
    camera.rotation_degrees = Vector3(-18, 0, 0)
    camera.current = true
    add_child(camera)

func _make_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(18, 18)
    panel.custom_minimum_size = Vector2(260, 86)
    layer.add_child(panel)
    var vbox := VBoxContainer.new()
    panel.add_child(vbox)
    speed_label = Label.new()
    speed_label.text = "VELOCIDADE  0"
    speed_label.add_theme_font_size_override("font_size", 22)
    vbox.add_child(speed_label)
    timer_label = Label.new()
    timer_label.text = "TEMPO  000.0"
    timer_label.add_theme_font_size_override("font_size", 20)
    vbox.add_child(timer_label)

    var help := Label.new()
    help.text = "WASD / setas para dirigir  •  Toque: botões abaixo"
    help.position = Vector2(18, 112)
    help.add_theme_font_size_override("font_size", 16)
    layer.add_child(help)

    _make_touch_button(layer, "◀", Vector2(28, -115), Vector2(84, 76), "steer_left")
    _make_touch_button(layer, "▶", Vector2(122, -115), Vector2(84, 76), "steer_right")
    _make_touch_button(layer, "ACELERAR", Vector2(-190, -150), Vector2(160, 92), "accelerate", true)
    _make_touch_button(layer, "FREAR", Vector2(-190, -48), Vector2(160, 72), "brake", true)

func _make_touch_button(layer: CanvasLayer, caption: String, offset: Vector2, size: Vector2, action: String, right_side: bool = false) -> void:
    var button := TouchScreenButton.new()
    var shape := RectangleShape2D.new()
    shape.size = size
    button.shape = shape
    button.action = action
    # Use viewport-relative anchors for bottom-corner placement.
    var rect := Node2D.new()
    rect.position = Vector2(0, 0)
    layer.add_child(rect)
    button.position = offset
    if right_side:
        button.position = Vector2(get_viewport().get_visible_rect().size.x + offset.x, get_viewport().get_visible_rect().size.y + offset.y)
    else:
        button.position = Vector2(offset.x, get_viewport().get_visible_rect().size.y + offset.y)
    layer.add_child(button)
    # TouchScreenButton has no text; add a matching label for the visual caption.
    var label := Label.new()
    label.text = caption
    label.position = button.position - size / 2.0
    label.size = size
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 22 if caption.length() < 4 else 16)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(label)

func _physics_process(_delta: float) -> void:
    if is_instance_valid(kart) and is_instance_valid(camera):
        var target := kart.global_position + Vector3(0, 4.8, 8.0).rotated(Vector3.UP, kart.rotation.y)
        camera.global_position = camera.global_position.lerp(target, 0.08)
        camera.look_at(kart.global_position + Vector3(0, 0.4, 0), Vector3.UP)

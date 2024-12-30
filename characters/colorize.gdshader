shader_type canvas_item;


uniform vec4 color: source_color;

void fragment() {
	if (COLOR.a > 0.0) {
		COLOR = color;
	}
}
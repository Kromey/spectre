shader_type spatial;

uniform vec4 BASE_COLOR : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float LINE_WIDTH = 0.02;
uniform vec4 LINE_COLOR : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float COLUMN_COUNT = 5.0;
uniform float ROW_COUNT = 5.0;

bool grid_line(vec2 uv) {
	return abs(fract(uv.x * COLUMN_COUNT)) <= LINE_WIDTH || abs(fract(uv.y * ROW_COUNT)) <= LINE_WIDTH;
}

void fragment() {
	if (grid_line(UV)) {
		ALBEDO = LINE_COLOR.rgb;
	} else {
		ALBEDO = BASE_COLOR.rgb;
	}
}

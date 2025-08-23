shader_type canvas_item;

uniform sampler2D gradient: source_color;

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	vec4 grad_color = texture(gradient,vec2(fract(UV.x+UV.y + TIME/2.0), UV.y));

	COLOR = grad_color.rgba * pixel.a * COLOR;
}

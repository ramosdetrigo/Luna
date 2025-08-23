shader_type canvas_item;

uniform sampler2D gradient: source_color;

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	vec4 grad_color = texture(gradient,vec2(fract(UV.x + TIME/1.5), UV.y));

	COLOR = vec4(grad_color.rgb, pixel.a);
}

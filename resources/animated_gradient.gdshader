shader_type canvas_item;

uniform sampler2D gradient: source_color;

uniform float angle : hint_range(-1.0, 1.0, 0.01) = 1.0;
uniform float speed : hint_range(0.0, 5.0, 0.1) = 0.66666;

void fragment() {
    vec4 pixel = texture(TEXTURE, UV);
    vec2 direction = vec2(cos(angle * PI), sin(angle * PI));
    float t = fract(dot(UV, direction) + TIME * speed);
    vec4 grad_color = texture(gradient, vec2(t, 0.5));
    COLOR = vec4(grad_color.rgb, pixel.a);
}

shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_nearest;

uniform sampler2D noise_tex1: repeat_enable;
uniform sampler2D noise_tex2: repeat_enable;

uniform vec2 offset1 = vec2(0.1);
uniform vec2 offset2 = vec2(0.2);

uniform float distortion_strength: hint_range(-1.0, 1.0) = 0.1;

void fragment()
{
	vec4 noise_color1 = texture(noise_tex1, UV + offset1*TIME);
	vec4 noise_color2 = texture(noise_tex2, UV + offset2*TIME);

	float final_noise = noise_color1.r * noise_color2.r;

	vec2 new_coords = SCREEN_UV;
	//new_coords.y = new_coords.y - 10.0;

	vec4 final_color = texture(screen_texture, new_coords + final_noise*distortion_strength);

	COLOR = final_color;
}

void vertex()
{
	VERTEX.y += 100.0;
	//if(VERTEX.y < 0.0 && VERTEX.x < 0.0)
	//{
		//float speed = my_float;
		//vec2 circle = vec2(cos(TIME*speed)*100.0, sin(TIME*speed)*100.0);
		//VERTEX += vec2(-200.0, -50.0) + circle;
	//}
	//VERTEX += vec2(cos(TIME)*100.0, 0.0);
	//VERTEX += vec2(cos(TIME)*100.0, sin(TIME)*100.0);
}

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform float blur_amount : hint_range(0.0, 5.0) = 1.5;

void fragment() {
	
	float w[9];
	//Pre-computed Gaussian 9 weights (sigma 5), renormalized to sum to 1
	w[0] = 0.080497596;
	w[1] = 0.078903637;
	w[2] = 0.074308647;
	w[3] = 0.067237244;
	w[4] = 0.058453252;
	w[5] = 0.048824260;
	w[6] = 0.039182387;
	w[7] = 0.030211641;
	w[8] = 0.022381334;
	
	//vec3 result = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount).rgb;
	vec4 tex_sum = texture(SCREEN_TEXTURE, SCREEN_UV) * w[0];
	float weight_sum = w[0];
	vec2 texel = SCREEN_PIXEL_SIZE * max(1.0, blur_amount*0.025);
	int range = min(40,int(floor(blur_amount*5.0)));
	for (int x = 1; x <= 8; x++) {
		tex_sum += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(float(x),0.0) * texel) * w[x];
		tex_sum += texture(SCREEN_TEXTURE, SCREEN_UV - vec2(float(x),0.0) * texel) * w[x];
		weight_sum += w[x] * 2.0;
	}
	COLOR.rgb = (tex_sum/weight_sum).rgb;
}
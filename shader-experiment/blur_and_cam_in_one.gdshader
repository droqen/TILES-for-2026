shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform float blur_amount : hint_range(0.0, 5.0) = 1.5;
uniform float zoom : hint_range(0.5, 100.0) = 4.0;
uniform vec2 dreamsize = vec2(100.0, 100.0);

vec3 blend(vec3[4] colours, float xw, float yw) {
	return mix(
		mix(colours[0], colours[1], xw),
		mix(colours[2], colours[3], xw),
		yw
	);
}

vec3 valueInsideRect(vec2 p, vec4 rect, vec3 insideColor)
{
    float inX = step(rect.x, p.x) * step(p.x, rect.z);
    float inY = step(rect.y, p.y) * step(p.y, rect.w);
    float inside = inX * inY;   // 1.0 if inside, 0.0 if outside
	
	return inside * insideColor; // black (0,0,0) outside
    return mix(vec3(1.0,1.0,1.0), insideColor, inside); // custom outside: white (1,1,1)
}

const vec2 OFFSET_RIGHT = vec2(1.0, 0.0);
const vec2 OFFSET_DOWN = vec2(0.0, 1.0);

void fragment() {
	//COLOR.rgb = vec3(SCREEN_UV.x, SCREEN_UV.y, 0.0);
	//vec4 dreamrect = vec4(0.0, 0.0, dreamsize);
	vec2 dreamsize_uv = dreamsize * SCREEN_PIXEL_SIZE;
	vec2 top_left_corner_of_dream = (vec2(1.,1.) - dreamsize_uv * zoom)*0.5;
	vec2 screen_x1_uv = (SCREEN_UV - top_left_corner_of_dream) / zoom;
	vec2 screen_x1 = screen_x1_uv / SCREEN_PIXEL_SIZE;
	vec2 screen_x1_int = vec2(floor(screen_x1.x-0.5)+0.5, floor(screen_x1.y-0.5)+0.5); // rounded
	vec2 screen_x1_int_uv = screen_x1_int * SCREEN_PIXEL_SIZE;
	vec2 or_uv = OFFSET_RIGHT * SCREEN_PIXEL_SIZE;
	vec2 od_uv = OFFSET_DOWN * SCREEN_PIXEL_SIZE;
	
	vec3[4] colours = {
		texture(SCREEN_TEXTURE, screen_x1_int_uv).rgb ,
		texture(SCREEN_TEXTURE, screen_x1_int_uv + or_uv).rgb ,
		texture(SCREEN_TEXTURE, screen_x1_int_uv + od_uv).rgb ,
		texture(SCREEN_TEXTURE, screen_x1_int_uv + or_uv + od_uv).rgb   };
	
	COLOR.rgb = valueInsideRect(
		screen_x1_uv,
		vec4(0.0, 0.0, dreamsize_uv),
		blend(colours,
			smoothstep(0.0, SCREEN_PIXEL_SIZE.x, screen_x1_uv.x - screen_x1_int_uv.x),
			smoothstep(0.0, SCREEN_PIXEL_SIZE.y, screen_x1_uv.y - screen_x1_int_uv.y)
		)
		//texture(SCREEN_TEXTURE, screen_x1_int * SCREEN_PIXEL_SIZE).rgb
	);
	
	
	//float w[9];
	////Pre-computed Gaussian 9 weights (sigma 5), renormalized to sum to 1
	//w[0] = 0.080497596;
	//w[1] = 0.078903637;
	//w[2] = 0.074308647;
	//w[3] = 0.067237244;
	//w[4] = 0.058453252;
	//w[5] = 0.048824260;
	//w[6] = 0.039182387;
	//w[7] = 0.030211641;
	//w[8] = 0.022381334;
	//
	////vec3 result = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount).rgb;
	//vec4 tex_sum = texture(SCREEN_TEXTURE, SCREEN_UV) * w[0];
	//float weight_sum = w[0];
	//vec2 texel = SCREEN_PIXEL_SIZE;
	//for (int x = 1; x <= 8; x++) {
		//tex_sum += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(float(x),0.0) * texel) * w[x];
		//tex_sum += texture(SCREEN_TEXTURE, SCREEN_UV - vec2(float(x),0.0) * texel) * w[x];
		//weight_sum += w[x] * 2.0;
	//}
	//COLOR.rgb = (tex_sum/weight_sum).rgb;
}
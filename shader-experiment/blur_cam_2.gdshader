shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform float blur_amount : hint_range(0.01, 3.0) = 0.2;
uniform float zoom : hint_range(0.5, 100.0) = 4.0;
uniform vec2 dreamsize = vec2(100.0, 100.0);

vec3 valueInsideRect(vec2 p, vec4 rect, vec3 insideColor)
{
    float inX = step(rect.x, p.x) * step(p.x, rect.z);
    float inY = step(rect.y, p.y) * step(p.y, rect.w);
    float inside = inX * inY;   // 1.0 if inside, 0.0 if outside
	
	return inside * insideColor; // black (0,0,0) outside
    return mix(vec3(1.0,1.0,1.0), insideColor, inside); // custom outside: white (1,1,1)
}

vec3 blend4(vec3[4] colours, float xw, float yw) {
	return mix(
		mix(colours[0], colours[1], xw),
		mix(colours[2], colours[3], xw),
		yw
	);
}
int get_idx(int x, int y) { return y*10 + x; }
vec3 get_blended_pixel_xy(vec3[100] colours, int x, int y, float xw, float yw) {
	return blend4({
		colours[get_idx(x-4,y-4)],
		colours[get_idx(x-3,y-4)],
		colours[get_idx(x-4,y-3)],
		colours[get_idx(x-3,y-3)]},
	xw,yw);
}

void fragment() {
	//COLOR.rgb = vec3(SCREEN_UV.x, SCREEN_UV.y, 0.0);
	//vec4 dreamrect = vec4(0.0, 0.0, dreamsize);
	vec2 dreamsize_uv = dreamsize * SCREEN_PIXEL_SIZE;
	vec2 top_left_corner_of_dream = (vec2(1.,1.) - dreamsize_uv * zoom)*0.5;
	vec2 screen_x1_uv = (SCREEN_UV - top_left_corner_of_dream) / zoom;
	vec2 screen_x1 = screen_x1_uv / SCREEN_PIXEL_SIZE;
	vec2 screen_x1_int = vec2(floor(screen_x1.x-0.5)+0.5, floor(screen_x1.y-0.5)+0.5); // rounded
	vec2 screen_x1_int_uv = screen_x1_int * SCREEN_PIXEL_SIZE;
	
	float xw = smoothstep(0., 1., screen_x1.x - screen_x1_int.x);
	float yw = smoothstep(0., 1., screen_x1.y - screen_x1_int.y);
	
	vec3[100] hundred_colours;

	vec4 dreamrect_uv = vec4(0.0, 0.0, dreamsize_uv);

	for(int x=-4;x<=5;x++) {
		for(int y=-4;y<=5;y++) {
			int i = get_idx(x+4,y+4);
			vec2 pixel_x1_int_uv = screen_x1_int_uv + vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE;
			hundred_colours[i] = valueInsideRect(
				pixel_x1_int_uv,
				dreamrect_uv,
				texture(SCREEN_TEXTURE, pixel_x1_int_uv).rgb
			);
		}
	}
	
	vec3 colsum = vec3(0.);
	float wtotal = 0.;
	
	// performance sucks wtf
	
	for(int x=4;x<=4;x++) {
		for(int y=4;y<=4;y++) {
			float w = 1.;
			colsum += get_blended_pixel_xy(hundred_colours, x, y, xw, yw);
			wtotal += w;
		}
	}
	
	COLOR.rgb = colsum;
	//COLOR.rgb = get_blended_pixel_xy(hundred_colours, 4, 4, xw, yw); //hundred_colours[get_idx(4,4)];
//
	//vec3 colour_sum = vec3(0.);
	//float colour_w = 0.;
	//
	//for(int x=-blur_range; x<=blur_range; x++) {
		//for(int y=-blur_range; y<=blur_range; y++) {
			//vec3 colour = valueInsideRect(
				//pixel_x1_int_uv,
				//texture(SCREEN_TEXTURE, pixel_x1_int_uv).rgb
			//);
			//vec2 c2p = pixel_x1_int_uv - screen_x1_uv;
			//vec2 c2ppx = (pixel_x1_int_uv - screen_x1_uv) / SCREEN_PIXEL_SIZE;
			//float dist = max(abs(c2ppx.x),abs(c2ppx.y));
			//float w = smoothstep(blur_amount + 1., blur_amount, dist);
			//colour_sum += w * colour;
			//colour_w += w;
		//}
	//}
	
	//COLOR.rgb = colour_sum / colour_w;
}
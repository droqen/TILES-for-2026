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
vec3 get_uncached_blended_xy_pixelcol(
	sampler2D screen_texture,
	vec2 screen_x1_int_uv,
	vec4 dreamrect_uv,
	vec2 p,
	float xw, float yw
) {
	vec2[4] pixeluvs = {
		screen_x1_int_uv,
		screen_x1_int_uv + vec2(p.x,0.),
		screen_x1_int_uv + vec2(0.,p.y),
		screen_x1_int_uv + p
	};
	vec3[4] colours;
	for(int i=0;i<4;i++) { colours[i] = valueInsideRect(
		pixeluvs[i],
		dreamrect_uv,
		texture(screen_texture, pixeluvs[i]).rgb
	); }
	return blend4(colours,xw,yw);
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
	vec4 dreamrect_uv = vec4(0.0, 0.0, dreamsize_uv);
	
	COLOR.rgb = get_uncached_blended_xy_pixelcol(
		SCREEN_TEXTURE, screen_x1_int_uv, dreamrect_uv,
		SCREEN_PIXEL_SIZE, xw, yw);
}
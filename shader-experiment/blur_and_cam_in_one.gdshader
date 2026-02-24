shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform float blur_amount : hint_range(0.1, 3.0) = 0.2;
uniform float zoom : hint_range(0.5, 100.0) = 4.0;
uniform vec2 dreamsize = vec2(100.0, 100.0);



float triangle_height_at_point(float Brad, float H, float M, float X) {
	float slope = abs(H/Brad); // if Brad is 0, this is infinite. do not let Brad = 0
	float drop = slope * abs(X-M);
	return max(0.0,H-drop*slope);
}
float triradleft(float Brad, float H, float M, float X, float half_triangle_area) {
	float slope = H/Brad; // H>0, Brad>0
	float HX = (X - (M-Brad))*slope;
	return clamp(
		(X - (M-Brad)) * HX * 0.5,
		0.0, half_triangle_area);
}
float triradright(float Brad, float H, float M, float X, float half_triangle_area) {
	float slope = H/Brad; // H>0, Brad>0
	float HX = ((M+Brad) - X)*slope;
	return clamp(
		((M+Brad) - X) * HX * 0.5,
		0.0, half_triangle_area);
}
float triangle_section_area(float Brad, float H, float M, float SA, float SB, float half_triangle_area) {
	//return abs(M-(SA+SB)*0.5) / Brad;
	return
		 triradleft(Brad,H,M,SB,half_triangle_area)
		-triradleft(Brad,H,M,SA,half_triangle_area)
		+triradright(Brad,H,M,SA,half_triangle_area)
		-triradright(Brad,H,M,SB,half_triangle_area)
	;
}


vec3 blend4(vec3[4] colours, float xw, float yw) {
	return mix(
		mix(colours[0], colours[1], xw),
		mix(colours[2], colours[3], xw),
		yw
	);
}
const float[4] ifloats = {0., 1., 2., 3.};

vec3 blend16(vec3[16] colours, float xw, float yw, vec2 debug_screen_uv) {
	float Brad = max(0.1, blur_amount);
	float H = 0.5 / Brad;
	int i=0;
	
	//float triheight = triangle_height_at_point(Brad,H,xw,1.5) * triangle_height_at_point(Brad,H,yw,1.5);
	//return vec3(triheight);
	//if (triheight<=0.24) { return vec3(1.,1.,1.); }
	float area =
		triangle_section_area(Brad, H, xw, 0., 1., 0.5) *
		triangle_section_area(Brad, H, yw, 0., 1., 0.5);
	
	//return vec3(triangle_section_area(Brad, H, xw, 0., 1., 0.5 * Brad));
	
	vec3 colsum=vec3(0.,0.,0.);
	float colw=0.0;
	for(int y=0;y<3;y++) {
		for(int x=0;x<3;x++) {
			float w =
			triangle_height_at_point(Brad, H, xw, ifloats[x]+0.5) +
			triangle_height_at_point(Brad, H, yw, ifloats[y]+0.5) ;
			//triangle_section_area(Brad, H, xw, ifloats[x], ifloats[x+1], 0.5) +
			//triangle_section_area(Brad, H, yw, ifloats[y], ifloats[y+1], 0.5) ;
			colsum += colours[i] * w;
			colw += w;
			i++;
		}
	}
	
	return mix(colsum/colw, vec3(area), smoothstep(0.4,0.6,debug_screen_uv.x));
	
	return colsum/colw;
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
	
	//vec3[16] colours = {
		//texture(SCREEN_TEXTURE, screen_x1_int_uv      -or_uv      -od_uv).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv                  -od_uv).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv+or_uv            -od_uv).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv+or_uv+or_uv      -od_uv).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv      -or_uv            ).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv                        ).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv+or_uv                  ).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv+or_uv+or_uv            ).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv      -or_uv+od_uv      ).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv            +od_uv      ).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv+or_uv      +od_uv      ).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv+or_uv+or_uv+od_uv      ).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv      -or_uv+od_uv+od_uv).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv            +od_uv+od_uv).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv+or_uv      +od_uv+od_uv).rgb ,
		//texture(SCREEN_TEXTURE, screen_x1_int_uv+or_uv+or_uv+od_uv+od_uv).rgb };
	vec2[16] offsets = {
		      -or_uv      -od_uv,
		                  -od_uv,
		+or_uv            -od_uv,
		+or_uv+or_uv      -od_uv,
		      -or_uv            ,
		vec2(0.,0.)             ,
		+or_uv                  ,
		+or_uv+or_uv            ,
		      -or_uv+od_uv      ,
		            +od_uv      ,
		+or_uv      +od_uv      ,
		+or_uv+or_uv+od_uv      ,
		      -or_uv+od_uv+od_uv,
		            +od_uv+od_uv,
		+or_uv      +od_uv+od_uv,
		+or_uv+or_uv+od_uv+od_uv
	};
	vec3[16] colours;
	
	vec3 colour_sum = vec3(0.);
	float colour_w = 0.;
	
	for (int i=0;i<16;i++) {
		vec2 pos = screen_x1_int_uv + offsets[i];
		vec2 away = (pos - screen_x1_uv) / SCREEN_PIXEL_SIZE;
		float dist = sqrt(
			away.x*away.x + away.y*away.y
		);
		if (dist>blur_amount) { continue; }
		colours[i] = texture(SCREEN_TEXTURE, screen_x1_int_uv + offsets[i]).rgb;
		vec3 c = colours[i];
		float w = 100.0/dist/dist;
		colour_sum += colours[i] * w;
		colour_w += w;
	};
	
	
	COLOR.rgb = valueInsideRect(
		screen_x1_uv,
		vec4(0.0, 0.0, dreamsize_uv),
		
		//blend4(
			//{
				//colours[5],colours[6],colours[9],colours[10]
			//},
			////screen_x1.x - screen_x1_int.x,
			////screen_x1.y - screen_x1_int.y
			//smoothstep(0.0, SCREEN_PIXEL_SIZE.x, (screen_x1_uv.x - screen_x1_int_uv.x)/blur_amount),
			//smoothstep(0.0, SCREEN_PIXEL_SIZE.y, (screen_x1_uv.y - screen_x1_int_uv.y)/blur_amount)
		//)
		
		//colour_sum / colour_w
		vec3(colour_w)
		
		//blend16(colours,
			//smoothstep(0.0, SCREEN_PIXEL_SIZE.x, screen_x1_uv.x - screen_x1_int_uv.x),
			//smoothstep(0.0, SCREEN_PIXEL_SIZE.y, screen_x1_uv.y - screen_x1_int_uv.y),
			//SCREEN_UV
		//)
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
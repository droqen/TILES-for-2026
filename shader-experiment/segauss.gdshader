shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform float blur_amount : hint_range(0.0, 5.0) = 1.5;

const int samples = 35;
const int LOD = 2;
const int sLOD = 1 << LOD;
const float sigma = float(samples) * .25;

// thanks https://www.shadertoy.com/view/ltScRG

float gaussian(vec2 i) {
	return exp( -.5 * dot(i/=sigma,i)) / (6.28*sigma*sigma);
}

vec4 blur(sampler2D sp, vec2 U, vec2 scale) {
	vec4 O = vec4(0);
	int s = samples/sLOD;
	for ( int i = 0; i < s*s; i++ ) {
		vec2 d = vec2(float(i%s),float(i/s))*float(sLOD) - float(samples)/2.;
		O += gaussian(d) * textureLod( sp, U + scale * d, float(LOD) );
	}
	return O / O.a;
}

void mainImage(out vec4 O, vec2 U) {
	O = blur( iChannel0, U/iResolution.xy, 1./iChannelResolution[0].xy );
}

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
	vec2 texel = SCREEN_PIXEL_SIZE;
	for (int x = 1; x <= 8; x++) {
		tex_sum += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(float(x),0.0) * texel) * w[x];
		tex_sum += texture(SCREEN_TEXTURE, SCREEN_UV - vec2(float(x),0.0) * texel) * w[x];
		weight_sum += w[x] * 2.0;
	}
	COLOR.rgb = (tex_sum/weight_sum).rgb;
}
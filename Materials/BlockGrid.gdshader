shader_type spatial;
render_mode blend_mix;

uniform float gridSize = 1.0;
uniform float gridThickness = 0.05;
uniform float gridFuzz = 0.01;
uniform float hazard = 0.0;
uniform vec4 gridColor : source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform vec4 faceColor : source_color = vec4(1.0, 1.0, 1.0, 0.0);
uniform vec3 origin = vec3(0.0, 0.0, 0.0);
uniform sampler2D scratches;

void fragment() {
	vec2 coord = UV * vec2(3.0, 2.0);
	
	float diagGridScalar = gridSize * 0.15;
	float diag = (coord.x + coord.y - diagGridScalar * 0.2 * gridThickness) / (gridSize * diagGridScalar);
	diag = diag - floor(diag);
	float thresh = 1.0 - (20.0 * gridThickness);
	float marginStrip = max(smoothstep(thresh - gridFuzz/diagGridScalar, thresh, diag), smoothstep(gridFuzz/diagGridScalar, 0.0, diag));
	
	coord = coord - floor(coord);
	vec2 scratch_uv = coord;
	coord = max(smoothstep(gridThickness + gridFuzz, gridThickness, coord), smoothstep(1.0 - gridThickness - gridFuzz, 1.0 - gridThickness, coord));
	float t = max(marginStrip * hazard, max(coord.x, coord.y));
	
	ALBEDO = mix(faceColor.rgb, gridColor.rgb, t);
	ALPHA =  mix(faceColor.a, gridColor.a, t);
	NORMAL_MAP = texture(scratches, scratch_uv).rgb;
	METALLIC = 0.8;
	ROUGHNESS = 0.7;
}

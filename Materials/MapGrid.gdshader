shader_type spatial;
render_mode blend_mix;

uniform float gridSize = 1.0;
uniform float gridThickness = 0.05;
uniform float gridFuzz = 0.01;
uniform float hazard = 0.0;
uniform vec4 gridColor : source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform vec4 faceColor : source_color = vec4(1.0, 1.0, 1.0, 0.0);
uniform vec3 origin = vec3(0.0, 0.0, 0.0);

varying vec2 world_space_uv;

void vertex()
{	
	// Calculation of TANGENT and BINORMAL similar to tri-planar projection
	TANGENT = vec3(0.0, 0.0, 1.0) * abs(NORMAL.x);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(NORMAL.y);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	
	BINORMAL = vec3(0.0, 1.0, 0.0) * abs(NORMAL.x);
	BINORMAL += vec3(0.0, 0.0, 1.0) * abs(NORMAL.y);
	BINORMAL += vec3(0.0, 1.0, 0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
	
	vec3 basis_x = BINORMAL;
	vec3 basis_y = TANGENT;
	
    vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 pos = world_position - origin;
	float x = dot(basis_x, pos);
	float y = dot(basis_y, pos);
	
	world_space_uv = vec2(x, y);
}

void fragment() {
	vec2 coord = (world_space_uv / gridSize);
	
	float diagGridScalar = gridSize * 0.15;
	float diagThicknessScalar = gridThickness / 0.05;
	float diag = (coord.x + coord.y - diagGridScalar * 0.166667 * diagThicknessScalar) / (gridSize * diagGridScalar);
	diag = diag - floor(diag);
	float thresh = 1.0 - (0.3333 * diagThicknessScalar);
	float marginStrip = max(smoothstep(thresh - gridFuzz/diagGridScalar, thresh, diag), smoothstep(gridFuzz/diagGridScalar, 0.0, diag));
	
	coord = coord + vec2(0.5);
	coord = coord - floor(coord);
	coord = max(smoothstep(gridThickness + gridFuzz, gridThickness, coord), smoothstep(1.0 - gridThickness - gridFuzz, 1.0 - gridThickness, coord));
	float t = max(marginStrip * hazard, max(coord.x, coord.y));
		
	ALBEDO = mix(faceColor.rgb, gridColor.rgb, t);
	ALPHA =  mix(faceColor.a, gridColor.a, t);
}

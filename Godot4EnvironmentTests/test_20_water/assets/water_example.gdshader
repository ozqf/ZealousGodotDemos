// assembled from marcelb GodotSSRWater
shader_type spatial;
render_mode blend_mix, depth_draw_always, diffuse_lambert, specular_schlick_ggx;

uniform vec4 water_color : source_color = vec4(0.0, 0.4, 0.6, 0.8);
uniform vec4 deep_water_color : source_color = vec4(0.0, 0.1, 0.3, 1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.05;

// Noise textures for ripples
uniform sampler2D normal_map_a : hint_normal;
uniform sampler2D normal_map_b : hint_normal;
uniform vec2 wave_direction_a = vec2(0.5, 0.0);
uniform vec2 wave_direction_b = vec2(0.0, 0.5);
uniform float wave_speed = 0.03;

// Refraction strength
uniform float refraction_strength : hint_range(0.0, 1.0) = 0.05;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	METALLIC = metallic;
    // Time-based UV animation for scrolling ripples
    vec2 time_a = TIME * wave_direction_a * wave_speed;
    vec2 time_b = TIME * wave_direction_b * wave_speed;
    
    // Blend two scrolling normal maps for dynamic, non-repeating waves
    vec3 normal_a = texture(normal_map_a, UV + time_a).rgb * 2.0 - 1.0;
    vec3 normal_b = texture(normal_map_b, UV + time_b).rgb * 2.0 - 1.0;
    vec3 blended_normal = normalize(normal_a + normal_b);
    
    // Pass normals to Godot's built-in PBR pipeline for realistic reflection
    NORMAL_MAP = blended_normal * 0.5 + 0.5;
    ROUGHNESS = roughness;
    
    // Calculate Refraction by distorting the screen UVs using the normal map
    vec2 refracted_uv = SCREEN_UV + (blended_normal.xy * refraction_strength);
    vec3 background_color = texture(screen_texture, refracted_uv).rgb;
    
    // Basic mix of water color and refracted background
    ALBEDO = mix(water_color.rgb, background_color, 1.0 - water_color.a);
}

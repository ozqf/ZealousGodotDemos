shader_type spatial;
// depth_test_disabled allows this overlay to draw directly on top of the base mesh coordinates
render_mode blend_mix, diffuse_lambert, specular_disabled, unshaded, depth_test_disabled;

uniform float max_refraction_depth : hint_range(0.1, 20.0) = 4.0;
uniform float shoreline_fade_distance : hint_range(0.05, 5.0) = 0.5;
uniform float refraction_strength : hint_range(0.0, 0.1) = 0.01;

uniform sampler2D normal_map_a : hint_normal;
uniform sampler2D normal_map_b : hint_normal;
uniform vec2 wave_dir_a = vec2(0.03, 0.01);
uniform vec2 wave_dir_b = vec2(-0.02, 0.02);

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

void fragment() {
    // 1. Calculate Refraction Ripples
    vec3 normal_a = texture(normal_map_a, UV + TIME * wave_dir_a).rgb * 2.0 - 1.0;
    vec3 normal_b = texture(normal_map_b, UV + TIME * wave_dir_b).rgb * 2.0 - 1.0;
    vec3 blended_normal = normalize(normal_a + normal_b);
    
    // 2. Camera Ray Distance
    float depth_raw_clean = texture(depth_texture, SCREEN_UV).r;
    vec3 ndc_clean = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw_clean);
    vec4 view_pos_clean = INV_PROJECTION_MATRIX * vec4(ndc_clean, 1.0);
    view_pos_clean.xyz /= view_pos_clean.w;
    float ray_distance = max(0.0, length(view_pos_clean.xyz - VERTEX));
    
    // 3. Sample the refracted background
    float refraction_dampener = clamp(ray_distance / 0.5, 0.0, 1.0);
    vec2 distorted_uv = SCREEN_UV + (blended_normal.xy * refraction_strength * refraction_dampener);
    ALBEDO = texture(screen_texture, distorted_uv).rgb;
    
    // 4. Clean Alpha Transitions
    float fresnel = pow(1.0 - clamp(dot(vec3(0.0, 0.0, 1.0), VIEW), 0.0, 1.0), 4.0);
    
    // Smooth fade out from the water mesh to 0 right at the shoreline edge
    float edge_fade = clamp(ray_distance / shoreline_fade_distance, 0.0, 1.0);
    
    // Smooth fade out as water deepens (1.0 at shore, drops to 0.0 at max opacity depth)
    float visibility_factor = 1.0 - clamp(ray_distance / max_refraction_depth, 0.0, 1.0);
    
    // Combine everything: only draw refraction when shallow, looking down, and away from immediate shore lines
    ALPHA = visibility_factor * (1.0 - fresnel) * edge_fade;
}

shader_type spatial;
render_mode blend_mix, depth_draw_never, diffuse_lambert, specular_disabled, unshaded, depth_test_disabled;

uniform float max_refraction_depth : hint_range(0.1, 40.0) = 8.0;
uniform float shoreline_fade_distance : hint_range(0.05, 5.0) = 0.5;
uniform float refraction_strength : hint_range(0.0, 0.1) = 0.01;
uniform float wave_frequency : hint_range(0.001, 2.0) = 0.1;

uniform sampler2D normal_map_a : hint_normal;
uniform sampler2D normal_map_b : hint_normal;
uniform vec2 wave_dir_a = vec2(0.03, 0.01);
uniform vec2 wave_dir_b = vec2(-0.02, 0.02);

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 meter_uv = world_pos.xz * wave_frequency;
    
    vec3 normal_a = texture(normal_map_a, meter_uv + TIME * wave_dir_a).rgb * 2.0 - 1.0;
    vec3 normal_b = texture(normal_map_b, meter_uv + TIME * wave_dir_b).rgb * 2.0 - 1.0;
    vec3 blended_normal = normalize(normal_a + normal_b);
    
    // 1. Precise View Space Ray Distance Calculation
    float depth_raw = texture(depth_texture, SCREEN_UV).r;
    vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw);
    vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    view_pos.xyz /= view_pos.w;
    float ray_distance = max(0.0, length(view_pos.xyz - VERTEX));
    
    // 2. REFRACTION ANCHOR (Fixes Ground Bleeding Artifacts)
    // Force wave refraction strength down to 0 right at the shoreline edge
    // This stops pixels from being pulled past the terrain borders
    float refraction_dampener = smoothstep(0.0, shoreline_fade_distance, ray_distance);
    vec2 distorted_uv = SCREEN_UV + (blended_normal.xy * refraction_strength * refraction_dampener);
    ALBEDO = texture(screen_texture, distorted_uv).rgb;
    
    // 3. Smooth Edge Fade and Fresnel Layout
    float fresnel = pow(1.0 - clamp(dot(vec3(0.0, 0.0, 1.0), VIEW), 0.0, 1.0), 4.0);
    float edge_fade = smoothstep(0.0, shoreline_fade_distance, ray_distance);
    
    // Smoothly fade out the refraction layer as the water deepens
    float transparency_fade = 1.0 - smoothstep(0.0, max_refraction_depth, ray_distance);
    
    // The alpha transparency matches the edge fade, smoothly blending out at the shore
    ALPHA = transparency_fade * (1.0 - fresnel) * edge_fade;
}

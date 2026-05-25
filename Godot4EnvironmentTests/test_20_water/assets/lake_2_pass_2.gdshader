shader_type spatial;
render_mode blend_mix, diffuse_lambert, specular_schlick_ggx, depth_test_disabled;

uniform float max_refraction_depth : hint_range(0.1, 40.0) = 10.0;
uniform float shoreline_fade_distance : hint_range(0.05, 5.0) = 0.5;
uniform float refraction_strength : hint_range(0.0, 0.1) = 0.01;
uniform float wave_frequency : hint_range(0.001, 2.0) = 0.1;
uniform float water_roughness : hint_range(0.0, 1.0) = 0.02;

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
    
    // 1. Align the Normal Maps for Reflection and Refraction Jitter
    vec3 normal_a = texture(normal_map_a, meter_uv + TIME * wave_dir_a).rgb * 2.0 - 1.0;
    vec3 normal_b = texture(normal_map_b, meter_uv + TIME * wave_dir_b).rgb * 2.0 - 1.0;
    vec3 blended_normal = normalize(normal_a + normal_b);
    
    // Apply normal maps to this layer so reflections warp with the waves
    NORMAL_MAP = blended_normal * 0.5 + 0.5;
    ROUGHNESS = water_roughness;

    // 2. Enable Full Metallic Reflections
    float fresnel = pow(1.0 - clamp(dot(vec3(0.0, 0.0, 1.0), VIEW), 0.0, 1.0), 4.0);
    METALLIC = mix(0.0, 1.0, fresnel);
    
    // 3. Camera Ray Distance
    float depth_raw_clean = texture(depth_texture, SCREEN_UV).r;
    vec3 ndc_clean = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw_clean);
    vec4 view_pos_clean = INV_PROJECTION_MATRIX * vec4(ndc_clean, 1.0);
    view_pos_clean.xyz /= view_pos_clean.w;
    float ray_distance = max(0.0, length(view_pos_clean.xyz - VERTEX));
    
    // 4. Sample the Refracted Background Image
    float refraction_dampener = smoothstep(0.0, 0.5, ray_distance);
    vec2 distorted_uv = SCREEN_UV + (blended_normal.xy * refraction_strength * refraction_dampener);
    
    // Pass the background texture to Albedo
    ALBEDO = texture(screen_texture, distorted_uv).rgb;
    
    // 5. Opacity Handoff Control
    float edge_fade = smoothstep(0.0, shoreline_fade_distance, ray_distance);
    float visibility_factor = 1.0 - smoothstep(0.0, max_refraction_depth, ray_distance);
    
    // Smoothly drop opacity in deep areas to hand control back to the base pass
    ALPHA = visibility_factor * (1.0 - fresnel) * edge_fade;
}

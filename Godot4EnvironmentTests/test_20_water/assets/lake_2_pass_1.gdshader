shader_type spatial;
// Changed depth_draw_always to depth_draw_never to enable alpha edge blending
render_mode blend_mix, depth_draw_never, diffuse_lambert, specular_schlick_ggx;

uniform vec4 shallow_color : source_color = vec4(0.1, 0.6, 0.8, 1.0);
uniform vec4 deep_color : source_color = vec4(0.01, 0.1, 0.25, 1.0);
uniform float depth_distance : hint_range(0.1, 20.0) = 5.0;

// NEW: Controls the width of the transparent strip against your land
uniform float shoreline_fade_distance : hint_range(0.05, 5.0) = 0.5;

uniform sampler2D normal_map_a : hint_normal;
uniform sampler2D normal_map_b : hint_normal;
uniform vec2 wave_dir_a = vec2(0.03, 0.01);
uniform vec2 wave_dir_b = vec2(-0.02, 0.02);
uniform float ripple_strength : hint_range(0.0, 0.5) = 0.05;

uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

void fragment() {
    // 1. Calculate Ripples for specular highlights and reflections
    vec3 normal_a = texture(normal_map_a, UV + TIME * wave_dir_a).rgb * 2.0 - 1.0;
    vec3 normal_b = texture(normal_map_b, UV + TIME * wave_dir_b).rgb * 2.0 - 1.0;
    vec3 blended_normal = normalize(normal_a + normal_b);
    NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), blended_normal * 0.5 + 0.5, ripple_strength);
    ROUGHNESS = 0.02; 

    // 2. Fixed Fresnel Mirror Angle for the Horizon
    float fresnel = pow(1.0 - clamp(dot(vec3(0.0, 0.0, 1.0), VIEW), 0.0, 1.0), 4.0);
    METALLIC = mix(0.0, 1.0, fresnel);
    
    // 3. Camera Ray Distance
    float depth_raw = texture(depth_texture, SCREEN_UV).r;
    vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw);
    vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    view_pos.xyz /= view_pos.w;
    float ray_distance = max(0.0, length(view_pos.xyz - VERTEX));
    
    // 4. Color Gradient Blend
    float depth_blend = clamp(ray_distance / depth_distance, 0.0, 1.0);
    ALBEDO = mix(shallow_color.rgb, deep_color.rgb, depth_blend);
    
    // 5. NEW: Smooth Shoreline Alpha Fade
    // Gently lowers the opacity of the blue tint to 0.0 right at the shoreline edge
    float edge_fade = clamp(ray_distance / shoreline_fade_distance, 0.0, 1.0);
    ALPHA = edge_fade;
}

shader_type spatial;
render_mode depth_draw_always, diffuse_lambert, specular_schlick_ggx;

uniform vec4 shallow_color : source_color = vec4(0.1, 0.6, 0.8, 1.0);
uniform vec4 deep_color : source_color = vec4(0.01, 0.1, 0.25, 1.0);
uniform float depth_distance : hint_range(0.1, 40.0) = 12.0;
uniform float shoreline_fade_distance : hint_range(0.05, 5.0) = 0.5;

uniform sampler2D normal_map_a : hint_normal;
uniform sampler2D normal_map_b : hint_normal;
uniform vec2 wave_dir_a = vec2(0.03, 0.01);
uniform vec2 wave_dir_b = vec2(-0.02, 0.02);
uniform float ripple_strength : hint_range(0.0, 0.5) = 0.05;
uniform float wave_frequency : hint_range(0.001, 2.0) = 0.1; 

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
    NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), blended_normal * 0.5 + 0.5, ripple_strength);
    ROUGHNESS = 0.02; 

    float fresnel = pow(1.0 - clamp(dot(vec3(0.0, 0.0, 1.0), VIEW), 0.0, 1.0), 4.0);
    METALLIC = mix(0.0, 1.0, fresnel);
    
    float depth_raw = texture(depth_texture, SCREEN_UV).r;
    vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw);
    vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    view_pos.xyz /= view_pos.w;
    float ray_distance = max(0.0, length(view_pos.xyz - VERTEX));
    
    float depth_blend = smoothstep(0.0, depth_distance, ray_distance);
    vec3 water_color = mix(shallow_color.rgb, deep_color.rgb, depth_blend);
    
    vec3 raw_background = texture(screen_texture, SCREEN_UV).rgb;
    float edge_fade = smoothstep(0.0, shoreline_fade_distance, ray_distance);
    
    ALBEDO = mix(raw_background, water_color, edge_fade);
}

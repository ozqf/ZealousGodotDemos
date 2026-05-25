shader_type spatial;
// "render_mode depth_draw_always" is required to keep it in the opaque pipeline
render_mode blend_mix, depth_draw_always, diffuse_lambert, specular_schlick_ggx;

uniform vec4 water_color : source_color = vec4(0.0, 0.4, 0.6, 1.0);

void fragment() {
    NORMAL_MAP = vec3(0.5, 0.5, 1.0); // Flat surface
    ROUGHNESS = 0.01;                  // Sharp mirror mirror
    METALLIC = 1.0;                   // Forces maximum reflection
    ALBEDO = water_color.rgb;         // Solid base color
}

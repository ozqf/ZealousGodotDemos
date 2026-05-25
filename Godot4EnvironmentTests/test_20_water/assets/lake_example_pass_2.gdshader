shader_type spatial;
// "render_mode blend_mix" allows alpha transparency over the base layer
render_mode blend_mix, diffuse_lambert, specular_disabled, unshaded;

uniform float refraction_strength : hint_range(0.0, 1.0) = 0.02;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Read the screen behind the lake
    vec3 background_color = texture(screen_texture, SCREEN_UV).rgb;
    
    // Output the background color
    ALBEDO = background_color;
    
    // Adjust the Alpha slider to control how much "underwater" geometry bleeds through
    ALPHA = 0.4; 
}
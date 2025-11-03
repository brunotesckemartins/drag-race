vec2 curve(vec2 uv) {
    uv = (uv - 0.5) * 2.0; 
    
    uv *= 1.0 + dot(uv, uv) * 0.010; 
    
    uv = (uv * 0.5) + 0.5; 
    return uv;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    
    vec2 curved_uv = curve(texture_coords);

    if (curved_uv.x < 0.0 || curved_uv.x > 1.0 || curved_uv.y < 0.0 || curved_uv.y > 1.0) {
        return vec4(0.0, 0.0, 0.0, 1.0); 
    }

    float r = Texel(texture, vec2(curved_uv.x + 0.003, curved_uv.y)).r;
    float g = Texel(texture, curved_uv).g;
    float b = Texel(texture, vec2(curved_uv.x - 0.003, curved_uv.y)).b;
    float a = Texel(texture, curved_uv).a;
    
    vec4 texColor = vec4(r, g, b, a);

    float scanline = mod(floor(screen_coords.y), 2.0) == 0.0 ? 0.7 : 1.0;
    texColor.rgb *= scanline;

    vec2 vignette_uv = (texture_coords - 0.5) * 2.0;
    float vignette = 1.0 - dot(vignette_uv, vignette_uv) * 0.25; 
    texColor.rgb *= vignette;

    return texColor * color;
}
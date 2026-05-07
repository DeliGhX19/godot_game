shader_type canvas_item;

uniform float intensity = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 col = texture(SCREEN_TEXTURE, uv);

    // 雪天偏白灰调
    float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    vec3 desaturated = mix(col.rgb, vec3(gray), 0.55 * intensity);
    vec3 snowy = mix(desaturated, vec3(0.85, 0.88, 0.95), 0.4 * intensity);
    snowy *= 1.1 - 0.2 * intensity; 
    snowy = mix(snowy, vec3(0.75, 0.78, 0.85), 0.15 * intensity); 
    col.rgb = snowy;

    // 边缘白雾模糊
    float dist = max(abs(uv.x - 0.5), abs(uv.y - 0.5)) * 2.0;        
    float edge_fog = smoothstep(0.35, 0.95, dist);  

    // 轻微采样周围像素，模拟边缘模糊散开
    float blur_amount = 0.012 * intensity * edge_fog;
    vec4 blurred = vec4(0.0);
    int samples = 5;
    for (int i = -samples; i <= samples; i++) {
        for (int j = -samples; j <= samples; j++) {
            vec2 off = vec2(float(i), float(j)) * blur_amount / float(samples);
            blurred += texture(SCREEN_TEXTURE, uv + off);
        }
    }
    blurred /= float((2*samples+1)*(2*samples+1));

    // 边缘混合白色+模糊图像
    col.rgb = mix(col.rgb, blurred.rgb * vec3(0.9, 0.92, 1.0), edge_fog * 0.7 * intensity);
    col.rgb = mix(col.rgb, vec3(0.88, 0.9, 1.0), edge_fog * 0.4 * intensity); 

    //暴风雪粒子
    float snow = 0.0;
    vec3 snow_color = vec3(0.95, 0.97, 1.0);
    float snow_speed = 0.35;

    for (int k = 0; k < 28; k++) {
        float fk = float(k);
        vec2 seed = vec2(fk * 0.37, fk * 1.73);
        float x = hash(seed) * 0.95 + 0.025;
        float y = fract(hash(seed + vec2(0.1, 0.2)) + TIME * snow_speed * (0.8 + hash(seed + vec2(0.3, 0.4)) * 0.5));
        float size = 0.002 + hash(seed + vec2(0.5, 0.6)) * 0.006;
        float brightness = 0.5 + hash(seed + vec2(0.7, 0.8)) * 0.5;
        float wind = sin(TIME * 1.2 + fk) * 0.003;
        x += wind;
        float d = length(uv - vec2(x, y));
        snow += brightness * smoothstep(size, 0.0, d) * 1.2;
    }
    col.rgb += snow_color * snow * intensity * 0.6;

    // 混合原图
    vec4 orig = texture(SCREEN_TEXTURE, SCREEN_UV);
    col.rgb = mix(orig.rgb, col.rgb, intensity);

    COLOR = col;
}
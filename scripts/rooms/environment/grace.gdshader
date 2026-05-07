shader_type canvas_item;

uniform float intensity = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 col = texture(SCREEN_TEXTURE, uv);

    // 暖金色调
    vec3 warm = col.rgb * vec3(1.12, 1.04, 0.82);
    col.rgb = mix(col.rgb, warm, 0.65 * intensity);
    col.rgb *= 1.0 + 0.15 * intensity;   // 更亮

    // 上方洒下的渐变光
    float top_glow = smoothstep(0.0, 1.0, 1.0 - uv.y) * 0.3;
    col.rgb += vec3(1.0, 0.9, 0.5) * top_glow * intensity;

    // 神圣光尘：缓慢飘落的金色粒子
    vec3 dust_color = vec3(1.0, 0.95, 0.6);
    float dust = 0.0;
    float fall_speed = 0.015;
    for (int i = 0; i < 15; i++) {
        float fi = float(i);
        vec2 seed = vec2(fi * 0.47, fi * 1.37);
        float x = hash(seed) * 0.95 + 0.025;
        float y = fract(hash(seed + vec2(0.1, 0.2)) + TIME * fall_speed);
        float size = 0.002 + hash(seed + vec2(0.3, 0.4)) * 0.005;
        float brightness = 0.4 + hash(seed + vec2(0.5, 0.6)) * 0.6;
        float dist = length(uv - vec2(x, y));
        dust += brightness * smoothstep(size, 0.0, dist) * 0.8;
        // 微弱拖尾
        for (int t = 1; t <= 2; t++) {
            vec2 tail = vec2(x, y) - vec2(0.0, 0.004 * float(t));
            float tail_dist = length(uv - tail);
            dust += brightness * 0.2 * smoothstep(size * 0.7, 0.0, tail_dist);
        }
    }
    col.rgb += dust_color * dust * intensity * 0.55;

    // 轻微光晕暗角（实际上让边缘稍暗，突出中心）
    float vignette = 1.0 - distance(uv, vec2(0.5)) * 0.5 * intensity;
    col.rgb *= clamp(vignette, 0.75, 1.0);

    vec4 orig = texture(SCREEN_TEXTURE, SCREEN_UV);
    col.rgb = mix(orig.rgb, col.rgb, intensity);

    COLOR = col;
}
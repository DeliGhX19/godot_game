shader_type canvas_item;

uniform float intensity = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 3; i++) {
        v += amp * noise(p * freq);
        freq *= 2.0;
        amp *= 0.5;
    }
    return v;
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5, 0.5);

    // 水波
    vec2 base = vec2(uv.x * 4.5, uv.y * 4.5 + TIME * 0.5);
    float dx = fbm(base) * 2.0 - 1.0;
    float dy = fbm(base + vec2(0.7, 0.3)) * 2.0 - 1.0;
    float strength = 0.018 * intensity;
    vec2 offset = vec2(dx, dy - 0.3) * strength;

    vec2 slow = vec2(uv.x * 1.5, uv.y * 1.5 + TIME * 0.15);
    float sx = fbm(slow) * 2.0 - 1.0;
    float sy = fbm(slow + vec2(0.5, 0.5)) * 2.0 - 1.0;
    offset += vec2(sx, sy) * strength * 0.7;

    vec2 distorted_uv = uv + offset;
    vec4 col = texture(SCREEN_TEXTURE, distorted_uv);

    // 色调
    vec3 water_tint = vec3(0.2, 0.5, 0.7);
    float tint_strength = 0.45 * intensity;
    col.rgb = mix(col.rgb, col.rgb * water_tint, tint_strength);
    col.rgb *= 0.8;

    // 雾效
    float dist = distance(uv, center);
    float fog = smoothstep(0.2, 1.2, dist * 2.0) * 0.6 * intensity;
    col.rgb = mix(col.rgb, vec3(0.1, 0.2, 0.3), fog);

    // 垂直光照
    float top_light = smoothstep(0.0, 0.5, uv.y) * 0.5;
    col.rgb = mix(col.rgb, col.rgb * 1.2, top_light * intensity);
    float bottom_dark = smoothstep(0.5, 1.0, uv.y) * 0.3;
    col.rgb *= 1.0 - bottom_dark * intensity;

    // 悬浮颗粒
    float particles = 0.0;
    float part_rise_speed = 0.015;
    for (int i = 0; i < 10; i++) {
        float fi = float(i);
        vec2 seed = vec2(fi * 0.13, fi * 0.97);
        float base_x = hash(seed) * 0.95 + 0.025;
        float phase_y = hash(seed + vec2(0.1, 0.2));
        float size = 0.001 + hash(seed + vec2(0.3, 0.4)) * 0.003;
        float drift = hash(seed + vec2(0.5, 0.6)) * 0.005;

        float x = base_x + sin(TIME * 0.15 + fi) * drift;
        float y = fract(phase_y + TIME * part_rise_speed);

        float d = length(uv - vec2(x, y));
        particles += smoothstep(size, 0.0, d) * 0.25;
    }
    col.rgb += particles * intensity * 0.2;

    vec4 orig = texture(SCREEN_TEXTURE, SCREEN_UV);
    col.rgb = mix(orig.rgb, col.rgb, intensity);

    COLOR = col;
}
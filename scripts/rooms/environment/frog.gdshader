shader_type canvas_item;

uniform float intensity = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float fog_thickness = 0.0;

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
    vec4 col = texture(SCREEN_TEXTURE, uv);

    // 淡绿灰色背景
    float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    vec3 base_color = mix(vec3(gray), vec3(0.75, 0.8, 0.7), 0.25);
    col.rgb = mix(col.rgb, base_color, 0.6 * intensity);

    // 雾气厚度因子
    float thick = clamp(fog_thickness * intensity, 0.0, 1.0);

    // 氤氲雾气飘动
    vec2 fog_uv = uv * 4.0 + vec2(TIME * 0.12, TIME * 0.08);
    float fog_density = fbm(fog_uv) * 0.8 + fbm(fog_uv * 1.7 + 0.5) * 0.5;
    fog_density += noise(uv * 20.0 + TIME * 0.2) * 0.2;
    fog_density = clamp(fog_density, 0.0, 1.0);

    // 边缘更浓
    float edge_dist = max(abs(uv.x - 0.5), abs(uv.y - 0.5)) * 2.0;
    float edge_fog = smoothstep(0.1, 0.8, edge_dist);
    fog_density = mix(fog_density, 1.0, edge_fog * 0.5);

    // 雾气浓度：整体进一步提升，确保最终几乎遮住画面
    float fog_alpha = clamp(fog_density * thick * 1.25, 0.0, 1.0);

    // 雾气颜色：白偏灰
    vec3 fog_color = vec3(0.82, 0.82, 0.78);

    col.rgb = mix(col.rgb, fog_color, fog_alpha);

    // 漂浮微粒
    float particles = 0.0;
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        vec2 seed = vec2(fi * 0.37, fi * 1.73);
        float x = hash(seed + vec2(TIME * 0.04)) * 0.9 + 0.05;
        float y = fract(hash(seed + vec2(TIME * 0.02)) + TIME * 0.015);
        float size = 0.003 + hash(seed) * 0.005;
        float d = length(uv - vec2(x, y));
        particles += smoothstep(size, 0.0, d) * 0.15;
    }
    col.rgb += fog_color * particles * thick;

    vec4 orig = texture(SCREEN_TEXTURE, SCREEN_UV);
    col.rgb = mix(orig.rgb, col.rgb, intensity);

    COLOR = col;
}
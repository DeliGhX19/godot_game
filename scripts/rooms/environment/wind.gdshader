shader_type canvas_item;

uniform float intensity = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float wind_angle = 0.0;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // 轻微晃动，叠加风向偏移
    float shake_x = sin(TIME * 5.0) * 0.002 * intensity;
    float shake_y = cos(TIME * 4.3) * 0.001 * intensity;
    shake_x += cos(wind_angle) * 0.003 * intensity;
    shake_y += sin(wind_angle) * 0.003 * intensity;
    uv += vec2(shake_x, shake_y) + hash(uv * 10.0 + TIME) * 0.0008 * intensity;

    vec4 col = texture(SCREEN_TEXTURE, uv);

    // 风沙色调：偏黄灰
    col.rgb = mix(col.rgb, col.rgb * vec3(0.9, 0.85, 0.7), intensity * 0.35);

    // 灰尘粒子
    float dust = 0.0;
    vec2 wind_dir = vec2(cos(wind_angle), sin(wind_angle));
    float wind_speed = 1.4;
    float trail_length = 0.015;

    for (int i = 0; i < 22; i++) {
        float fi = float(i);
        vec2 seed = vec2(fi * 0.37, fi * 1.73);

        // 随机起始位置（屏幕内）
        vec2 start_pos = vec2(hash(seed) * 0.9 + 0.05,
                              hash(seed + vec2(0.1, 0.2)) * 0.9 + 0.05);
        // 随机速度因子
        float speed_factor = 0.8 + hash(seed + vec2(0.3, 0.4)) * 0.4;
        // 随机相位偏移
        float phase = hash(seed + vec2(0.5, 0.6));

        // 粒子沿风向循环移动，移动距离设为1.2屏尺寸，保证不断流
        float t = fract(phase + TIME * wind_speed * speed_factor);
        vec2 pos = start_pos + wind_dir * t * 1.2;

        // 让粒子在屏幕内循环，当超出后再从对面出现
        pos.x = mod(pos.x, 1.0);
        pos.y = mod(pos.y, 1.0);

        float size = 0.002 + hash(seed + vec2(0.7, 0.8)) * 0.005;
        float brightness = hash(seed + vec2(0.9, 1.0)) * 0.5 + 0.5;

        float d = length(uv - pos);
        dust += brightness * smoothstep(size, 0.0, d) * 1.2;

        // 拖尾：沿风向反方向延伸
        for (int t_idx = 1; t_idx <= 3; t_idx++) {
            float tail = float(t_idx) * 0.003;
            vec2 tail_pos = pos - wind_dir * tail;
            float tail_d = length(uv - tail_pos);
            dust += brightness * 0.4 * smoothstep(size * 0.9, 0.0, tail_d);
        }
    }

    col.rgb += dust * intensity * 0.6;

    // 暗角
    float vignette = 1.0 - distance(uv, vec2(0.5)) * 1.0 * intensity;
    col.rgb *= clamp(vignette, 0.6, 1.0);

    vec4 orig = texture(SCREEN_TEXTURE, SCREEN_UV);
    col.rgb = mix(orig.rgb, col.rgb, intensity);

    COLOR = col;
}
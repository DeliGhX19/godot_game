shader_type canvas_item;

uniform float intensity = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 col = texture(SCREEN_TEXTURE, uv);

    float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    col.rgb = mix(col.rgb, vec3(gray), 0.75 * intensity);

    vec3 purple = vec3(0.55, 0.35, 0.75);
    float lines = 0.0;
    float fall_speed = 0.5;

    for (int i = 0; i < 16; i++) {
        float fi = float(i);
        vec2 seed = vec2(fi * 0.37, fi * 1.73);

        // 每次循环随机换新种子（基于当前时间与竖纹索引）
        float clock_f = floor(TIME * fall_speed + hash(seed + vec2(fi * 0.13, 0.0)) * 10.0);
        vec2 life_seed = vec2(fi, clock_f);

        float x = hash(life_seed + vec2(0.0, 0.1)) * 0.92 + 0.04;
        float height = 0.04 + hash(life_seed + vec2(0.2, 0.3)) * 0.08;
        float thickness = 0.0008 + hash(life_seed + vec2(0.4, 0.5)) * 0.0018;

        // 竖纹从屏幕顶部出现，向下移动
        float start_y = -height * 0.5;
        float end_y = 1.0 + height * 0.5;

        // 生命进度（一个竖纹走完整个屏幕为一个生命周期）
        float life_duration = (end_y - start_y) / fall_speed;
        float life_progress = fract(hash(life_seed + vec2(0.6, 0.7)) + TIME / life_duration);

        float cur_y = start_y + life_progress * (end_y - start_y);

        float wavy = sin(life_progress * 14.0 + fi * 3.0) * 0.15;
        float cur_thick = thickness * (1.0 + wavy);

        float in_x = smoothstep(cur_thick, 0.0, abs(uv.x - x));
        float edge = 0.001;
        float half_h = height * 0.5;
        float in_y = smoothstep(cur_y - half_h - edge, cur_y - half_h, uv.y) *
                     (1.0 - smoothstep(cur_y + half_h, cur_y + half_h + edge, uv.y));

        lines += in_x * in_y * 0.5;
    }

    col.rgb += purple * lines * intensity;

    vec4 orig = texture(SCREEN_TEXTURE, SCREEN_UV);
    col.rgb = mix(orig.rgb, col.rgb, intensity);

    COLOR = col;
}
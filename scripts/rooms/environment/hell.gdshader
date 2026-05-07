shader_type canvas_item;

uniform float intensity = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 col = texture(SCREEN_TEXTURE, uv);

    // 去色保留红通道
    float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    vec3 high_contrast = mix(vec3(gray), col.rgb, 0.2);
    high_contrast *= vec3(1.5, 0.3, 0.3);

    // 高对比度，拉大黑白差
    high_contrast = (high_contrast - 0.5) * 2.8 + 0.5;
    high_contrast = clamp(high_contrast, 0.0, 1.0);

    // 心跳脉冲
    float pulse = sin(TIME * 8.0) * 0.08 + sin(TIME * 1.7) * 0.04;
    high_contrast *= 1.0 + pulse;

    // 暗角压暗红色
    float dist = max(abs(uv.x - 0.5), abs(uv.y - 0.5)) * 2.0;
    float vignette = smoothstep(0.4, 1.0, dist);
    high_contrast = mix(high_contrast, vec3(0.1, 0.0, 0.0), vignette * 0.8);

    col.rgb = mix(col.rgb, high_contrast, intensity);

    vec4 orig = texture(SCREEN_TEXTURE, SCREEN_UV);
    col.rgb = mix(orig.rgb, col.rgb, intensity);

    COLOR = col;
}

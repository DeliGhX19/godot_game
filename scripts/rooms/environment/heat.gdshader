shader_type canvas_item;

uniform float intensity = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// 噪声函数
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// 值噪声
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

// 分形布朗运动
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    for (int i = 0; i < 3; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // 垂直衰减
    float falloff = pow(uv.y, 1.5);
    vec2 base = vec2(uv.x * 6.0, uv.y * 5.0 + TIME * 0.8);
    
    // 生成扭曲场
    float distort_x = fbm(base) * 2.0 - 1.0; 
    float distort_y = fbm(base + vec2(0.5, 0.3)) * 2.0 - 1.0;
    
    // 扭曲强度
    float strength = 0.006 * intensity * falloff;
    vec2 offset = vec2(distort_x, distort_y - 0.5) * strength;
    
    // 叠加高频细微抖动
    float detail = fbm(base * 3.0 + vec2(TIME * 0.3, 0.0));
    offset += vec2(detail - 0.5, (detail - 0.5) * 0.5) * strength * 0.5;
    vec2 distorted_uv = uv + offset;
    
    // 采样屏幕
    vec4 col = texture(SCREEN_TEXTURE, distorted_uv);
    
    // 色调、对比度、暗角
    col.rgb *= vec3(1.25, 0.9, 0.7);
    col.rgb = mix(col.rgb, col.rgb * 1.15, intensity * 0.5);
    col.rgb = (col.rgb - 0.5) * (1.0 + 0.2 * intensity) + 0.5;
    
    float vignette = 1.0 - abs(uv.y - 0.5) * 1.6 * intensity;
    col.rgb *= clamp(vignette, 0.4, 1.0);
    
    // 热浪底部微微增亮
    col.rgb += vec3(0.1, 0.03, 0.0) * falloff * intensity * 0.3;
    
    vec4 orig = texture(SCREEN_TEXTURE, SCREEN_UV);
    col.rgb = mix(orig.rgb, col.rgb, intensity);
    
    COLOR = col;
}
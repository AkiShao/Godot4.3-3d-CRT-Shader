shader_type spatial;
render_mode unshaded;

uniform sampler2D TEXTURE;

uniform float curve_intensity = 1.06;// 弯曲强度，越大弯曲越严重
uniform float scan_line_num = 250.0;// 扫描线条数，数字越大条数越多
uniform float dark = -2.0;// 扫描线暗部亮度，越低暗部越黑
uniform float light_intensity = 1.2;// 光强
uniform float filter_intensity = 0.02;// 滤镜强度

// 模拟电视画面弯曲
vec2 curve(vec2 uv)
{
	uv = (uv - 0.5) * 2.0;
	uv *= curve_intensity;
	uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
	uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
	uv  = (uv / 2.0) + 0.5;
	uv =  uv *0.92 + 0.04;
	return uv;
}

void vertex(){
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {


	vec2 uv = curve(UV);

	// 颜色采样
	vec3 col;
	col.r = texture(TEXTURE, vec2(uv.x + 0.0005, uv.y + 0.0005)).r;
	col.g = texture(TEXTURE, vec2(uv.x + 0.0000, uv.y - 0.0020)).g;
	col.b = texture(TEXTURE, vec2(uv.x - 0.0020, uv.y + 0.0000)).b;

	// 扫描线效果增强
	float scan_lines = sin(scan_line_num * uv.y);
	float scan_strength = clamp(0.5 + 0.5 * scan_lines, 0.0, 1.0); // 扫描线权重

	vec3 darkened_col = col * dark;
	col = mix(darkened_col, col, scan_strength);


    // 画面整体亮度校正
	col *= light_intensity;

	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		col = vec3(0.0);
    }


	vec4 CRT = vec4(col,filter_intensity);
	vec3 color = CRT.rgb;

	ALBEDO = color;
	ALPHA = CRT.a;
}

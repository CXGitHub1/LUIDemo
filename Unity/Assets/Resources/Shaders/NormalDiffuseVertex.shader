Shader "Xcqy/LegacyShadersDiffuseVertex" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
    _Speed ("Wave Speed", Range(0.1, 80)) = 5
    _Frequency ("Wave Frequency", Range(0, 5)) = 2
    _Amplitude ("Wave Amplitude", Range(-1, 1)) = 0.02
}
SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 200

CGPROGRAM
#pragma surface surf Lambert vertex:vert

sampler2D _MainTex;
fixed4 _Color;
float _Speed;
float _Frequency;
float _Amplitude;

struct Input {
	float2 uv_MainTex;
    float3 vertColor;
};

void vert(inout appdata_full v, out Input o)
{
    float time = _Time * _Speed;
    //float waveValueA = sin(time + v.vertex.y * _Frequency) * _Amplitude * (1 - v.color.r);
    float waveValueA = sin(time + v.vertex.x * _Frequency) * _Amplitude * v.vertex.y;

    v.vertex.xyz = float3(v.vertex.x+waveValueA, v.vertex.y, v.vertex.z);
    o.vertColor = v.color;
    o.uv_MainTex = v.vertex;
}

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = c.rgb;
	o.Alpha = c.a;
}
ENDCG
}

Fallback "Legacy Shaders/VertexLit"
}

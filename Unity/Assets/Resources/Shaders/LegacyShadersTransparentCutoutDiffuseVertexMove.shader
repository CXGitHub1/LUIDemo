Shader "Xcqy/LegacyShadersTransparentCutoutDiffuseVertexMove" {
Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
    _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    _Speed ("Wave Speed", Range(0.1, 80)) = 15
    _Frequency ("Wave Frequency", Range(0, 5)) = 5
    _Amplitude ("Wave Amplitude", Range(-1, 1)) = 0.05
}

SubShader {
    Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
    LOD 200
    Cull Off

CGPROGRAM
#pragma surface surf Lambert alphatest:_Cutoff vertex:vert

sampler2D _MainTex;
fixed4 _Color;
float _Speed;
float _Frequency;
float _Amplitude;

struct Input {
    float2 uv_MainTex;
    float3 vertColor;
};

void vert(inout appdata_full v, out Input o) {
    float time = _Time * _Speed;
    float wavex = sin(time + v.vertex.y * _Frequency) * _Amplitude * v.color.g;
    float wavey = sin(time + v.vertex.y * _Frequency) * _Amplitude * v.color.b;
    v.vertex.xyz = float3(v.vertex.x + wavex, v.vertex.y + wavey, v.vertex.z);
    o.vertColor = v.color;
    o.uv_MainTex = v.vertex;
}

void surf (Input IN, inout SurfaceOutput o) {
    fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
    o.Albedo = c.rgb;
    //o.Albedo = IN.vertColor;
    o.Alpha = c.a;
}
ENDCG
}

Fallback "Legacy Shaders/Transparent/Cutout/VertexLit"
}

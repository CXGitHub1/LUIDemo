Shader "Xcqy/UnlitTextureXY" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
	}
	SubShader {
		Tags {"RenderType"="Opaque"}
		LOD 200
	
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;
		fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			//o.Albedo = tex.rgb;
			o.Albedo = tex.rgb * _Color;
			o.Emission = tex.rgb * 0.9;
			o.Alpha = tex.a;
		}
		ENDCG
	} 

    FallBack "Diffuse"
}

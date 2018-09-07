// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//边缘发光Shader UnlitTexture的基础上修改
Shader "Xcqy/RimLightUnlitTexture" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
    _RimColor("RimColor", Color) = (1,1,1,1)  
    _RimPower("RimPower", Range(0.000001, 3.0)) = 3.0
}

SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 100
	
	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;  
                float3 worldViewDir : TEXCOORD2;  
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
            fixed4 _RimColor;  
            float _RimPower;  
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);  
                //顶点转化到世界空间  
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
                //可以把计算计算ViewDir的操作放在vertex shader阶段，毕竟逐顶点计算比较省  
                o.worldViewDir = _WorldSpaceCameraPos.xyz - worldPos;  
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                fixed3 worldNormal = normalize(i.worldNormal);  
                float3 worldViewDir = normalize(i.worldViewDir);  
                float rim = 1 - max(0, dot(worldViewDir, worldNormal));  
                fixed3 rimColor = _RimColor * pow(rim, 1 / _RimPower);  
				fixed4 color = tex2D(_MainTex, i.texcoord);
                color.rgb = color.rgb + rimColor;  
				return fixed4(color);
			}
		ENDCG
	}
}

}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Xcqy/UnlitTextureOcclusion" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
    _RimColor("RimColor",Color) = (0.05, 0.2, 0.4, 1)  
    _RimPower ("Rim Power", Range(0.1,8.0)) = 0.23

}

SubShader {
	Tags {"Queue" = "Geometry-50" "RenderType"="Opaque"}
	LOD 300

    Pass  
        {  
            Blend SrcAlpha One  
            ZWrite off  
            Lighting off  
  
            ztest greater  
  
            CGPROGRAM  
            #pragma vertex vert  
            #pragma fragment frag  
            #include "UnityCG.cginc"  
  
            float4 _RimColor;  
            float _RimPower;  
              
            struct appdata_t {  
                float4 vertex : POSITION;  
                float2 texcoord : TEXCOORD0;  
                float4 color:COLOR;  
                float4 normal:NORMAL;  
            };  
  
            struct v2f {  
                float4  pos : SV_POSITION;  
                float4  color:COLOR;  
            } ;  
            v2f vert (appdata_t v)  
            {  
                v2f o;  
                o.pos = UnityObjectToClipPos(v.vertex);  
                float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));  
                float rim = 1 - saturate(dot(viewDir,v.normal ));  
                o.color = _RimColor*pow(rim,_RimPower);  
                return o;  
            }  
            float4 frag (v2f i) : COLOR  
            {  
                return i.color;   
            }  
            ENDCG  
    }

	
	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.texcoord);
				return col;
			}
		ENDCG
	}

    }

}

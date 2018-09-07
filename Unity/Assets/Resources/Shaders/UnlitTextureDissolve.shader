// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 不受光材质消融效果
Shader "Xcqy/UnlitTextureDissolve" {
Properties {
	_BurnAmount ("Burn Amount", Range(0.0, 1.0)) = 0.0
	_LineWidth("Burn Line Width", Range(0.0, 0.2)) = 0.1
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_BurnFirstColor("Burn First Color", Color) = (1, 0, 0, 1)
	_BurnSecondColor("Burn Second Color", Color) = (1, 0, 0, 1)
	_BurnMap("Burn Map", 2D) = "white"{}
}

SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 100
	
	Pass {  
		Tags { "LightMode"="ForwardBase" }
		Cull Off
		CGPROGRAM

	    #pragma vertex vert
	    #pragma fragment frag
	    
	    #include "UnityCG.cginc"

		fixed _BurnAmount;
		fixed _LineWidth;
		sampler2D _MainTex;
		fixed4 _BurnFirstColor;
		fixed4 _BurnSecondColor;
		sampler2D _BurnMap;

		float4 _MainTex_ST;
		float4 _BurnMap_ST;

		struct a2v {
			float4 vertex : POSITION;
			float4 texcoord : TEXCOORD0;
		};
		
		struct v2f {
			float4 pos : SV_POSITION;
			float2 uvMainTex : TEXCOORD0;
			float2 uvBurnMap : TEXCOORD2;
		};

	    
	    v2f vert (a2v v)
	    {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uvMainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);
			return o;
	    }

		fixed4 frag(v2f i) : SV_Target {
			fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
            fixed4 color = tex2D(_MainTex, i.uvMainTex);
			clip(burn.r - _BurnAmount);
			fixed t = 1 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount);
			fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);
			burnColor = pow(burnColor, 5);
			fixed3 finalColor = lerp(color, burnColor, t * step(0.0001, _BurnAmount));
			return fixed4(finalColor, 1);
		}
		ENDCG
	}
}

}

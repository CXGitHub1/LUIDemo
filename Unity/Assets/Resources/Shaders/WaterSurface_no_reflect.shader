// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: 去掉GramaaSpace判断

Shader "Custom/WaterSurface_no_reflect"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_RefractTex ("Refract Texture", 2D) = "white" {}
		//_ReflectTex("Reflect Texture", 2D) = "white"{}
		_BumpTex ("Bump Texture", 2D) = "white"{}
		_BumpStrength ("Bump strength", Range(0.0, 10.0)) = 1.0
		_BumpDirection ("Bump direction(2 wave)", Vector)=(1,1,1,-1)
		_BumpTiling ("Bump tiling", Vector)=(0.0625,0.0625,0.0625,0.0625)
		_FresnelTex("Fresnel Texture", 2D) = "white" {}
		_Skybox("skybox", Cube)="white"{}
		_Specular("Specular Color", Color)=(1,1,1,0.5)
		_Params("shiness,Refract Perturb,Reflect Perturb", Vector)=(128, 0.025, 0.05, 0)
		_SunDir("sun direction", Vector)=(0,0,0,0)
	}
	SubShader
	{
		Tags {"Queue"="Transparent-1" "RenderType"="Transparent" "LightMode"="ForwardBase"}
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 100

		Pass
		{
			offset 1,1
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase


			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv:TEXCOORD0;
				//float3 normal:NORMAL;
				//float3 tangent:TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 bumpCoords:TEXCOORD1;
				float3 viewVector:TEXCOORD2;

				float4 vertex : SV_POSITION;
			};
			float4 _Color;
			sampler2D _RefractTex;
			sampler2D _BumpTex;
			half _BumpStrength;
			float4 _BumpDirection;
			float4 _BumpTiling;
			sampler2D _FresnelTex;
			samplerCUBE _Skybox;
			float4 _Specular;
			float4 _Params;
			float4 _SunDir;

			float3 PerPixelNormal(sampler2D bumpMap, float4 coords, half bumpStrength)
			{
				float2 bump = (UnpackNormal(tex2D(bumpMap, coords.xy)) + UnpackNormal(tex2D(bumpMap, coords.zw))) * 0.5;
				//bump += (UnpackNormal(tex2D(bumpMap, coords.xy*2))*0.5 + UnpackNormal(tex2D(bumpMap, coords.zw*2))*0.5) * 0.5;
				//bump += (UnpackNormal(tex2D(bumpMap, coords.xy*8))*0.5 + UnpackNormal(tex2D(bumpMap, coords.zw*8))*0.5) * 0.5;
				float3 worldNormal = float3(0,0,0);
				worldNormal.xz = bump.xy * bumpStrength;
				worldNormal.y = 1;
				return worldNormal;
			}

			inline float FastFresnel(float3 I, float3 N, half R0)
			{
				float icosIN = saturate(1-dot(I, N));
				float i2 = icosIN*icosIN;
				float i4 = i2*i2;
				return R0 + (1-R0)*(i4*icosIN);
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float4 screenPos = ComputeScreenPos(o.vertex);
				o.uv.xy = v.uv;
				o.bumpCoords.xyzw = (worldPos.xzxz + _Time.yyyy * _BumpDirection.xyzw) * _BumpTiling.xyzw;
				o.viewVector = (worldPos - _WorldSpaceCameraPos.xyz);
				return o;
			}
			sampler2D_float _CameraDepthTexture;
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 result = fixed4(0,0,0,1);
				float3 worldNormal = normalize(PerPixelNormal(_BumpTex, i.bumpCoords, _BumpStrength));
				float3 viewVector = normalize(i.viewVector);
				float3 halfVector = normalize((normalize(_SunDir.xyz)-viewVector));

				float2 offsets = worldNormal.xz*viewVector.y;
				float4 refractColor = tex2D(_RefractTex, i.uv.xy+offsets*_Params.y)*_Color;
				//
				float3 reflUV = reflect( viewVector, worldNormal);
				float3 reflectColor = texCUBE(_Skybox, reflUV);
				//
				float2 fresnelUV = float2( saturate(dot(-viewVector, worldNormal)), 0.5);
				half fresnel = tex2D(_FresnelTex, fresnelUV).r;
				//
//				if(IsGammaSpace())
//				{
//					fresnel = pow(fresnel, 2.2);
//				}
				//fresnel = FastFresnel(-viewVector, worldNormal, 0.02);

				result.xyz = lerp(refractColor.xyz, reflectColor.xyz, fresnel);
				//spec
				float3 specularColor = _Specular.w*pow(max(0, dot(worldNormal, halfVector)), _Params.x);
				result.xyz += _Specular.xyz*specularColor;
				result.a *= refractColor.a;
				return result;
			}
			ENDCG
		}
	}
//	FallBack "Diffuse"
}

Shader "Xcqy/ModelIllumination" {
	Properties {
		 _IlluminCol ("Self-Illumination color (RGB)", Color) = (0.64,0.64,0.64,1)
		 _MainTex ("Particle Texture", 2D) = "white" {}
	}

	SubShader { 
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Pass {
			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
			Blend SrcAlpha One

			Material {
				Ambient (1,1,1,1)
				Diffuse (1,1,1,1)
			}

			SetTexture [_MainTex] { ConstantColor [_IlluminCol] combine constant * texture }
			SetTexture [_MainTex] { combine previous + texture }
			SetTexture [_MainTex] { ConstantColor [_IlluminCol] combine previous * constant }
		}
	}
}
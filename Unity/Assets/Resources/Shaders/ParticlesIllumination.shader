Shader "Xcqy/ParticlesIllumination" {
	Properties {
		 _MainTex ("Particle Texture", 2D) = "white" {}
	}

	SubShader { 
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Pass {
			Blend SrcAlpha One
			SetTexture [_MainTex] { combine texture * primary }
		}
	}
}
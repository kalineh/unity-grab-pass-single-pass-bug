Shader "GrabPassInvertSP4"
{
    SubShader
    {
        // Draw ourselves after all opaque geometry
        Tags { "Queue" = "Transparent" }

        // Grab the screen behind the object into _BackgroundTexture
        GrabPass
        {
            "_BackgroundTexture"
        }

        // Render the object with the texture generated above, and invert the colors
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			half4 _BackgroundTexture_ST;


            struct v2f
            {
                float4 grabPos : TEXCOORD0;
                float4 pos : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert(appdata_base v) {
                v2f o;
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;
            }

            sampler2D _BackgroundTexture;

            half4 frag(v2f i) : SV_Target
            {
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

				half2 grabUV = UNITY_PROJ_COORD(i.grabPos.xy / i.grabPos.w);

				//grabUV = UnityStereoScreenSpaceUVAdjust(grabUV, _BackgroundTexture_ST);

#if UNITY_SINGLE_PASS_STEREO

				float4 scaleOffset = unity_StereoScaleOffset[unity_StereoEyeIndex];

				grabUV = (grabUV - scaleOffset.zw) / scaleOffset.xy;

				grabUV.x += 0.06 * unity_StereoEyeIndex;

				grabUV.x = step(grabUV.x, 0.5);
				grabUV.y = step(grabUV.y, 0.5);

#endif

				return half4(grabUV.x, grabUV.y, 0, 1);
            }
            ENDCG
        }

    }
}
Shader "Loki/Loki Toon"
{
    Properties
    {
        _mainTexture("Main Texture", 2D) = "white" {} //All the necessary properties for the shader
        _rampTexture ("Ramp Texture", 2D) = "white" {}
        _rimColour("Rim Colour", Color) = (1,1,1,1)
        _rimPower("Rim Power", Range(0, 8)) = 3
        _rimEmission("Rim Emission", Range(0, 10)) = 0
        _mainColor("Main Color", Color) = (1,1,1,1)
        _mainEmission("Main Emission", Color) = (1,1,1,1)
        _emissionStrength("Emission Strength", Range(0, 10)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma multi_compile _ CEL_SHADING


        struct Input
        {
            float2 uv_mainTexture;
            float3 viewDir; //Gets the view direction for the light calculations
        };

        sampler2D _mainTexture; //Initializes the variables
        sampler2D _rampTexture;
        fixed4 _mainColor;
        fixed4 _mainEmission;
        float _emissionStrength;
        float4 _rimColour;
        float _rimPower;
        float _rimEmission;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float4 c = tex2D(_mainTexture, IN.uv_mainTexture);
            o.Albedo = c.rgb*_mainColor.rgb;
            half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal)); //Calculates the rim lighting
            o.Emission = _mainEmission.rgb * _emissionStrength;
            o.Emission += _rimColour.rgb * pow(rim, 8 - _rimPower) * _rimEmission; //Adds the rim lighting to the emission
            float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); //Gets the light direction
            float NdotL = dot(o.Normal, lightDir); //Calculates the dot product of the normal and light direction
            float ramp = tex2D(_rampTexture, float2(NdotL, 0.5)).r; //Gets the ramp value from the ramp texture
            o.Albedo *= ramp; //Multiplies the albedo by the ramp value, giving the toon effect
        }

        ENDCG
    }
}
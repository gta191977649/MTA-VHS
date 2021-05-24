//-- Declare the textures. These are set using dxSetShaderValue( shader, "Tex0", texture )
texture Tex0;
texture Tex1;

//-- Declare a user variable. This can be set using dxSetShaderValue( shader, "PositionOfCheese", 1, 2, 3 )
float3 PositionOfCheese;

//-- These variables are set automatically by MTA
float4x4 World;
float4x4 View;
float4x4 Projection;
float4x4 WorldViewProjection;
float Time;


//---------------------------------------------------------------------
//-- Sampler for the main texture (needed for pixel shaders)
//---------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (Tex0);
};


//---------------------------------------------------------------------
//-- Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
    float3 Position : POSITION;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
//-- Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse  : COLOR0;
  float2 TexCoord : TEXCOORD0;
};

float random(float2 co)
{
    float a = 12.9898;
    float b = 78.233;
    float c = 33758.5453;
    float dt= dot(co.xy ,float2(a,b));
    float sn= fmod(dt,3.14);
    return frac(sin(sn) * c);
}


//-----------------------------------------------------------------------------
//-- VertexShaderExample
//--  1. Read from VS structure
//--  2. Process
//--  3. Write to PS structure
//-----------------------------------------------------------------------------
PSInput VertexShaderExample(VSInput VS)
{
    PSInput PS = (PSInput)0;

    //-- Transform vertex position (You nearly always have to do something like this)
    PS.Position = mul(float4(VS.Position, 1), WorldViewProjection);

    //-- Copy the color and texture coords so the pixel shader can use them
    PS.Diffuse = VS.Diffuse;
    PS.TexCoord = VS.TexCoord;

    return PS;
}


//-----------------------------------------------------------------------------
//-- PixelShaderExample
//--  1. Read from PS structure
//--  2. Process
//--  3. Return pixel color
//-----------------------------------------------------------------------------
float4 PixelShaderExample(PSInput PS) : COLOR0
{
    float2 uv = PS.TexCoord.xy ;
    float magnitude = 0.000003;


    // Set up offset
	float2 offsetRedUV = uv;
	//offsetRedUV.x = uv.x + random(float2(Time*0.03,uv.y*0.42)) * 0.001;
	offsetRedUV.x += sin(random(float2(Time*0.2, uv.y)))*magnitude;

    float2 offsetGreenUV = uv;
	offsetGreenUV.x = uv.x + random(float2(Time*0.004,uv.y*0.002)) * 0.0025;
	offsetGreenUV.x += sin(Time*0.03)*magnitude;

    float2 offsetBlueUV = uv;
	offsetBlueUV.x = uv.y;
	offsetBlueUV.x += random(float2(cos(Time*0.03),sin(uv.y)));

    // Load Texture
    float r = tex2D(Sampler0, offsetRedUV).r;
	float g = tex2D(Sampler0, offsetGreenUV).g;
	float b = tex2D(Sampler0, uv).b;
	
	//fragColor = vec4(r,g,b,0);
    float4 finalColor = float4(r,g,b,1) * PS.Diffuse;

    /*

    //-- Modify the texture coord to make the image look all wobbly
    PS.TexCoord.y += sin(PS.TexCoord.y * 100 + Time * 10) * 0.03;

    //-- Grab the pixel from the texture
    float4 finalColor = tex2D(Sampler0, PS.TexCoord);

    //-- Apply color tint
    finalColor = finalColor * PS.Diffuse;
    */
    return finalColor;
}


//-----------------------------------------------------------------------------
//-- Techniques
//-----------------------------------------------------------------------------

//--
//-- MTA will try this technique first:
//--
technique complercated
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderExample();
        PixelShader  = compile ps_2_0 PixelShaderExample();
    }
}

//--
//-- And if the preceding technique will not validate on
//-- the players computer, MTA will try this one:
//--
technique simple
{
    pass P0
    {
        //-- Set up texture stage 0
        Texture[0] = Tex0;
        ColorOp[0] = SelectArg1;
        ColorArg1[0] = Texture;
        AlphaOp[0] = SelectArg1;
        AlphaArg1[0] = Texture;
            
        //-- Disable texture stage 1
        ColorOp[1] = Disable;
        AlphaOp[1] = Disable;
    }
}
/*

highp float rand(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
	// Flip Y Axis
	//uv.y = -uv.y; This was causing issues
	
	highp float magnitude = 0.000003;
	
	
	// Set up offset
	vec2 offsetRedUV = uv;
	offsetRedUV.x = uv.x + rand(vec2(iTime*0.03,uv.y*0.42)) * 0.001;
	offsetRedUV.x += sin(rand(vec2(iTime*0.2, uv.y)))*magnitude;
	
	vec2 offsetGreenUV = uv;
	offsetGreenUV.x = uv.x + rand(vec2(iTime*0.004,uv.y*0.002)) * 0.004;
	offsetGreenUV.x += sin(iTime*9.0)*magnitude;
	
	vec2 offsetBlueUV = uv;
	offsetBlueUV.x = uv.y;
	offsetBlueUV.x += rand(vec2(cos(iTime*0.01),sin(uv.y)));
	
	// Load Texture
	float r = texture(iChannel0, offsetRedUV).r;
	float g = texture(iChannel0, offsetGreenUV).g;
	float b = texture(iChannel0, uv).b;
	
	fragColor = vec4(r,g,b,0);
	
}

*/
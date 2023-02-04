// texture coordinates that are set in the vertex shader
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D input_tex; 

void main()
{
	lowp vec4 input_col = texture2D(input_tex, var_texcoord0.xy);
	gl_FragColor = input_col;
}
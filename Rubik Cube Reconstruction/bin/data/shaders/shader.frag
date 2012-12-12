#version 330

in vec2 texCoord;
smooth in vec3 vNormal;
out vec4 outputColor;

uniform sampler2D gSampler;
uniform vec4 vColor;
uniform int PureColor;

void main()
{
  if(PureColor == 1)outputColor = vColor;
  else
  {
  	vec4 vTexColor = texture2D(gSampler, texCoord);
  	outputColor = vTexColor*vColor;
	}
}
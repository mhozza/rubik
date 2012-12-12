#version 330

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 normalMatrix;

layout (location = 0) in vec3 inPosition;
layout (location = 1) in vec2 inCoord;
layout (location = 2) in vec3 inNormal;

out vec2 texCoord;

smooth out vec3 vNormal;

uniform float texCoordRotAngle;

void main()
{
	gl_Position = projectionMatrix*modelViewMatrix*vec4(inPosition, 1.0);
  vec2 vMid = vec2(0.5, 0.5);
  vec2 vInCopy = inCoord;
  vec2 vDir = vInCopy-vMid;
  vec2 vRotated;
  vRotated.x = cos(texCoordRotAngle)*vDir.x - sin(texCoordRotAngle)*vDir.y;
  vRotated.y = cos(texCoordRotAngle)*vDir.y + sin(texCoordRotAngle)*vDir.x; 
  
  vRotated.x = vRotated.x-vRotated.x*abs(sin(texCoordRotAngle))*0.35;
  vRotated.y = vRotated.y-vRotated.y*abs(sin(texCoordRotAngle))*0.35;
	texCoord = vMid+vRotated;
	vec4 vRes = normalMatrix*vec4(inNormal, 0.0);
	vNormal = vRes.xyz;
}
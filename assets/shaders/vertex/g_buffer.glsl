# version 330 core

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inColor;
layout(location = 2) in vec3 inNormal;
layout(location = 3) in vec3 inUV;

uniform mat4 projection, view, model;
uniform int hasTexture;
uniform vec3 cameraPos;

out vec3 outPosition, outColor, outNormal, outUV;
out vec3 outFragPos, outViewPos, outCameraPos;
flat out int outHasTexture;

void main() {
  // projection * view * model * position
  outPosition = inPosition;
  outColor = inColor;
  outNormal= normalize(transpose(inverse(mat3(model))) * inNormal);
  outUV    = inUV;
  outHasTexture = hasTexture;
  outCameraPos = cameraPos;

  outFragPos = vec3(model * vec4(inPosition, 1.0));

  gl_Position = projection * view * model * vec4(inPosition, 1.0);
}

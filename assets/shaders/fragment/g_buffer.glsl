# version 330 core

layout(location  = 0) out vec3 fragPosition;
layout (location = 1) out vec4 fragColor;
layout (location = 2) out vec3 fragNormal;
layout (location = 3) out vec3 fragUV;

in vec3 outPosition, outColor, outNormal, outUV, outFragPos, outCameraPos;
out vec4 outputFragColor;
flat in int outHasTexture;

uniform sampler2D diffuse_texture;

void main() {
  vec3 result;

  if (outHasTexture == 0) {
    result = outColor;
  } else {
    result = texture(diffuse_texture, outUV.xy).xyz + 0.25;
  }

  fragPosition = outPosition;
  fragColor = vec4(result, 1.0);
  fragNormal = outNormal;
  fragUV = outUV;

  float gamma = 2.2;
  outputFragColor.rgb = pow(fragColor.rgb, vec3(1.0 / gamma));
}

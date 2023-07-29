# version 330 core

layout(location  = 0) out vec3 fragPosition;
layout (location = 1) out vec4 fragColor;
layout (location = 2) out vec3 fragNormal;
layout (location = 3) out vec3 fragUV;

in vec3 out_position, out_color, out_normal, out_uv, out_frag_pos, out_camera_pos;
out vec4 outputFragColor;
flat in int out_has_texture;

uniform sampler2D diffuse_texture;

void main() {
  vec3 result;

  if (out_has_texture == 0) {
    result = out_color;
  } else {
    result = texture(diffuse_texture, out_uv.xy).xyz + 0.25;
  }

  fragPosition = out_position;
  fragColor = vec4(result, 1.0);
  fragNormal = out_normal;
  fragUV = out_uv;

  float gamma = 2.2;
  outputFragColor.rgb = pow(fragColor.rgb, vec3(1.0 / gamma));
}

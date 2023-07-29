#version 330 core
@include "light_struct"

layout (location = 0) in vec3 in_position;
layout (location = 1) in vec2 in_tex_coords;

uniform sampler2D diffuse, position, texcoord, normal, depth;
uniform int light_count;
uniform Light lights[7];

out vec2 out_tex_coords;
flat out int out_light_count;
flat out Light out_lights[7];

void main() {
  gl_Position = vec4(in_position.x, in_position.y, in_position.z, 1.0);
  out_tex_coords = in_tex_coords;
  out_light_count = light_count;

  for(int i = 0; i < light_count; i++)
  {
    out_lights[i] = lights[i];
  }
}

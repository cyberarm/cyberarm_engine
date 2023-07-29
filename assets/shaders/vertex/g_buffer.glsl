# version 330 core

layout(location = 0) in vec3 in_position;
layout(location = 1) in vec3 in_color;
layout(location = 2) in vec3 in_normal;
layout(location = 3) in vec3 in_uv;

uniform mat4 projection, view, model;
uniform int has_texture;
uniform vec3 camera_pos;

out vec3 out_position, out_color, out_normal, out_uv;
out vec3 out_frag_pos, out_view_pos, out_camera_pos;
flat out int out_has_texture;

void main() {
  // projection * view * model * position
  out_position = in_position;
  out_color = in_color;
  out_normal= normalize(transpose(inverse(mat3(model))) * in_normal);
  out_uv    = in_uv;
  out_has_texture = has_texture;
  out_camera_pos = camera_pos;

  out_frag_pos = vec3(model * vec4(in_position, 1.0));

  gl_Position = projection * view * model * vec4(in_position, 1.0);
}

#version 330 core
@include "light_struct"

out vec4 frag_color;

const int DIRECTIONAL = 0;
const int POINT = 1;
const int SPOT = 2;

in vec2 out_tex_coords;
flat in int out_light_count;
flat in Light out_lights[7];

uniform sampler2D diffuse, position, texcoord, normal, depth;

vec4 directionalLight(Light light) {
  vec3 norm = normalize(texture(normal, out_tex_coords).rgb);
  vec3 diffuse_color = texture(diffuse, out_tex_coords).rgb;
  vec3 frag_pos = texture(position, out_tex_coords).rgb;

  vec3 lightDir = normalize(light.position - frag_pos);
  float diff = max(dot(norm, lightDir), 0);

  vec3 _ambient = light.ambient;
  vec3 _diffuse = light.diffuse * diff;
  vec3 _specular = light.specular;

  return vec4(_diffuse + _ambient + _specular, 1.0);
}

void main() {
  Light light;
  light.type = DIRECTIONAL;

  light.position = vec3(100, 100, 100);

  light.diffuse = vec3(0.5, 0.5, 0.5);
  light.ambient = vec3(0.8, 0.8, 0.8);
  light.specular = vec3(0.2, 0.2, 0.2);

  light.intensity = 1.0;

  frag_color = texture(diffuse, out_tex_coords) * directionalLight(light);
}

// #version 330 core
// @include "light_struct"

// out vec4 frag_color;

// const int DIRECTIONAL = 0;
// const int POINT = 1;
// const int SPOT = 2;

// in vec2 out_tex_coords;
// flat in int out_light_count;
// flat in Light out_lights[7];

// uniform sampler2D diffuse, position, texcoord, normal, depth;

// vec4 directionalLight(Light light) {
//   vec3 norm = normalize(texture(normal, out_tex_coords).rgb);
//   vec3 diffuse_color = texture(diffuse, out_tex_coords).rgb;
//   vec3 frag_pos = texture(position, out_tex_coords).rgb;

//   vec3 lightDir = normalize(light.position - frag_pos);
//   float diff = max(dot(norm, lightDir), 0);

//   vec3 _ambient = light.ambient;
//   vec3 _diffuse = light.diffuse * diff;
//   vec3 _specular = light.specular;

//   return vec4(_diffuse + _ambient + _specular, 1.0);
// }

// vec4 pointLight(Light light) {
//   return vec4(0.25, 0.25, 0.25, 1);
// }

// vec4 spotLight(Light light) {
//   return vec4(0.5, 0.5, 0.5, 1);
// }

// vec4 calculateLighting(Light light) {
//   vec4 result;

//   // switch(light.type) {
//   //   case DIRECTIONAL: {
//   //     result = directionalLight(light);
//   //   }
//   //   case SPOT: {
//   //     result = spotLight(light);
//   //   }
//   //   default: {
//   //     result = pointLight(light);
//   //   }
//   // }

//   if (light.type == DIRECTIONAL) {
//     result = directionalLight(light);
//   } else {
//     result = pointLight(light);
//   }

//   return result;
// }

// void main() {
//   frag_color = vec4(0.0);

//   for(int i = 0; i < out_light_count; i++)
//   {
//     frag_color += texture(diffuse, out_tex_coords) * calculateLighting(out_lights[i]);
//   }
// }

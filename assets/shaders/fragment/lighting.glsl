#version 330 core
out vec4 FragColor;

@include "light_struct"
const int DIRECTIONAL = 0;
const int POINT = 1;
const int SPOT = 2;

in vec2 outTexCoords;
flat in Light outLight[1];

uniform sampler2D diffuse, position, texcoord, normal, depth;

vec4 directionalLight(Light light) {
  vec3 norm = normalize(texture(normal, outTexCoords).rgb);
  vec3 diffuse_color = texture(diffuse, outTexCoords).rgb;
  vec3 fragPos = texture(position, outTexCoords).rgb;

  vec3 lightDir = normalize(light.position - fragPos);
  float diff = max(dot(norm, lightDir), 0);

  vec3 _ambient = light.ambient;
  vec3 _diffuse = light.diffuse * diff;
  vec3 _specular = light.specular;

  return vec4(_diffuse + _ambient + _specular, 1.0);
}

vec4 pointLight(Light light) {
  return vec4(0.25, 0.25, 0.25, 1);
}

vec4 spotLight(Light light) {
  return vec4(0.5, 0.5, 0.5, 1);
}

vec4 calculateLighting(Light light) {
  vec4 result;

  // switch(light.type) {
  //   case DIRECTIONAL: {
  //     result = directionalLight(light);
  //   }
  //   case SPOT: {
  //     result = spotLight(light);
  //   }
  //   default: {
  //     result = pointLight(light);
  //   }
  // }

  if (light.type == DIRECTIONAL) {
    result = directionalLight(light);
  } else {
    result = pointLight(light);
  }

  return result;
}

void main() {
  FragColor = texture(diffuse, outTexCoords) * calculateLighting(outLight[0]);
}
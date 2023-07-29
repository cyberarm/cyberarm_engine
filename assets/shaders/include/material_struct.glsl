struct Material {
  vec3 color;
  vec3 roughness;
  vec3 metalic;
  vec3 specular;

  bool use_color_texture;
  bool use_roughness_texture;
  bool use_metalic_texture;
  bool use_specular_texture;

  sampler2D color_tex;
  sampler2D roughness_tex;
  sampler2D metalic_tex;
  sampler2D specular_tex;
};

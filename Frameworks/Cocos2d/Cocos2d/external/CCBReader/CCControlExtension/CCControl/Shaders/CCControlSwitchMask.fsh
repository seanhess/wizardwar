#ifdef GL_ES
precision lowp float;
#endif

varying vec4        v_fragmentColor;
varying vec2        v_texCoord;
uniform sampler2D   u_texture;
uniform sampler2D   u_mask;

void main()
{
    vec4 texColor   = texture2D(u_texture, v_texCoord);
    vec4 maskColor  = texture2D(u_mask, v_texCoord);
    vec4 finalColor = vec4(texColor.r, texColor.g, texColor.b, maskColor.a * texColor.a);
    gl_FragColor    = v_fragmentColor * finalColor;
}
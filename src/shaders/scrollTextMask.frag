#version 450
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float scrollOffset;
    float clipWidth;
    vec2 textureResolution;
};

layout(binding = 1) uniform sampler2D source;
void main() {
    vec2 uv = qt_TexCoord0;

    // Scroll source horizontally
    float scrolledX = mod(uv.x + scrollOffset, 1.0);
    vec2 scrolledUV = vec2(scrolledX, uv.y);

    vec4 color = texture(source, scrolledUV);

    float alphaFactor = 1.0;
    if (clipWidth > 0.0) {
        // normalize
        float cutoff = clipWidth / float(textureResolution.x);
        if (uv.x > cutoff)
            alphaFactor = 0.0;
    }

    fragColor = color * alphaFactor;
}

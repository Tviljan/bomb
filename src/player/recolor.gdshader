shader_type canvas_item;
render_mode blend_mix;

void fragment(){
    vec4 color = texture(TEXTURE, UV);
    // if the pixel has enough red
    if (color.r  > 0.0){
        // set its color to green
        color.g = 255.0;  // or color = vec4(0,255.0,0,color.a)
    }
    // otherwise
    else {
        // set its color to blue
        color.b = 255.0;  // or color = vec4(0,0,255.0,color.a)
    }
    COLOR = color;
}
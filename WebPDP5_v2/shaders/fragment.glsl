precision mediump float;
uniform float radius;
uniform float uTime;
uniform float zoom;
uniform sampler2D uTexture;


uniform vec3 customColor;
varying vec2 pos;


//helpers

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

// The MIT License
// Copyright © 2013 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// https://www.youtube.com/c/InigoQuilez
// https://iquilezles.org/
//
// https://www.shadertoy.com/view/Xsl3Dl
vec3 hash( vec3 p ) // replace this by something better
{
	p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
            dot(p,vec3(269.5,183.3,246.1)),
            dot(p,vec3(113.5,271.9,124.6)));

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec3 p )
{
  vec3 i = floor( p );
  vec3 f = fract( p );
	
	vec3 u = f*f*(3.0-2.0*f);

  return mix( mix( mix( dot( hash( i + vec3(0.0,0.0,0.0) ), f - vec3(0.0,0.0,0.0) ), 
                        dot( hash( i + vec3(1.0,0.0,0.0) ), f - vec3(1.0,0.0,0.0) ), u.x),
                   mix( dot( hash( i + vec3(0.0,1.0,0.0) ), f - vec3(0.0,1.0,0.0) ), 
                        dot( hash( i + vec3(1.0,1.0,0.0) ), f - vec3(1.0,1.0,0.0) ), u.x), u.y),
              mix( mix( dot( hash( i + vec3(0.0,0.0,1.0) ), f - vec3(0.0,0.0,1.0) ), 
                        dot( hash( i + vec3(1.0,0.0,1.0) ), f - vec3(1.0,0.0,1.0) ), u.x),
                   mix( dot( hash( i + vec3(0.0,1.0,1.0) ), f - vec3(0.0,1.0,1.0) ), 
                        dot( hash( i + vec3(1.0,1.0,1.0) ), f - vec3(1.0,1.0,1.0) ), u.x), u.y), u.z );
}

float cellular(vec3 coords) {
  vec2 gridBasePosition = floor(coords.xy);
  vec2 gridCoordOffset = fract(coords.xy);

  float closest = 1.0;
  for (float y = -2.0; y <= 2.0; y += 1.0) {
    for (float x = -2.0; x <= 2.0; x += 1.0) {
      vec2 neighbourCellPosition = vec2(x, y);
      vec2 cellWorldPosition = gridBasePosition + neighbourCellPosition;
      vec2 cellOffset = vec2(
        noise(vec3(cellWorldPosition, coords.z) + vec3(243.432, 324.235, 0.0)),
        noise(vec3(cellWorldPosition, coords.z))
      );

      float distToNeighbour = length(
          neighbourCellPosition + cellOffset - gridCoordOffset);
      closest = min(closest, distToNeighbour);
    }
  }

  return closest;
}



/* float fbm(vec3 p, int octaves, float persistence, float lacunarity) {
  float amplitude = 0.5;
  float frequency = 1.0;
  float total = 0.0;
  float normalization = 0.0;

//octaves are the number of loops
//an fbm is similar to adding sine waves together consequtively;
//and then increasing frequences / decreasing amplitude with each iteration
  for (int i = 0; i < octaves; ++i) {
    float noiseValue = noise(p * frequency);
    total += noiseValue * amplitude;
    normalization += amplitude;
    amplitude *= persistence;
    frequency *= lacunarity;
  }

  total /= normalization;

  return total;
}
 */





void main()
{
    vec3 coords;
    coords = vec3(pos * radius, uTime * 0.001);
	  float noiseSample = 0.0;
    float noiseSampleRegular = 0.0;
    noiseSampleRegular = remap(noise(coords), -1.0, 1.0, 0.0, 1.0);
    float noiseSampleRegular2nd = remap(noise(coords*1.2), -1.0, 1.0, 0.0, 1.0);
	  noiseSample = remap(cellular(coords), -1.0, 1.0, 0.0, 1.0); //the noise function will also return negative values
    float noiseSampleRegular3rd = remap(noise(coords*0.5), -1.0, 1.0, 0.0, 1.0);
  
    float d = length(pos - vec2(0.5))-0.6*noiseSample;
    float e = length(pos - vec2(0.5))-0.6*1.4*noiseSampleRegular;
    float f = length(pos - vec2(0.5))-0.6*1.4*noiseSampleRegular2nd;
    float g = length(pos - vec2(0.5))-0.3*1.4*noiseSampleRegular2nd;
    float h = length(pos - vec2(0.5))-0.6*2.0*noiseSampleRegular3rd;
    float i = length(pos - vec2(0.5))-0.1*1.4*noiseSampleRegular2nd;


    d = abs(d);
    e = abs(e);
    f = abs(f);
    g = abs(g);
    h = abs(h);
    i = abs(i);

    d = smoothstep(-0.05,0.08, d);
    e = smoothstep(-0.05,0.08, e);
    f = smoothstep(-0.05,0.08, f);
    g = smoothstep(-0.05,0.08,g);
    h = smoothstep(-0.05,0.08,h);
    i = smoothstep(-0.05,0.08,i);
    d = d*e*f*g*h*i;
    
    float c = length(pos-vec2(0.5))-0.2;
    
    vec3 img = texture2D(uTexture, pos+d-0.5).xyz;
    vec3 backgr = mix(vec3(0.97, 0.85, 0.85), vec3(0.97, 0.85, 0.85)*0.9,pos.x);    
    backgr = mix(vec3(0.07, 0.1, 0.22), vec3(0.97, 0.85, 0.85)*0.9,pos.x);
    
    //backgr = vec3(0.97, 0.85, 0.85);

    //play with values in white
    vec3 color = mix(vec3(2.0), backgr, d);
    //remove line for no image data:
    //color = mix(img, color, d);
    color = mix(color,vec3(0.0), c);
    
    gl_FragColor = vec4(color, 1.0);
}
class SpiralForce extends Force
{
  Particle a,b;
  float k;
  float distanceMin;
  float distanceMinSquared;

  SpiralForce( Particle a, Particle b, float k, float distanceMin )
  {
    this.a = a;
    this.b = b;
    this.k = k;
    this.distanceMin = distanceMin;
    this.distanceMinSquared = distanceMin*distanceMin;
  }

  void setMinimumDistance( float d )
  {
    distanceMin = d;
    distanceMinSquared = d*d;
  }

  void apply()
  {
    if ( on && ( a.isFree() || b.isFree() ) )
    {
      float a2bX = a.x - b.x;
      float a2bY = a.y - b.y;
      
      float a2bDistanceSquared = a2bX*a2bX + a2bY*a2bY;

      if ( a2bDistanceSquared < distanceMinSquared )
        a2bDistanceSquared = distanceMinSquared;

      float force = k / a2bDistanceSquared;

      //Add this to make the force drop off with 1/sq(d) instead of 1/d
      //float length = (float)Math.sqrt( a2bDistanceSquared );
      
      //a2bX /= length;
      //a2bY /= length;

      // multiply by force 

      a2bX *= force;
      a2bY *= force;

      // apply
      //The only difference between spiral and a regular force is we rotate x and y when we apply it
      if ( a.isFree() )
        a.force().add( -a2bY,a2bX, 0 );
      if ( b.isFree() )
        b.force().add( a2bY, -a2bX, 0 );
    }
  }
}

class Attraction2D extends Force
{
  Particle a,b;
  float k;
  float distanceMin;
  float distanceMinSquared;

  Attraction2D( Particle a, Particle b, float k, float distanceMin )
  {
    this.a = a;
    this.b = b;
    this.k = k;
    this.distanceMin = distanceMin;
    this.distanceMinSquared = distanceMin*distanceMin;
  }

  void setMinimumDistance( float d )
  {
    distanceMin = d;
    distanceMinSquared = d*d;
  }

  void apply()
  {
    if ( on && ( a.isFree() || b.isFree() ) )
    {
      float a2bX = a.x - b.x;
      float a2bY = a.y - b.y;
      
      float a2bDistanceSquared = a2bX*a2bX + a2bY*a2bY;

      if ( a2bDistanceSquared < distanceMinSquared )
        a2bDistanceSquared = distanceMinSquared;

      float force = k / a2bDistanceSquared;

      //Add this to make the force drop off with 1/sq(d) instead of 1/d
      float length = (float)Math.sqrt( a2bDistanceSquared );
      
      a2bX /= length;
      a2bY /= length;

      // multiply by force 

      a2bX *= force;
      a2bY *= force;

      // apply
      if ( a.isFree() )
        a.force().add( -a2bX,-a2bY, 0 );
      if ( b.isFree() )
        b.force().add( a2bX, a2bY, 0 );
    }
  }
  
  float strength() {
    return k;
  }
}

class VariableAttraction extends Force
{
  Particle a,b;
  float k;
  float distanceMin;
  float distanceMinSquared;
  float exponent;

  VariableAttraction( Particle a, Particle b, float k, float distanceMin )
  {
    this.a = a;
    this.b = b;
    this.k = k;
    this.distanceMin = distanceMin;
    this.distanceMinSquared = distanceMin*distanceMin;
    exponent = 2;
  }

  void setMinimumDistance( float d )
  {
    distanceMin = d;
    distanceMinSquared = d*d;
  }

  void apply()
  {
    if ( on && ( a.isFree() || b.isFree() ) )
    {
      float a2bX = a.x - b.x;
      float a2bY = a.y - b.y;
      float a2bZ = a.z - b.z;
      
      float a2bDistanceSquared = a2bX*a2bX + a2bY*a2bY + a2bZ;

      if ( a2bDistanceSquared < distanceMinSquared )
        a2bDistanceSquared = distanceMinSquared;

      float length = (float)Math.sqrt( a2bDistanceSquared );

      float force = k / pow(length,exponent);
      
      a2bX /= length;
      a2bY /= length;
      a2bZ /= length;

      // multiply by force 

      a2bX *= force;
      a2bY *= force;

      // apply
      if ( a.isFree() )
        a.force().add( -a2bX,-a2bY, -a2bZ );
      if ( b.isFree() )
        b.force().add( a2bX, a2bY, a2bZ );
    }
  }
}

class NoiseForce extends Force {
  Particle p;
  float noiseScale;
  float k;
  
  NoiseForce(Particle p, float k, float noiseScale) {
    this.p = p;
    this.k = k;
    this.noiseScale = noiseScale;
  }
  
  void apply() {
    if(on && p.isFree()) {
      float forceX = k*(noise(p.x*noiseScale,p.y*noiseScale,0)-.5);
      float forceY = k*(noise(p.x*noiseScale,p.y*noiseScale,50)-.5);
      p.force().add(forceX,forceY,0);
    }
  }
}

class NoisePotential2D extends Force {
  Particle p;
  float noiseScale;
  float k;
  float DELTA = 1;
  
  NoisePotential2D(Particle p, float k, float noiseScale) {
    this.p = p;
    this.k = k;
    this.noiseScale = noiseScale;
  }
  
  void apply() {
    if(on && p.isFree()) {
      float potentialX0 = noise((p.x-DELTA)*noiseScale,p.y*noiseScale, noiseT);
      float potentialX1 = noise((p.x+DELTA)*noiseScale,p.y*noiseScale, noiseT);
      float potentialY0 = noise(p.x*noiseScale,(p.y-DELTA)*noiseScale, noiseT);
      float potentialY1 = noise(p.x*noiseScale,(p.y+DELTA)*noiseScale, noiseT);
      
      p.force().add(k*(potentialX1-potentialX0)/(2*DELTA),k*(potentialY1-potentialY0)/(2*DELTA),0);
    }
  }
}

class ImagePotential extends Force {
  Particle p;
  float k;
  PImage image;
  
  ImagePotential(Particle p, float k, PImage image) {
    this.p = p;
    this.k = k;
    this.image = image;
  }
  
  void apply() {
    if(on && p.isFree()) {
      int xpos = int(p.x);
      int ypos = int(p.y);
      if(xpos>=image.width || xpos < 0 || ypos >= image.height || ypos < 0) return;
      float potentialX0,potentialX1,potentialY0,potentialY1;
      potentialX0=potentialX1=potentialY0=potentialY1=255;
      if(xpos-1 > 0) potentialX0 = brightness(image.pixels[ypos*image.width+xpos-1]); 
      if(xpos+1 < image.width) potentialX1 = brightness(image.pixels[ypos*image.width+xpos+1]); 
      if(ypos-1 > 0) potentialY0 = brightness(image.pixels[(ypos-1)*image.width+xpos]); 
      if(ypos+1 < image.height) potentialY1 = brightness(image.pixels[(ypos+1)*image.width+xpos]); 
      
      p.force().add(k*(potentialX1-potentialX0)/2.0,k*(potentialY1-potentialY0)/2.0,0);
    }
  }
}

class RandomForce2D extends Force {
  Particle p;
  float k;
  
  RandomForce2D(Particle p, float k) {
    this.p = p;
    this.k = k;
  }
  
  void apply() {
    if(on && p.isFree()) {
      p.force().add(random(-k,k),random(-k,k),0);
    }
  }
}

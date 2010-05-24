//move each point to the center of its voronoi region
void lloydStep() {
  for(int i=0;i<pnts.size();++i) {
    Pnt p = (Pnt) pnts.get(i);
    //get the voronoi region from the Delaunay triangulation
    Pnt[] voronoi = voronoiRegion(p);
    Pnt newPt = centroid(voronoi);
    //check for numerical error
    if(Float.isNaN(newPt.x()) || Float.isNaN(newPt.y())) {
      newPt = p;
    } 
    else {
      //move points to be inside the boundary (0,0)x(width,height)
      if(newPt.x() < 0) {
        //moveit
        Pnt dir = p.subtract(newPt);
        newPt = new Pnt(0,newPt.y()-dir.y()*newPt.x()/dir.x());
      } 
      else if(newPt.x() > width) {
        //moveit
        Pnt dir = p.subtract(newPt);
        newPt = new Pnt(width,newPt.y()-dir.y()*(newPt.x()-width)/dir.x());
      } 
      else if(newPt.y() < 0) {
        Pnt dir = p.subtract(newPt);
        newPt = new Pnt(newPt.x()-dir.x()*newPt.y()/dir.y(),0);
      } 
      else if(newPt.y() > height) {
        Pnt dir = p.subtract(newPt);
        newPt = new Pnt(newPt.x()-dir.x()*(newPt.y()-height)/dir.y(),height);
      }
    }
    pnts.set(i,newPt);
  }

  //recompute the triangulation
  dt = new DelaunayTriangulation(initialTriangle);
  for(int i=0;i<pnts.size();++i) {
    Pnt pt = (Pnt) pnts.get(i);
    dt.delaunayPlace(pt,null);
  }
}

Pnt[] voronoiRegion(Pnt p) {
  Set simpleces = dt.triangles(p);
  HashSet pts2 = new HashSet();
  for(Iterator it = simpleces.iterator();it.hasNext();) {
    Simplex s = (Simplex) it.next();
    for(Iterator it2 = s.iterator();it2.hasNext();) {
      Pnt p2 = (Pnt) it2.next();
      if(!p.equals(p2))
        pts2.add(p2);
    }
  }
  LinkedList normPts = new LinkedList();
  Iterator it = pts2.iterator();
  while(it.hasNext()) {
    Pnt curr = (Pnt) it.next();
    normPts.add(curr.add(-p.x(),-p.y()));
  }  
  Pnt[] sortedPts = sortAngle(normPts);
  for(int i=0;i<sortedPts.length;++i) {
    sortedPts[i] = sortedPts[i].add(p);
  }
  //compute voronoi pts;
  Pnt[] voronoiPts = new Pnt[sortedPts.length];
  for(int i=0;i<sortedPts.length;++i) {
    Pnt pt = pnt.circumcenter(new Pnt[] {
      p, sortedPts[i], sortedPts[(i+1)%sortedPts.length]    }
    );
    voronoiPts[i] = pt;
  }
  return voronoiPts;
}

Pnt[] sortAngle(Collection points) {
  Pnt[] sortedPts = new Pnt[points.size()];
  int k = sortedPts.length;
  for(int i=0;i<k;++i) {
    Iterator it = points.iterator();
    Pnt minAngle = (Pnt) it.next();
    while(it.hasNext()) {
      Pnt curr = (Pnt) it.next();
      if(compAngle(curr, minAngle)) minAngle = curr;
    }
    sortedPts[i] = minAngle;
    points.remove(minAngle);
  }
  return sortedPts;
}

//compare angles without any inverse trig functions
boolean compAngle(Pnt p1, Pnt p2) {
  float p1L = p1.magnitude();
  float p2L = p2.magnitude();
  p1 = new Pnt(p1.x()/p1L,p1.y()/p1L);
  p2 = new Pnt(p2.x()/p2L,p2.y()/p2L);
  if(p1.y() >= 0) {
    if(p2.y() >= 0) {
      if(p1.x() > p2.x()) {
        return true;
      } 
      else {
        return false;
      }
    } 
    else {
      return true;
    }
  } 
  else {
    if(p2.y() >= 0) {
      return false;
    } 
    else {
      if(p1.x() < p2.x()) {
        return true;
      } 
      else{
        return false;
      }
    }
  }
}

//compute the area centroid of an ordered set of points
Pnt centroid(Pnt[] crv) {
  float area = 0;
  float ux = 0;
  float uy = 0;
  for(int i=0;i<crv.length;++i) {
    Pnt p1 = crv[i];
    Pnt p2 = crv[(i+1)%crv.length];
    float a = p1.x()*p2.y()-p2.x()*p1.y();
    area += a;
    ux += (p1.x()+p2.x())*a;
    uy += (p1.y()+p2.y())*a;

  }
  area *= 0.5;

  return new Pnt(ux/area/6.0,uy/area/6.0);
}


/*
Represents an Article Tree in the sketch.
Note: I basically learned how to draw trees by viewing different
peoples code on http://www.openprocessing.org/ .  Lots of love for all
contributors to the site.
*/
public class ArticleTree
{
  
  /*Public Properties*/
  String articleUrl;
  String articleTitle;
  int lastUpdatedTime;
  
  ArrayList tpUsers;
  int decayTickCount = 0;
  
  /*Visual Properties*/
  float baseHeight = map(1.25, 0, 100, 0, height);
  float baseWidth = map(0.03, 0, 100, 0, width);
  float branchRatioLength = 0.90;
  int branchesPerStep = 2;
  int userDeathMinutes = 60;
  float textSizeBase = baseWidth*4;
  float margin = width * 0.1;
  color treeTrunkColor = #29210F;
  
  /*Stored Layout Values*/
  float baseX = -1;
  
  
  ArticleTree(String _articleUrl, String _articleTitle, int _lastUpdatedTime)
  {
    articleUrl = _articleUrl;
    articleTitle = _articleTitle;
    lastUpdatedTime = _lastUpdatedTime;
    
    tpUsers = new ArrayList();
  }
  
  
  /*
  Responsible for drawing this specific tree in the sketch.
  */
  void drawTree()
  {
    //First check to see if we should be dropping users.
    dropDeadUsers();
    if(tpUsers.size() <= 0)
    {
      return;
    }
    
    //Draw the base of the tree...or trunk if you're botanically inclined.
    strokeWeight(baseWidth * tpUsers.size());
    stroke(treeTrunkColor);
    if(baseX < 0)
    {
      baseX = random(0+margin, width-margin);
    }
    float y1 = height;
    float x2 = baseX;
    float y2 = height - (tpUsers.size()*baseHeight);
    
    line(baseX, y1, x2, y2);
    
    //Draw the article title along the trunk.
    textSize(textSizeBase * tpUsers.size());
    fill(treeTrunkColor, random(140,255));
    pushMatrix();
    translate(baseX, y1);
    rotate(radians(-90));
    text(articleTitle, 2, -5);
    popMatrix();
    
    //Start the branches drawing process. (NOTE: RECURSIVE!!)
    for(int i=0; i<branchesPerStep;i++)
    {
      drawBranch(x2, y2, -HALF_PI, y1-y2, 1);
    }

  }
  
  /*
  Recursive method for drawing the trees branches.
  Note: Setting the branchesPerStep value really high is a great 
  way to burn out your CPU.
  */
  void drawBranch(float startX, float startY, float prevAng, float prevLen, int inc)
  {
    int step = tpUsers.size() - inc;
    strokeWeight(baseWidth * step);
    stroke(#29210F);
   
    float newLen = branchRatioLength*prevLen;
    float angle = random(-PI/16, PI/16)+prevAng;
    float x2 = cos(angle)*newLen+startX;
    float y2 = sin(angle)*newLen+startY;
    
    line(startX, startY, x2, y2);
    
    //Check to see if we're in the top most branches.  If not draw more...else draw leaves.
    if(inc<tpUsers.size())
    {
      for(int i=0; i<branchesPerStep;i++)
      {
        drawBranch(x2, y2, prevAng+(random(-1,1)*radians(55)), newLen, inc+1);
      }
    }
    else
    {
      float leafWidth = random(baseWidth*tpUsers.size(), 3*(baseWidth*tpUsers.size()));
      int randInt = (int)random(0,100);
      //Do we want to draw a leaf or a TimesPeople user icon?
      //Note: User icons don't work in the browser because of cross domain issues.
      if(randInt%6 != 0  || online)
      {
        //If tree isn't decaying too much draw a nice green leaf.
        float healthColor = decayTickCount > 5 ? 255 - 50 * (decayTickCount-5) : random(105, 255);
        //If tree is decaying start "browning" the leaf based on it's decay level.
        float decayColor = decayTickCount > 5 ? 255 - 50 * (decayTickCount-5) : 50 * decayTickCount;
        
        //Draw the leaf.
        stroke(decayColor, healthColor, 0, random(32, 192));
        strokeWeight(leafWidth);
        point(x2+random(-2, 2), y2+random(-2, 2));
      }
      else
      {
        int index = (int)random(0,tpUsers.size());
        TPUser user = (TPUser)tpUsers.get(index);
        PImage userImage = user.userImage;
        if(userImage != null)
        {
          pushMatrix();
          translate(x2,y2);
          rotate(radians(random(-30, 30)));
          scale(leafWidth/userImage.width);
          image(userImage, -userImage.width/2, -userImage.height/2);
          popMatrix();
        }
      }
    }
  }
  
  /*
  Checks to see if any users have died and if so drops them
  from the tree.
  */
  void dropDeadUsers()
  {
    ArrayList deadUsers = new ArrayList();
    for(int i=0; i<tpUsers.size(); i++)
    {
      TPUser user = (TPUser)tpUsers.get(i);
      int now = millis();
      int diff = userDeathMinutes * 60000;
      if(user.userActionDate+diff < now)
      {
        deadUsers.add(user);
      }
    }
    //Remove dead users.
    for(int j=0; j<deadUsers.size(); j++)
    {
      TPUser removeUser = (TPUser)deadUsers.get(j);
      tpUsers.remove(removeUser);
      println("USERREMOVE:("+tpUsers.size()+") "+articleTitle);
    }
  }
  
  
  /*
  der..
  */
  boolean hasUserId(int userId)
  {
    for(int i=0; i<tpUsers.size(); i++)
    {
      TPUser tpuser = (TPUser)tpUsers.get(i);
      if(tpuser.userId == userId)
      {
        return true;
      }
    }
    return false;
  }
  
}
  
  
 

/*
Represents a TimesPeople user and the info required for
this sketch.
*/
public class TPUser
{
  
  int userId;
  int userActionDate;
  PImage userImage;
  
  TPUser(int id, int actionDate, String imageUrl)
  {
    userId = id;
    userActionDate = actionDate;
    try
    {
      if(imageUrl != "")
      {
        println(imageUrl);
        userImage = loadImage(imageUrl);
      }
      else
      {
        userImage = loadImage("http://graphics8.nytimes.com/images/apps/timespeople/none.png", "png");
      }
    }
    catch(Exception ex)
    {
     //Try the default
     try
     {
       userImage = loadImage("http://graphics8.nytimes.com/images/apps/timespeople/none.png", "png");
     }
     catch(Exception ex2)
     {
       //I give up dealing with stupid flaky wireless connections killing my sketch life.
       println(ex2.toString());
     }
    }
    
  }
  
}

import org.json.*;
import processing.net.*;

String FeedURL = "http://timespeople.nytimes.com/svc/timespeople/api/v1/livefeed.js";
ArrayList ArticleTrees;
int lastSecond;
int pauseCountSeconds = 20;
int treeDecayMinutes = 5;

/*
Peforms initial setup stuff.  Thus making it aptly named.
*/
void setup()
{
  
  PFont font;
  font = loadFont("Meta-Normal-48.vlw");
  textFont(font);
  
   //Set the size of the stage
  if(online)
  {
    size(800,600);
  }
  else
  {
    size(1280,768);
  }
  frameRate(60);
  
  smooth();

  ArticleTrees = new ArrayList();
  lastSecond = millis();
  getLatestFeed();
  updateScene();
}

/*
Method continuously called during execution.
Checks to see if the proper amount of time has passed
before updating the data.
*/
void draw()
{
  int now = millis();
  int diff = pauseCountSeconds*1000;
  if(lastSecond + diff < now)
  {
    //update the viz
    checkForDecay();
    lastSecond = now;
    getLatestFeed();
    updateScene();
    saveFrame("tp_garden-########");
  }
}

/*
  Updates the Data Set
*/
void getLatestFeed()
{
  println("starting");

  
  try
  {
    String result = join(loadStrings(FeedURL),"");
    JSONObject nytData = new JSONObject(result);
    JSONArray resultsArray = nytData.getJSONArray("results");
    for(int i=0; i<resultsArray.length(); i++)
    {
     JSONObject item = (JSONObject)resultsArray.get(i);
     addItem(item);
    }
  }
  catch(Exception ex)
  {
   println(ex.toString()); 
  }
  
  dropDeadTress();
  
  println("Articles: "+ArticleTrees.size());
}


/*
  Performs a smart add to the data set.
*/
void addItem(JSONObject newItem)
{
  String currentUrl = "";
  String currentTitle = "";
  int currentUserId = 0;
  String currentImageUrl = "";
  try
  {
    currentUrl = cleanUrl(newItem.getString("object_url")); 
    currentTitle = newItem.getString("object");
    currentUserId = newItem.getInt("user_id");
    currentImageUrl = newItem.getString("user_pic_url");
  }
  catch(JSONException ex)
  {
    println(ex.toString());
    return;
  }
  
  
  //Check to see if the article already exists as a tree.
  Boolean foundArticle = false;
  if(ArticleTrees.size() > 0)
  {
    for(int i=0; i<ArticleTrees.size(); i++)
    {
      ArticleTree currentTree = (ArticleTree)ArticleTrees.get(i);
      if(currentTree.articleUrl.equals(currentUrl))
      {
        foundArticle = true;
        //If we haven't already logged this user do so.
        if(!currentTree.hasUserId(currentUserId))
        {
          currentTree.lastUpdatedTime = millis();
          TPUser newUser = new TPUser(currentUserId, millis(), currentImageUrl);
          currentTree.tpUsers.add(newUser);
          currentTree.decayTickCount = currentTree.decayTickCount > 0 ? currentTree.decayTickCount - 1 : 0;

          println("USERADD:("+currentTree.tpUsers.size()+") "+currentTitle);
        }
     
        break;
      }
    }
  }
  
  //If we didn't find a tree for the article create a new once.
  if(!foundArticle)
  {
    ArticleTree addItem = new ArticleTree(currentUrl, currentTitle, millis());
    TPUser newUser = new TPUser(currentUserId, millis(), currentImageUrl);
    addItem.tpUsers.add(newUser);
    ArticleTrees.add(addItem);
    println("ADDEDTREE: "+currentTitle);
  }
  
}

/*
Updates the visuals for the entire sketch.
*/
void updateScene()
{
  drawBackground();
  for(int i=0; i<ArticleTrees.size(); i++)
  {
    ArticleTree currentItem = (ArticleTree)ArticleTrees.get(i);
    currentItem.drawTree();
  }
}

/*
Check to see if any of trees have decayed and update info accordingly.
*/
void checkForDecay()
{
  ArrayList trees = new ArrayList();
  for(int i=0; i<ArticleTrees.size(); i++)
  {
    ArticleTree tree = (ArticleTree)ArticleTrees.get(i);
    int now = millis();
    int diff = (treeDecayMinutes + (treeDecayMinutes*tree.decayTickCount)) * 60000;
    if(tree.lastUpdatedTime+diff < now)
    {
      tree.decayTickCount++;
      println("DECAYTICK:"+tree.articleTitle);
    }
  }
}

/*
Checks to see if any of the trees users have all died and in turn kills the tree.
*/
void dropDeadTress()
{
  ArrayList deadTrees = new ArrayList();
  for(int i=0; i<ArticleTrees.size(); i++)
  {
    ArticleTree tree = (ArticleTree)ArticleTrees.get(i);
    if(tree.tpUsers.size() <= 0)
    {
      deadTrees.add(tree);
    }
  }
  //Remove dead users.
  for(int j=0; j<deadTrees.size(); j++)
  {
    ArticleTree removeTree = (ArticleTree)deadTrees.get(j);
    println("REMOVEDTREE:"+removeTree.articleTitle);
    ArticleTrees.remove(removeTree);

  }
}


/*
  Cleans the url of querystring to help make it unique to the article.
*/
String cleanUrl(String url)
{
  //I don't know processing well enough so I'm doing this the lazy way.
  int searchIndex = url.indexOf('?');
  if(searchIndex > 0)
  {
    return url.substring(0,searchIndex);
  }
  else
  {
    return url;
  }  
}


/*
  Draw the amazingly awesome background.
*/
void drawBackground()
{ 
  
  background(#71D3FF);
  float barWidth = width/7;
  
  stroke(#C4ECFF);
  strokeWeight(barWidth);
  
  float x2 = width/2;
  float y2 = height;
  
  
  line(0-barWidth, 0-barWidth, x2, y2);
  line(width+barWidth, 0-barWidth, x2, y2);
  line(0-barWidth, height-barWidth, x2, y2);
  line(width+barWidth, height-barWidth, x2, y2); 
  line(width/2, 0-height-barWidth, x2, y2);
  
  
  /*
  int steps = 20;
  int startBlue = 20;
  int blueInc = 10;
  background(0,0,startBlue);
  noStroke();
  float stepsTotalHeight = 0;
  
  for(int i=0; i<=steps; i++)
  {
    fill(0,0,startBlue+(blueInc*i));
    rect(0, height-stepsTotalHeight, width, height/steps);
    stepsTotalHeight += height/steps;
  }
  
  fill(#FCE005);
  arc(width/8, 0, width*.3, width*.3, 0, PI);
  fill(#FFFFFF);
  ellipse(width*.65, height*.2, width*.3, height*.2);
  ellipse(width*.6, height*.28, width*.3, height*.2);
  ellipse(width*.75, height*.33, width*.3, height*.2);
  ellipse(width*.8, height*.24, width*.3, height*.2);
 */ 
}


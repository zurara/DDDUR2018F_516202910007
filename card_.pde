import controlP5.*;
import java.text.SimpleDateFormat;
import java.util.*;

ControlP5 cp5;
Table account;
Table shop;
Table trade;
PFont font, chineseFont;
PImage addButton;
PImage card;
List<PersonData> datas = new ArrayList<PersonData>();

Textarea myTextarea, recordarea;
Button btnEnter;
Textfield tf;
Textlabel monthL;
Textlabel expenseL;

Boolean first=true;

String[] Daily = {"1000091", "1000092", "1000093", "1000095", "1000098", "1000101", 
  "1000127", "1000137", "1000143", "1000175", "1000176", "1000194", "1000195", 
  "1000237", "1000190", "1000191", "1000193", "1000236", "1000240"};

Chart monthBar;
Chart monthPie;


void setup() {
  size(400, 600);
  background(248);
  cp5 = new ControlP5(this);
  account = loadTable ("account_demo.tsv", "header");
  shop = loadTable ("merchant_demo.tsv", "header");
  trade = loadTable ("trade.tsv", "header");
  font = createFont("arial", 15);
  chineseFont = createFont("Zfull-GB", 12);
  card = loadImage("card.png");
  addButton = loadImage("addButton.png");
  addNewCard();
  userInfo();
  inputCode();
  userRecord();
}

void draw() {
}

void addButton() {
  datas = new ArrayList<PersonData>();
  first=true;
  cp5.remove("INPUT YOUR STUDENTCODE");
  cp5.remove("ENTER");
  cp5.remove("info");
  cp5.remove("record");
  cp5.remove("expenseData");
  cp5.remove("monthData");
  cp5.remove("mL");
  cp5.remove("eL");

  setup();
}
void addNewCard() {
  int margin=60;
  //imageMode(CENTER);
  //image(addButton, width-margin, margin);    
  cp5.addButton("addButton")
    .setPosition(width-margin-16, margin-16)
    .setSize(32, 32)
    .setImage(loadImage("addButton.png"))
    .updateSize()
    ;

  imageMode(CENTER);
  image(card, width/2, margin*3);
}

void inputCode() {


  tf = cp5.addTextfield("INPUT YOUR STUDENTCODE")
    .setPosition(width/2-100, height/4)
    .setAutoClear(false)
    .setSize(200, 20)
    .setColorBackground(color(255, 255, 255, 100))
    .setColorCaptionLabel(color(200, 200, 200))
    .setColor(color(60, 60, 60))
    ;


  btnEnter = cp5.addButton("ENTER")
    .setValue(0)
    .setColorBackground(color(160, 160, 160, 100))
    .setColorForeground(210) 
    .setPosition(100, 240)
    .setSize(200, 19)
    ;
  btnEnter.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
}
public void ENTER(int theValue) {
  try
  {
    recordarea.clear();
    TableRow result = account.findRow(tf.getText(), "studentcode");
    String stucode;
    stucode = result.getString("account");
    println(stucode);
    Float money;

    String type="Unknown";
    String gender="Unknown";
    if (result.getString("type").compareTo("本科")==0) {
      type="Bachelor";
    } else if (result.getString("type").compareTo("硕士")==0) {
      type="Master";
    } else if (result.getString("type").compareTo("博士")==0) {
      type="Doctor";
    }
    if (result.getString("gender").compareTo("男")==0) {
      gender ="Male";
    } else if (result.getString("gender").compareTo("女")==0) {
      gender="Female";
    }

    myTextarea.setText("GRADE" + "      " +result.getString("grade")
      +"\nTYPE"+ "         "  +type
      +"\nGENDER"+ "    "  +gender
      );

    Iterable<TableRow> rowIt = trade.findRows(stucode, "fromaccount");
    for (TableRow row : rowIt) {
      money=float(row.getInt("amount"))/100;
      println(row.getString("toaccount") + ": " + money.toString());

      TableRow res=shop.findRow(row.getString("toaccount"), "toaccount");

      recordarea.append(res.getString("accountname") +" "
        +row.getString("timestamp") + "   " 
        + money.toString() + "元" +"\n");
      PersonData p = new PersonData(row.getString("toaccount"), row.getString("timestamp"), money);
      datas.add(p);
    }

    monthChart(datas);
    btnEnter.setVisible(false);
  }
  catch(Exception error)
  {
    if (!first)
      myTextarea.setText("NOT FOUND");
    else
      first=false;
  }
}

void userInfo() {

  myTextarea = cp5.addTextarea("info")
    .setPosition(100, 190)
    .setSize(200, 50)
    .setLineHeight(14)
    .setColor(color(128))
    .setColorBackground(color(255, 100))
    .setColorForeground(color(255, 100))
    .hideScrollbar()
    ;
}

void userRecord() {


  recordarea = cp5.addTextarea("record")
    .setPosition(50, 320)
    .setSize(300, 150)
    .setLineHeight(14)
    .setColor(color(128))
    .setFont(chineseFont)
    .setColorBackground(color(248))
    ;
}

Boolean isDaily(String id)
{
  for (String i : Daily)
    if (i.equals(id))
      return true;
  return false;
}  

void monthChart(List<PersonData> list) {
  Float[] monthAmount = new Float[12];
  Float dailyAmount = 0.0, foodAmount = 0.0;
  Arrays.fill(monthAmount, 0.0);
  Float maxMonthAmount = 0.0;
  for (PersonData p : list)
  {
    Date pdate = new Date(); 

    try {
      pdate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(p.timestamp);
      monthAmount[pdate.getMonth()] += p.amount;
      if (monthAmount[pdate.getMonth()] > maxMonthAmount)
        maxMonthAmount = monthAmount[pdate.getMonth()];
      if (isDaily(p.toaccount))
        dailyAmount += p.amount;
      else
        foodAmount += p.amount;
    }
    catch (Exception e) {
      println(e);
    }
  }
  //println("Sep:"+monthAmount[8].toString());
  //println("Daily:"+dailyAmount.toString());
  //println("Food:"+foodAmount.toString());
  monthBar = cp5.addChart("monthData")
    .setColorCaptionLabel(color(0))
    .setPosition(50, 480)
    .setSize(220, 80)
    .setColorBackground(color(248))      
    .setRange(0, maxMonthAmount)
    .setView(Chart.BAR_CENTERED) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    ;
  monthBar.addDataSet("Month");
  monthBar.setColors("Month", color(#1ED4E3), color(#7AA9AD));
  monthBar.setData("Month", new float[5]);
  monthBar.setStrokeWeight(0.5);

  monthBar.push("Month", monthAmount[8]);
  monthBar.push("Month", monthAmount[9]);
  monthBar.push("Month", monthAmount[10]);
  monthBar.push("Month", monthAmount[11]);
  monthBar.push("Month", monthAmount[0]);

  monthPie= cp5.addChart("expenseData")
    .setColorCaptionLabel(color(0))
    .setColorBackground(color(248))
    .setPosition(270, 480)
    .setSize(80, 80)
    .setView(Chart.PIE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    ;
  monthPie.addDataSet("MonthP");
  monthPie.setColors("MonthP", color(#89BED1), color(#1BB8F0));
  monthPie.setData("MonthP", new float[2]);

  monthPie.push("MonthP", dailyAmount);
  monthPie.push("MonthP", foodAmount);

  monthL = cp5.addTextlabel("mL")
    .setText("SEP." +"            "+"OCT."+"            "+"NOV."+"            "+ "DEC."+"           "+ "JAN.")
    .setPosition(65, 560)
    .setColorValue(#383939)
    ;
  float am = dailyAmount+foodAmount ;
  float dPer = norm(dailyAmount, 0, am);
  float fPer = norm(foodAmount, 0, am);
  expenseL = cp5.addTextlabel("eL")
    .setText("Daily" + " "+ round(dPer*100)+"%"+"\n"+"Food" + " "+ round(fPer*100)+"%")
    .setPosition(285, 510)
    .setColorValue(#FAFAFA)
    ;

}

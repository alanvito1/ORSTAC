//+------------------------------------------------------------------+
//|                                            SupportResistance.mq4 |
//|                                    Copyright 2017, Erwin Beckers |
//|                                      https://www.erwinbeckers.nl |
//
// # Donations are welcome !!
// Like what you see ? Feel free to donate to support further developments..
// BTC: 1J4npABsiQa2GkJu5q6RsjtCR1jxNvZdtu
// BCC: 1J4npABsiQa2GkJu5q6RsjtCR1jxNvZdtu
// LTC: LN4BCwQEUzULg3z6NpA5KQSvUftv3xG9xA
// ETH: 0xfa77e81d94b39b49f4b3dc7880c68ad57e6e7163
// NEO: ANQxQxFd4z5c7P3W1azK7zxvzRNY4dwbJg
//
// v1.02:
// - Added timeframes lower than 1 Hour
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Erwin Beckers"
#property link      "https://www.erwinbeckers.nl"
#property version   "1.02"
#property strict
#property indicator_chart_window

#include <CSupportResistance.mqh>

extern bool        SR_1Minute      = false;
extern bool        SR_5Minutes     = false;
extern bool        SR_15Minutes    = false;
extern bool        SR_30Minutes    = false;
extern bool        SR_1Hours       = false;
extern bool        SR_4Hours       = false;
extern bool        SR_Daily        = false;
extern bool        SR_Weekly       = true;
extern bool        SR_Monthly      = true;
extern bool        ShowAgeLabels   = true;
extern bool        ShowLastTouch   = false; 
extern bool        ShowAllSRLines  = false; 
extern string      __colors__      = "---- S/R settings ----";
extern color       ColorAge1       = Silver;
extern color       ColorAge2       = clrDarkGray;
extern color       ColorAge3       = LightSeaGreen;
extern color       ColorAge4       = Teal;
extern color       ColorText       = Black;


CSupportResistance* _supportResistanceMN1;
CSupportResistance* _supportResistanceW1;
CSupportResistance* _supportResistanceD1;
CSupportResistance* _supportResistanceH4;
CSupportResistance* _supportResistanceH1;
CSupportResistance* _supportResistanceM30;
CSupportResistance* _supportResistanceM15;
CSupportResistance* _supportResistanceM5;
CSupportResistance* _supportResistanceM1;

color        Colors[]     = {Silver,clrDarkGray, LightSeaGreen,Teal};


//+------------------------------------------------------------------+
void ClearAll()
{
   _supportResistanceMN1.ClearAll();
   _supportResistanceW1.ClearAll();
   _supportResistanceD1.ClearAll();
   _supportResistanceH4.ClearAll();
   _supportResistanceH1.ClearAll();
   _supportResistanceM30.ClearAll();
   _supportResistanceM15.ClearAll();
   _supportResistanceM5.ClearAll();
   _supportResistanceM1.ClearAll();
}

//+------------------------------------------------------------------+
void CalculateSR(bool forceRefresh = false)
{  
   string txt="S/R:";
   if (SR_Monthly) 
   {
      txt +="MN1,";
      _supportResistanceMN1.Calculate(forceRefresh);
      _supportResistanceMN1.Draw("MN1", ColorText, Colors, ShowAgeLabels, ShowLastTouch, ShowAllSRLines);
   }
   
   if (SR_Weekly) 
   {
      txt +="W1,";
      _supportResistanceW1.Calculate(forceRefresh);
      _supportResistanceW1.Draw("W1", ColorText, Colors, ShowAgeLabels, ShowLastTouch, ShowAllSRLines);
   }
   
   if (SR_Daily) 
   {
      txt +="D1,";
      _supportResistanceD1.Calculate(forceRefresh);
      _supportResistanceD1.Draw("D1", ColorText, Colors, ShowAgeLabels, ShowLastTouch, ShowAllSRLines);
   }
   
   if (SR_4Hours)
   {
      txt +="H4,";
      _supportResistanceH4.Calculate(forceRefresh);
      _supportResistanceH4.Draw("H4", ColorText, Colors, ShowAgeLabels, ShowLastTouch, ShowAllSRLines);
   }
   
   if (SR_1Hours)
   {
      txt +="H1,";
      _supportResistanceH1.Calculate(forceRefresh);
      _supportResistanceH1.Draw("H1", ColorText, Colors, ShowAgeLabels, ShowLastTouch, ShowAllSRLines);
   }
   
   if (SR_30Minutes)
   {
      txt +="M30,";
      _supportResistanceM30.Calculate(forceRefresh);
      _supportResistanceM30.Draw("M30", ColorText, Colors, ShowAgeLabels, ShowLastTouch, ShowAllSRLines);
   }
   
   if (SR_15Minutes)
   {
      txt +="M15,";
      _supportResistanceM15.Calculate(forceRefresh);
      _supportResistanceM15.Draw("M15", ColorText, Colors, ShowAgeLabels, ShowLastTouch, ShowAllSRLines);
   }
   
   if (SR_5Minutes)
   {
      txt +="M5,";
      _supportResistanceM5.Calculate(forceRefresh);
      _supportResistanceM5.Draw("M5", ColorText, Colors, ShowAgeLabels, ShowLastTouch, ShowAllSRLines);
   }
   
   if (SR_1Minute)
   {
      txt +="M1,";
      _supportResistanceM1.Calculate(forceRefresh);
      _supportResistanceM1.Draw("M1", ColorText, Colors, ShowAgeLabels, ShowLastTouch, ShowAllSRLines);
   }
   
   switch (SR_Detail)
   {
      case Minium:     txt += " Minimum";     break;
      case MediumLow:  txt += " Medium/Low";  break;
      case Medium:     txt += " Medium";      break;
      case MediumHigh: txt += " Medium/High"; break;
      case Maximum:    txt += " Maximum";     break;
   }
   
   ObjectCreate("@info", OBJ_LABEL, 0, 0, 0);
   ObjectSet("@info", OBJPROP_BACK, false);
   ObjectSet("@info", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSet("@info", OBJPROP_XDISTANCE, 250);
   ObjectSet("@info", OBJPROP_YDISTANCE, 0);
   ObjectSetText("@info", txt, 8, "Arial", ColorText);
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   CalculateSR();
   return(rates_total);
}


//+------------------------------------------------------------------+
void deinit()
{ 
   ClearAll();
   delete _supportResistanceMN1;
   delete _supportResistanceW1;
   delete _supportResistanceD1;
   delete _supportResistanceH4;
   delete _supportResistanceH1;
   delete _supportResistanceM30;
   delete _supportResistanceM15;
   delete _supportResistanceM5;
   delete _supportResistanceM1;
}

//+------------------------------------------------------------------+
int init()
{  
   Colors[0] = ColorAge1;
   Colors[1] = ColorAge2;
   Colors[2] = ColorAge3;
   Colors[3] = ColorAge4;
   
   _supportResistanceMN1 = new CSupportResistance(Symbol(), PERIOD_MN1);
   _supportResistanceW1  = new CSupportResistance(Symbol(), PERIOD_W1);
   _supportResistanceD1  = new CSupportResistance(Symbol(), PERIOD_D1);
   _supportResistanceH4  = new CSupportResistance(Symbol(), PERIOD_H4);
   _supportResistanceH1  = new CSupportResistance(Symbol(), PERIOD_H1);
   _supportResistanceM30 = new CSupportResistance(Symbol(), PERIOD_M30);
   _supportResistanceM15 = new CSupportResistance(Symbol(), PERIOD_M15);
   _supportResistanceM5 = new CSupportResistance(Symbol(), PERIOD_M5);
   _supportResistanceM1 = new CSupportResistance(Symbol(), PERIOD_M1);
   
   CalculateSR(true);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id,          // Event ID
                  const long& lparam,    // Parameter of type long event
                  const double& dparam,  // Parameter of type double event
                  const string& sparam)  // Parameter of type string events
{
   if (id == 9)
   {
      //Print("Chart zoomed or changed, recalculate SR");
      CalculateSR();
   }
   if (id == CHARTEVENT_KEYDOWN)
   {
      switch(lparam)
      {
         case 49://1
            Print("Detail: minimum");
            SR_Detail = Minium; 
            CalculateSR();
         break;
         
         case 50://2
            Print("Detail: medium low");
            SR_Detail = MediumLow; 
            CalculateSR();
         break;
         
         case 51://3
            Print("Detail: medium");
            SR_Detail = Medium; 
            CalculateSR();
         break;
         
         case 52://4
            Print("Detail: medium high");
            SR_Detail = MediumHigh; 
            CalculateSR();
         break;
         
         case 53://5
            Print("Detail: maximum");
            SR_Detail = Maximum; 
            CalculateSR();
         break;
 
         case 77://m
            ClearAll();
            SR_Monthly = !SR_Monthly;
            Print("Monthly :", SR_Monthly ? "on":"off");
            CalculateSR();
         break;
                  
         case 87://w
            ClearAll();
            SR_Weekly = !SR_Weekly;
            Print("Weekly :", SR_Weekly ? "on":"off");
            CalculateSR();
         break;
         
         case 65://a
            ClearAll();
            ShowAllSRLines = !ShowAllSRLines;
            Print("ShowAllSRLines :", ShowAllSRLines ? "on":"off");
            CalculateSR();
         break;
         
         case 68://d
            ClearAll();
            SR_Daily = !SR_Daily;
            Print("Daily :", SR_Weekly ? "on":"off");
            CalculateSR();
         break;
         
         case 72://h
            ClearAll();
            SR_4Hours = !SR_4Hours;
            Print("4Hours :", SR_Weekly ? "on":"off");
            CalculateSR();
         break;
         
         case 73://i
            ClearAll();
            SR_1Hours=!SR_1Hours;
            Print("1Hour :", SR_1Hours ? "on":"off");
            CalculateSR();
         break;
         
         case 82://r
            ClearAll();
            SR_1Hours = false;
            SR_4Hours = false;
            SR_Daily  = true;
            SR_Weekly = false;
            SR_Detail = Medium;
            CalculateSR();
         break;
      }
   }
}
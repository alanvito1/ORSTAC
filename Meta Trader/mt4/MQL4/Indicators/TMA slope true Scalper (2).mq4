//+------------------------------------------------------------------+
//|   pacois_mod                             10.2 TmaSlope v.1.4.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, zznbrm"

//Edited by shahrooz "sh.sadeghi.me@gmail.com"
//Edited by Nanningbob April 2012 for 10.2                           
//---- indicator settings
#property indicator_separate_window
#property  indicator_buffers     9
#property  indicator_level1      0.4
#property  indicator_level2      -0.4 
#property  indicator_level3      0.8 
#property  indicator_level4      -0.8 
#property  indicator_levelcolor  clrDarkSlateGray 
// pacois_mod 
#property indicator_color1 Green
#property indicator_color2 Lime
#property indicator_color3 FireBrick
#property indicator_color4 Red
#property indicator_color5 Yellow
#property indicator_color6 Yellow



#property indicator_width1 8
#property indicator_width2 8
#property indicator_width3 8
#property indicator_width4 8
#property indicator_width5 8  
#property indicator_width6 8  
#property indicator_width7 2   

//---- input parameters
extern string OtherTimeFrames = "Select below 0=current tf,1,5,15,30,60,240,1440,10080,43200";

extern int BarsBack  = 50;

extern ENUM_TIMEFRAMES select_other_tf_to_show=5;
extern ENUM_TIMEFRAMES select_other_tf_to_show2=15;
extern ENUM_TIMEFRAMES select_other_tf_to_show3=30;

extern int H_Pos_MTF=5;
extern int V_Pos_MTF=42;
extern string Font_Name = "Verdana";
extern int        Font_Size_MTF              = 16;
extern int Corner_MTF=3;
extern color      Font_Color_Range            = Gray;
extern color      Font_Color_Buy              = Green;
extern color      Font_Color_Sell             = Red;

extern int eintPeriod = 13;
extern double edblHigh1 = 0.4;
extern double edblLow1 = -0.4;
extern int atrPeriod = 100;


extern int        H_Pos               = 5;
extern int        V_Pos               = 22;
extern int        Corner              = 3;
extern int        Font_Size           = 16;
extern int        Font_Size_text      = 16;
extern int        H_Pos_text          = 5;
extern int        V_Pos_text          = 2;

extern int Text_Corner=3;

//---- indicator buffers
double gadblUp1[];
double gadblUp2[];

double gadblDn1[];
double gadblDn2[];

double gadblMid1[];
double gadblMid2[];

double gadblSlope[]; 

double highestTMA[];
double lowestTMA[];

double TICK;
bool AdditionalDigit;
string gstrShortName;
string TimeFrameStr;
string TimeFrameStr2;
string TimeFrameStr3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{              
   //IndicatorBuffers( 8 );    
   IndicatorBuffers( 7 );
   IndicatorDigits( 5 );
   gstrShortName = WindowOnDropped()+"10.2 TmaSlopeTrueScalper";
   IndicatorShortName( gstrShortName );
   AdditionalDigit = MarketInfo(Symbol(), MODE_MARGINCALCMODE) == 0 && MarketInfo(Symbol(), MODE_PROFITCALCMODE) == 0 && Digits % 2 == 1;
   TICK = getTick();
      
   SetIndexBuffer( 0, gadblUp1 );    SetIndexLabel( 0, "UP1" );       SetIndexStyle( 0, DRAW_HISTOGRAM );
   SetIndexBuffer( 1, gadblUp2 );    SetIndexLabel( 1, "UP2");       SetIndexStyle( 1, DRAW_HISTOGRAM );
   SetIndexBuffer( 2, gadblDn1 );    SetIndexLabel( 2, "DN1" );       SetIndexStyle( 2, DRAW_HISTOGRAM );
   SetIndexBuffer( 3, gadblDn2 );    SetIndexLabel( 3, "DN2" );       SetIndexStyle( 3, DRAW_HISTOGRAM );
   SetIndexBuffer( 4, gadblMid1 );    SetIndexLabel( 4,"MID1" );       SetIndexStyle( 4, DRAW_HISTOGRAM );
   SetIndexBuffer( 5, gadblMid2 );    SetIndexLabel( 5,"MID2" );       SetIndexStyle( 5, DRAW_HISTOGRAM );

   SetIndexBuffer( 6, gadblSlope );  SetIndexLabel( 6, gstrShortName );    SetIndexStyle( 6, DRAW_NONE );
   
   SetIndexBuffer( 7, highestTMA ); SetIndexLabel( 7, "" );   SetIndexStyle( 7, DRAW_NONE );
   SetIndexBuffer( 8, lowestTMA );  SetIndexLabel( 8, "" );   SetIndexStyle( 8, DRAW_NONE );

      
   SetIndexEmptyValue( 0, 0.0 );
   SetIndexEmptyValue( 1, 0.0 );
   SetIndexEmptyValue( 2, 0.0 );

   switch(select_other_tf_to_show)
   {
      case 1 : TimeFrameStr="M1"; break;
      case 5 : TimeFrameStr="M5"; break;
      case 15 : TimeFrameStr="M15"; break;
      case 30 : TimeFrameStr="M30"; break;
      case 60 : TimeFrameStr="H1"; break;
      case 240 : TimeFrameStr="H4"; break;
      case 1440 : TimeFrameStr="D1"; break;
      case 10080 : TimeFrameStr="W1"; break;
      case 43200 : TimeFrameStr="MN1"; break;
      default : TimeFrameStr="Current";
   } 
   
     switch(select_other_tf_to_show2)
   {
      case 1 : TimeFrameStr2="M1"; break;
      case 5 : TimeFrameStr2="M5"; break;
      case 15 : TimeFrameStr2="M15"; break;
      case 30 : TimeFrameStr2="M30"; break;
      case 60 : TimeFrameStr2="H1"; break;
      case 240 : TimeFrameStr2="H4"; break;
      case 1440 : TimeFrameStr2="D1"; break;
      case 10080 : TimeFrameStr2="W1"; break;
      case 43200 : TimeFrameStr2="MN1"; break;
      default : TimeFrameStr2="Current";
   } 
   
   
      switch(select_other_tf_to_show3)
   {
      case 1 : TimeFrameStr3="M1"; break;
      case 5 : TimeFrameStr3="M5"; break;
      case 15 : TimeFrameStr3="M15"; break;
      case 30 : TimeFrameStr3="M30"; break;
      case 60 : TimeFrameStr3="H1"; break;
      case 240 : TimeFrameStr3="H4"; break;
      case 1440 : TimeFrameStr3="D1"; break;
      case 10080 : TimeFrameStr3="W1"; break;
      case 43200 : TimeFrameStr3="MN1"; break;
      default : TimeFrameStr3="Current";
   } 
   
   

   return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   ObjectDelete( gstrShortName + "0" );
   ObjectDelete( gstrShortName + "1" );
   ObjectDelete( gstrShortName + "2" );
   return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   if ( counted_bars < 0 ) return(-1);
   if ( counted_bars > 0 ) counted_bars--;
               
   int intLimit = MathMin( Bars - 1, Bars - counted_bars + eintPeriod );
   
   double dblTma, dblPrev;
   double atr; 
     for( int inx = intLimit; inx >= 0; inx-- )
   {   
   lowestTMA[inx]=-0; highestTMA[inx]=0;
 
   int currentBar=0;
   int endBar=BarsBack;
 
  for(currentBar=0;currentBar<endBar; currentBar++)
  lowestTMA[inx]=MathMin(lowestTMA[inx], gadblSlope[currentBar]);
  
  for(currentBar=0;currentBar<endBar; currentBar++)
  highestTMA[inx]=MathMax(highestTMA[inx],gadblSlope[currentBar]);
   
   EALevels("horzup"+WindowOnDropped(),0,highestTMA[inx],highestTMA[inx],1,2,clrLime,true); 
   EALevels("horzdn"+WindowOnDropped(),0,lowestTMA[inx],lowestTMA[inx],1,2,clrRed,true); 
  
 }

   // Calculate Tma Slope for current timeframe and plot
   for(  inx = intLimit; inx >= 0; inx-- )
   {   
      atr= iATR(NULL,0,atrPeriod,inx+10)*0.1;

      if (atr == 0) continue;      
      dblTma = calcTma( inx );
      dblPrev = calcPrev( inx );
      gadblSlope[inx] = ( dblTma - dblPrev ) / atr;
      
      gadblUp1[inx] = 0.0;   
      gadblDn1[inx] = 0.0;     
      gadblMid1[inx] = 0.0;   
      gadblUp2[inx] = 0.0;   
      gadblDn2[inx] = 0.0;     
      gadblMid2[inx] = 0.0;   
   
     if ( gadblSlope[inx] > edblHigh1 )
     {
         if(gadblSlope[inx] < gadblSlope[inx+1]) gadblUp1[inx] = gadblSlope[inx];
         else gadblUp2[inx] = gadblSlope[inx];
     }
     else if ( gadblSlope[inx] < edblLow1 )
     {
         if(gadblSlope[inx] < gadblSlope[inx+1]) gadblDn2[inx] = gadblSlope[inx];
         else gadblDn1[inx] = gadblSlope[inx];
     }
     else  
     {
         if(gadblSlope[inx] < gadblSlope[inx+1]) gadblMid2[inx] = gadblSlope[inx];
         else gadblMid1[inx] = gadblSlope[inx];
     } 
     
 
   }
   
   
   
   // Update current timeframe tma slope label
   string tt=DoubleToStr(gadblSlope[0],2);
   int intWindow = WindowFind( gstrShortName );
   string str1;
   color clr1;
   
   // Update current timeframe tma slope trend status label         
   if (gadblSlope[0] >= edblHigh1)   
   {
      str1 = "Buy Only";
      clr1 = Font_Color_Buy;
   }
   else if ( gadblSlope[0] <= edblLow1 )
   {
      str1 = "Sell Only";
      clr1 = Font_Color_Sell;
   }
   else
   {
      str1 = "Ranging";
      clr1 = Font_Color_Range;
   }   
   
   ObjectCreate(gstrShortName + "0",OBJ_LABEL,intWindow,0,0);
   ObjectSet(gstrShortName + "0",OBJPROP_XDISTANCE,H_Pos);
   ObjectSet(gstrShortName + "0",OBJPROP_YDISTANCE,V_Pos);
   ObjectSet(gstrShortName + "0",OBJPROP_CORNER,Corner);
   ObjectSetText(gstrShortName + "0"," "+tt,Font_Size,Font_Name,clr1);
      
   // Update current timeframe tma slope trend status label   
   ObjectCreate(gstrShortName + "1", OBJ_LABEL,intWindow, 0, 0);
   ObjectSet(gstrShortName + "1", OBJPROP_CORNER, Text_Corner);
   ObjectSet(gstrShortName + "1", OBJPROP_XDISTANCE, H_Pos_text);//left to right
   ObjectSet(gstrShortName + "1", OBJPROP_YDISTANCE, V_Pos_text);//top to bottom
   ObjectSetText(gstrShortName + "1", str1, Font_Size_text, Font_Name, clr1);

   // Update other timeframe tma slope value label
   double hh = gadblSlope[0];
   double hh2 = gadblSlope[0];
   double hh3 = gadblSlope[0];
   if ( ( select_other_tf_to_show != Period() ) && ( select_other_tf_to_show != 0 ) )
   {
      double atrMTF = iATR(NULL,select_other_tf_to_show,atrPeriod,10)*0.1;
      double atrMTF2 = iATR(NULL,select_other_tf_to_show2,atrPeriod,10)*0.1;
      double atrMTF3 = iATR(NULL,select_other_tf_to_show3,atrPeriod,10)*0.1;
      if (atrMTF == 0) return( 0 );
   
      double dblTmaMTF = calcTmaMTF( 0 , select_other_tf_to_show );
      double dblPrevMTF = calcTmaMTF( 1 , select_other_tf_to_show);
      hh = ( dblTmaMTF - dblPrevMTF ) / atrMTF;
      
      double dblTmaMTF2 = calcTmaMTF( 0 , select_other_tf_to_show2 );
      double dblPrevMTF2 = calcTmaMTF( 1 , select_other_tf_to_show2);
      hh2 = ( dblTmaMTF2 - dblPrevMTF2 ) / atrMTF2;
      
      
      double dblTmaMTF3 = calcTmaMTF( 0 , select_other_tf_to_show3 );
      double dblPrevMTF3 = calcTmaMTF( 1 , select_other_tf_to_show3);
      hh3 = ( dblTmaMTF3 - dblPrevMTF3 ) / atrMTF3;
      
      
   }
    
   if(hh>=edblHigh1) clr1=Font_Color_Buy;
   else if (hh<=edblLow1) clr1=Font_Color_Sell;
   else clr1=Font_Color_Range;
   
   string jj=DoubleToStr(hh,2);
   // pacois_mod 
    ObjectCreate(gstrShortName + "2",OBJ_LABEL,intWindow,0,0);
    ObjectSet(gstrShortName + "2",OBJPROP_XDISTANCE,H_Pos_MTF);
    ObjectSet(gstrShortName + "2",OBJPROP_YDISTANCE,V_Pos_MTF);
    ObjectSet(gstrShortName + "2",OBJPROP_CORNER,Corner_MTF);
   ObjectSetText(gstrShortName + "2",""+TimeFrameStr+" = "+jj,Font_Size_MTF,Font_Name,clr1);
   
   
   if(hh2>=edblHigh1) clr1=Font_Color_Buy;
   else if (hh2<=edblLow1) clr1=Font_Color_Sell;
   else clr1=Font_Color_Range;
   // pacois_mod 
   string jj2=DoubleToStr(hh2,2);
   
    ObjectCreate(gstrShortName + "22",OBJ_LABEL,intWindow,0,0);
    ObjectSet(gstrShortName + "22",OBJPROP_XDISTANCE,H_Pos_MTF);
    ObjectSet(gstrShortName + "22",OBJPROP_YDISTANCE,V_Pos_MTF+20);
    ObjectSet(gstrShortName + "22",OBJPROP_CORNER,Corner_MTF);
   ObjectSetText(gstrShortName + "22",""+TimeFrameStr2+" = "+jj2,Font_Size_MTF,Font_Name,clr1);
    if(hh3>=edblHigh1) clr1=Font_Color_Buy;
   else if (hh3<=edblLow1) clr1=Font_Color_Sell;
   else clr1=Font_Color_Range;
   // pacois_mod  
    string jj3=DoubleToStr(hh3,2);
   
    ObjectCreate(gstrShortName + "23",OBJ_LABEL,intWindow,0,0);
    ObjectSet(gstrShortName + "23",OBJPROP_XDISTANCE,H_Pos_MTF);
    ObjectSet(gstrShortName + "23",OBJPROP_YDISTANCE,V_Pos_MTF+40);
    ObjectSet(gstrShortName + "23",OBJPROP_CORNER,Corner_MTF);
   ObjectSetText(gstrShortName + "23",""+TimeFrameStr3+" = "+jj3,Font_Size_MTF,Font_Name,clr1);
   
   
   return( 0 );
}

//+------------------------------------------------------------------+
//| getTick()                                                        |
//+------------------------------------------------------------------+
double getTick() {
    double tick = MarketInfo(Symbol(), MODE_TICKSIZE);
    if (AdditionalDigit) {
        tick *= 10;
    }    
    return (tick);
}

//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
double calcTma( int inx )
{
   return( iMA( Symbol(), Period(), eintPeriod+1, 0, MODE_LWMA, PRICE_CLOSE, inx ) );
}

//+------------------------------------------------------------------+
//| calcPrev()                                                       |
//+------------------------------------------------------------------+
double calcPrev( int inx )
{
   double dblSum  = (eintPeriod+1)*Close[inx+1];
   double dblSumw = (eintPeriod+1);
   int jnx, knx;
   
   // Add in the current (inx) bar
   dblSum  += ( eintPeriod * Close[inx] );
   dblSumw += eintPeriod;
         
   for ( jnx = 1, knx = eintPeriod; jnx <= eintPeriod; jnx++, knx-- )
   {
      dblSum  += ( knx * Close[inx+1+jnx] );
      dblSumw += knx;
   }
   
   return( dblSum / dblSumw );
}
 
 double calcTmaMTF( int inx , int tf)
{
   double dblSum  = (eintPeriod+1)*iClose(Symbol(),tf,inx);
   double dblSumw = (eintPeriod+1);
   int jnx, knx;
         
   for ( jnx = 1, knx = eintPeriod; jnx <= eintPeriod; jnx++, knx-- )
   {
      dblSum  += ( knx * iClose(Symbol(),tf,inx+jnx) );
      dblSumw += knx;

      if ( jnx <= inx )
      {
         dblSum  += ( knx * iClose(Symbol(),tf,inx-jnx) );
         dblSumw += knx;
      }
   }
   
   return( dblSum / dblSumw );
}

 void EALevels(string levels, int Window, double start, double end,double w, double s,color clr, bool Delete)
  {
   if (Delete) ObjectDelete(levels);
   if(ObjectFind(levels)!=0)
     {
   ObjectCreate(levels, OBJ_HLINE, WindowFind(gstrShortName), WindowFirstVisibleBar(), start, Time[0], end);
   ObjectSet(levels, OBJPROP_COLOR, clr);
   ObjectSet(levels,OBJPROP_BACK,1);
   ObjectSet(levels,OBJPROP_WIDTH,w);
   ObjectSet(levels,OBJPROP_STYLE,s);
     }
   else
   ObjectMove(levels, WindowFind(gstrShortName),  WindowFirstVisibleBar(), Time[0]);
  }
  
 //pacois_mod  

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 



   



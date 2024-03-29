#property copyright "Copyright 2020, 3filter"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrBlue
#property indicator_color2 clrRed
#property indicator_width1 1
#property indicator_width2 1
//============================================
enum ON_OFF {
             on, //ON
             off //OFF
             };
enum TYPE_SIGN {
             in,      //being in the channel
             out,     //off channel
             tick_in, //the moment of transition to the channel
             tick_out //channel transition moment
             };
enum TYPE_LINE_STOCH {
             total,   //two lines
             no_total //any line
             };
enum TYPE_TIME { 
             en_time, // allow trade
             dis_time // ban trade
             };
enum TYPE_MAIL { 
             one_time, // once upon first occurrence of a signal
             all_time  // every time a signal appears
             };
//============================================
extern string             txt0         = "INDICATOR 1"; //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern ON_OFF             on_off_main1 = on;                  // Turning on
extern string             name_ind1    = "ValueAut";        // Indicator name
extern int                bufferUP1    = 0;                   // Buffer arrows "UP"
extern int                bufferDN1    = 1;                   // Buffer arrows "DOWN"
extern string             txt01        = "";                  //.
extern string             txt02        = "INDICATOR 2"; //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern ON_OFF             on_off_main2 = on;                  // Turning on
extern string             name_ind2    = "RSI";        // Indicator name
extern int                bufferUP2    = 0;                   // Buffer arrows "UP"
extern int                bufferDN2    = 1;                   // Buffer arrows "DOWN"
extern string             txt012       = "";                  //.
extern string             txt03        = "INDICATOR 3"; //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern ON_OFF             on_off_main3 = on;                  // Turning on
extern string             name_ind3    = "bb";        // Indicator name
extern int                bufferUP3    = 0;                   // Buffer arrows "UP"
extern int                bufferDN3    = 0;                   // Buffer arrows "DOWN"
extern string             txt013       = "";                  //.
extern string             txt_adx_1    = "ADX";   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern ON_OFF             on_off_adx   = off;                  // Enable ADX
extern int                period_adx   = 1;                  // Period
extern double             level_adx    = 60.0;                 // Level
extern ENUM_APPLIED_PRICE price_adx    = 0;                   // Price type
extern string             txt_adx_2    = "";                  //.
extern string             txt_cci_1    = "~~~~~~ CCI_1 ~~~~~~"; //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern ON_OFF             on_off_cci1  = off;                  // Enable CCI
extern TYPE_SIGN          type_cci1    = 0;                   // Signal type
extern ON_OFF             revers_cci1  = 1;                 // Signal Reverse
extern int                period_cci1  = 3;                 // Period
extern double             level_cci1   = 95.0;                 // Levels (0+x, 0-x)
extern ENUM_APPLIED_PRICE price_cci1   = 0;                  // Price type
extern string             txt_cci_2    = "";                  //.
extern string             txt_rsi_1    = "~~~~~~ RSI_1 ~~~~~~"; //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern ON_OFF             on_off_rsi1  = off;                  // Enable RSI
extern TYPE_SIGN          type_rsi1    = 0;                   // Signal type
extern ON_OFF             revers_rsi1  = 1;                 // Signal Reverse
extern int                period_rsi1  = 14;                 // Period
extern double             level_rsi1   = 20.0;                 // Levels (100-x, 0+x)
extern ENUM_APPLIED_PRICE price_rsi1   = 0;                  // Price type
extern string             txt_rsi_2    = "";                  //.
extern string             txt_dem_1    = "~~~~~~ DeMarker_1 ~~~~~~"; //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern ON_OFF             on_off_DeM1  = off;                  // Enable DeMarker
extern TYPE_SIGN          type_DeM1    = 0;                 // Signal type
extern ON_OFF             revers_DeM1  = 0;               // Signal Reverse
extern int                period_DeM1  = 14;               // Period
extern double             level_DeM1   = 0.2;               // Levels (1-x, 0+x)
extern string             txt_dem_2    = "";                //.
extern string             txt_Stoch_1  = "~~~~~~ Stochastic ~~~~~~"; //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern ON_OFF             on_off_Stoch = off;                  // Enable Stochastic
extern TYPE_SIGN          type_Stoch   = 0;                 // Signal type
extern ON_OFF             revers_Stoch = 0;               // Signal Reverse
extern int                periodK_Stoch= 5;              // Period %K
extern int                periodD_Stoch= 3;              // Period %D
extern int                sloving_Stoch= 3;              // Slowdown
extern ENUM_STO_PRICE     price_Stoch  = 0;                // Price type
extern ENUM_MA_METHOD     methMA_Stoch = 0;               // Method MA
extern double             level_Stoch  = 20.0;               // Levels (100-x, 0+x)
extern TYPE_LINE_STOCH    type_line    = 0;                  // Level Out...
extern string             txt_Stoch_2  = "";                //.
extern string             txt_WPR_1    = "~~~~~~ WPR_1 ~~~~~~"; //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern ON_OFF             on_off_WPR1  = off;                  // Enable WPR
extern TYPE_SIGN          type_WPR1    = 0;                 // Signal type
extern ON_OFF             revers_wpr1  = 0;               // Signal Reverse
extern int                period_WPR1  = 14;               // Period
extern double             level_WPR1   = 20.0;               // Levels (0-x, -100+x)
extern string             txt_WPR_2    = "";                //.
extern string             txt_bb_1     = "~~~~~~ BBands_1 ~~~~~~"; //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern ON_OFF             on_off_BB1   = off;                  // Enable BBands
extern TYPE_SIGN          type_BB1     = 0;                 // Signal type
extern ON_OFF             revers_BB1   = 0;               // Signal Reverse
extern int                period_BB1   = 20;               // Period
extern double             deviat_BB1   = 2.00;              // Deviation
extern int                shift_BB1    = 0;                // Shift
extern ENUM_APPLIED_PRICE price_BB1    = 0;                // Price type
extern string             txt_bb_2     = "";                  //.
extern string             txt_Env_1     = "~~~~~~ Envelopes ~~~~~~"; //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern ON_OFF             on_off_Env    = off;                  // Enable Envelopes
extern TYPE_SIGN          type_Env      = 0;                 // Signal type
extern ON_OFF             revers_Env    = 0;               // Signal Reverse
extern int                period_Env    = 14;               // Period
extern double             deviat_Env    = 0.10;              // Deviation
extern int                shift_Env     = 0;                // Shift
extern ENUM_MA_METHOD     methMA_Env    = 0;               // Method MA
extern ENUM_APPLIED_PRICE price_Env     = 0;                // Price type
extern string             txt_Env_2     = "";                  //.
extern double             rollback     = 0; // Min the ratio of the body of the candle to the shadows (%, if 0 then do not use.)
extern string             txt_r        = "";                  //.
extern ON_OFF             filtr_bar    = off; // Enable filter by candle color
extern string             txt_f        = "";                  //.
extern int                wait_bar     = 0;  // Min. number of pass bars between arrows
extern string             txt_w        = "";                  //.
extern string             txt26        = "TIME FILTER";//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern TYPE_TIME          time_type    = 1; // In the hours indicated below...
extern string             hour_filtr   = "";                 // Hours of the day to apply the filter (if empty, the filter is off.)
extern string             txt2_7       = "";                  //.
extern string             minut_filtr  = "";                // The list of minutes open. signal candles (if empty, the filter is off.)
extern string             txt27        = "";                  //.
extern string             txt28        = "Statistics";  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern ON_OFF             statistika   = on;                 //Enable statistics counting
extern int                cntMinut     = 1;                //How many minutes to update statistics
extern int                cnt_bars     = 500;                //Number of bars for counting signals
extern int                expir        = 1;                   //Number of expiration bars
extern string             txt29        = "";                  //.
extern int                ots          = 3;                  //The distance of the shooter from the candles (in pips)
extern ON_OFF             AlertSound   = 0;                 //Enable sound alert
extern string             txt30        = "";                  //.
extern ON_OFF             AlertMail    = 0;                 //Enabling Email Signaling
extern ON_OFF             AlertNotif   = 0;                 //Enabling sending a signal to a mobile terminal
extern TYPE_MAIL          mail_type    = 1;                   //Send a signal during candle formation ...

double buyBuffer[];
double sellBuffer[];

bool   indicatorsON=true;
int time_cnt = 0;
bool soundBuy = false;
bool soundSell = false;
bool sendMail = true;
datetime timeBar = iTime(NULL,0,0);
datetime timeBar_prev = iTime(NULL,0,0);
double rollback_bar;

//===============================================================\
//============= ACCOUNT AND TIME BLOCK =================\
datetime end_date = D'2028.12.01 00:00'; //activation end date
long number_login = 6401357; //customer MT account number
//===============================================================\

int h,m;
ushort u_sep;                  // delimiter character code
string result_hour[];          // array to get the clock strings
string result_minut[];         // array to get minutes strings

int init()
{
u_sep=StringGetCharacter(",",0);
h=StringSplit(hour_filtr,u_sep,result_hour);
u_sep=StringGetCharacter(",",0);
m=StringSplit(minut_filtr,u_sep,result_minut);

// Buffers and style
SetIndexStyle(0, DRAW_ARROW);
SetIndexArrow(0, 225);
SetIndexBuffer(0, buyBuffer);
SetIndexStyle(1, DRAW_ARROW);
SetIndexArrow(1, 226);
SetIndexBuffer(1, sellBuffer);
// Data window
IndicatorShortName("3filter");

if(on_off_BB1==1&&true&&
on_off_DeM1==1&&true&&true&&
on_off_Env==1&&
on_off_Stoch==1&&
on_off_adx==1&&
filtr_bar==1&&
on_off_WPR1==1&&true&&true&&
on_off_cci1==1&&true&&
on_off_rsi1==1&&true&&
on_off_main1==1&&on_off_main2==1&&on_off_main3==1) indicatorsON=false;

 return(INIT_SUCCEEDED);
}

int deinit()
{
 Comment("");
 return(0);
}

int start()
{
 if(indicatorsON) Tick();
 return(0);
}

void Tick()
  {
if(TimeCurrent()>end_date)
{if((TimeSeconds(TimeCurrent())%2) == 0) Comment("!!! THE INDICATOR IS NOT ATTACHED TO YOUR ACCOUNT OR THE TERM DURATION TIME IS EXPIRED !!!");
else Comment(""); return;}

      double gap  = ots*Point;

    int limit;
    int counted_bars = IndicatorCounted();
    if(counted_bars < 0) 
        return;
    if(counted_bars > 0) 
        counted_bars--;
    limit = Bars - counted_bars;

    for(int i = 0; i < limit; i++)
     { 
      if(!hour_trade(i)||!minut_trade(i)||!for_Bars(i)) continue;

      if(rollback>0)
       {rollback_bar = 100;
        if((High[i]-Low[i])==0) rollback_bar  = 0;
        else
        {if(Close[i]>=Open[i]) rollback_bar  = ((Close[i]-Open[i])/(High[i]-Low[i]))*100;
         if(Close[i]<=Open[i]) rollback_bar  = ((Open[i]-Close[i])/(High[i]-Low[i]))*100;}}

       // Long signal
      if(BuySell_signal("buy",i))
       buyBuffer[i] = Low[i]-gap;
       else
       buyBuffer[i] = EMPTY_VALUE;

        // Short signal
      if(BuySell_signal("sell",i))
       sellBuffer[i] = High[i]+gap;
       else
       sellBuffer[i] = EMPTY_VALUE;
        }

        string  messageBuy  =  StringConcatenate("3filter (", Symbol(), ", ", Period(), ")  -  BUY!!!" ,"-" ,TimeToStr(TimeLocal(),TIME_SECONDS));
        string  messageSell =  StringConcatenate("3filter (", Symbol(), ", ", Period(), ")  -  SELL!!!","-"  ,TimeToStr(TimeLocal(),TIME_SECONDS));
     if(mail_type==0)
     {timeBar = iTime(NULL,0,0);
      if (timeBar_prev!=timeBar) sendMail = true;
      timeBar_prev = iTime(NULL,0,0);}

     if (buyBuffer[0] == Low[0]-gap && soundBuy)
         {
           soundBuy = false;
           if(AlertSound==0) Alert(messageBuy);
          if(sendMail)
           {sendMail = false;
            if(AlertNotif==0) SendNotification(messageBuy);
            if(AlertMail==0)  SendMail("3filter",messageBuy);}
          }
      if (!soundBuy && (buyBuffer[0] == EMPTY_VALUE)) {soundBuy = true;  if(mail_type==1) sendMail = true;}
     if (sellBuffer[0] == High[0]+gap && soundSell)
         {
           soundSell = false;
           if(AlertSound==0) Alert(messageSell);
          if(sendMail)
           {sendMail = false;
            if(AlertNotif==0) SendNotification(messageSell);
            if(AlertMail==0)  SendMail("3filter",messageSell);}
          }
      if (!soundSell && (sellBuffer[0] == EMPTY_VALUE)) {soundSell = true;  if(mail_type==1) sendMail = true;}

    if(statistika==0)
     {
      if ((int(TimeCurrent()) - time_cnt) >= (cntMinut*60))
       { cnt_Statist();
         time_cnt = int(TimeCurrent());
         Print("==3filter==: Statistics recounted ",TimeCurrent()," by terminal time"); }
       }
}

bool BuySell_signal(string b_s, int i)
 {
     if(b_s=="buy")
       // Long signal
      {if(
         (filtr_bar==1 || Open[i]>Close[i])
          &&
         (rollback==0 || rollback_bar>=rollback)
          &&
         (on_off_main1==1 || fun_main1("up",i))
          &&
         (on_off_main2==1 || fun_main2("up",i))
          &&
         (on_off_main3==1 || fun_main3("up",i))
          &&
         (on_off_adx==1  || fun_ADX(i))
          &&
         (on_off_cci1==1 || fun_CCI((revers_cci1==1?"up":"dn"),1,i))
          &&
true
          &&
         (on_off_rsi1==1 || fun_RSI((revers_rsi1==1?"up":"dn"),1,i))
          &&
true
          &&
         (on_off_DeM1==1 || fun_DeM((revers_DeM1==1?"up":"dn"),1,i))
          &&
true
          &&
true
          &&
         (on_off_Stoch==1 || fun_Stoch((revers_Stoch==1?"up":"dn"),i))
          &&
         (on_off_WPR1==1 || fun_WPR((revers_wpr1==1?"up":"dn"),1,i))
          &&
true
          &&
true
          &&
         (on_off_BB1==1  || fun_BB((revers_BB1==1?"up":"dn"),1,i))
          &&
true
          &&
         (on_off_Env==1  || fun_Env((revers_Env==1?"up":"dn"),i))
         )
       return(true);
       else
       return(false);}

     if(b_s=="sell")
        // Short signal
      {if(
         (filtr_bar==1 || Open[i]<Close[i])
          &&
         (rollback==0 || rollback_bar>=rollback)
          &&
         (on_off_main1==1 || fun_main1("dn",i))
          &&
         (on_off_main2==1 || fun_main2("dn",i))
          &&
         (on_off_main3==1 || fun_main3("dn",i))
          &&
         (on_off_adx==1  || fun_ADX(i))
          &&
         (on_off_cci1==1 || fun_CCI((revers_cci1==1?"dn":"up"),1,i))
          &&
true
          &&
         (on_off_rsi1==1 || fun_RSI((revers_rsi1==1?"dn":"up"),1,i))
          &&
true
          &&
         (on_off_DeM1==1 || fun_DeM((revers_DeM1==1?"dn":"up"),1,i))
          &&
true
          &&
true
          &&
         (on_off_Stoch==1 || fun_Stoch((revers_Stoch==1?"dn":"up"),i))
          &&
         (on_off_WPR1==1 || fun_WPR((revers_wpr1==1?"dn":"up"),1,i))
          &&
true
          &&
true
          &&
         (on_off_BB1==1  || fun_BB((revers_BB1==1?"dn":"up"),1,i))
          &&
true
          &&
         (on_off_Env==1  || fun_Env((revers_Env==1?"dn":"up"),i))
         )
       return(true);
       else
       return(false);}
    return(false);
  }

bool for_Bars ( int k )
  {
   if((k+wait_bar)>=Bars) return (false);
   for (int i = k+1; i<=k+wait_bar; i++)
      {
       if(BuySell_signal("buy",i) || BuySell_signal("sell",i)) return (false);
       }
     return (true);
   }

void cnt_Statist()
 { int total_cnt=0, profit_cnt=0, losses_cnt=0;
   double winrate=0;
   string msg;

   for(int s=cnt_bars; s>expir; s--)
     { if(s>=Bars) continue;
       if((buyBuffer[s]!=EMPTY_VALUE && Open[s-1]<Close[s-expir]) ||(sellBuffer[s]!=EMPTY_VALUE && Open[s-1]>Close[s-expir]))  profit_cnt++;
       if((buyBuffer[s]!=EMPTY_VALUE && Open[s-1]>=Close[s-expir])||(sellBuffer[s]!=EMPTY_VALUE && Open[s-1]<=Close[s-expir])) losses_cnt++; }

    total_cnt = profit_cnt+losses_cnt;
   if(total_cnt>0) winrate = ((profit_cnt)*1.0/(total_cnt)*1.0)*100.0;

        msg = "\n---<<< 3filter >>>---\n\n" +
        "Statistics for " + IntegerToString(MathMin(Bars,cnt_bars)) + " bars:\n" +
        IntegerToString(profit_cnt) + "+  " + IntegerToString(losses_cnt) + "- \n" +
        "Winright " + DoubleToString(winrate,1) + "% \n\n" +
        "Updated " + TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);

   Comment(msg);
   }

bool fun_ADX (int index)
 {
  double adx = EMPTY_VALUE;
         adx = iADX(NULL,0,period_adx,price_adx,MODE_MAIN,index);
      if(adx>level_adx) return(true); else return(false);
  return(false);
  }

bool fun_CCI (string up_dn, int numb_CCI, int index)
 {
  double cci = EMPTY_VALUE;
  double cci_p = EMPTY_VALUE;
  double lev_max;
  double lev_min;
   if(numb_CCI==1) {
                    cci = iCCI(NULL,0,period_cci1,price_cci1,index);
                    if(type_cci1==2||type_cci1==3) cci_p = iCCI(NULL,0,period_cci1,price_cci1,index+1);
                    lev_max = level_cci1;
                    lev_min = 0-level_cci1;
                     if(up_dn=="up")
                        {
                         if((type_cci1==0&&cci>lev_min&&cci<lev_max)||(type_cci1==1&&cci<lev_min)||(type_cci1==2&&cci_p<lev_min&&cci>lev_min)||(type_cci1==3&&cci_p>lev_min&&cci<lev_min)) return(true); else return(false);
                         }
                     if(up_dn=="dn")
                        {
                         if((type_cci1==0&&cci>lev_min&&cci<lev_max)||(type_cci1==1&&cci>lev_max)||(type_cci1==2&&cci_p>lev_max&&cci<lev_max)||(type_cci1==3&&cci_p<lev_max&&cci>lev_max)) return(true); else return(false);
                         }
                    }
  return(false);
  }

bool fun_RSI (string up_dn, int numb_RSI, int index)
 {
  double rsi = EMPTY_VALUE;
  double rsi_p = EMPTY_VALUE;
  double lev_max;
  double lev_min;

   if(numb_RSI==1) {
                    rsi = iRSI(NULL,0,period_rsi1,price_rsi1,index);
                    if(type_rsi1==2||type_rsi1==3) rsi_p = iRSI(NULL,0,period_rsi1,price_rsi1,index+1);
                    lev_max = 100-level_rsi1;
                    lev_min = 0+level_rsi1;
                     if(up_dn=="up")
                        {
                         if((type_rsi1==0&&rsi>lev_min&&rsi<lev_max)||(type_rsi1==1&&rsi<lev_min)||(type_rsi1==2&&rsi_p<lev_min&&rsi>lev_min)||(type_rsi1==3&&rsi_p>lev_min&&rsi<lev_min)) return(true); else return(false);
                         }
                     if(up_dn=="dn")
                        {
                         if((type_rsi1==0&&rsi>lev_min&&rsi<lev_max)||(type_rsi1==1&&rsi>lev_max)||(type_rsi1==2&&rsi_p>lev_max&&rsi<lev_max)||(type_rsi1==3&&rsi_p<lev_max&&rsi>lev_max)) return(true); else return(false);
                         }
                    }  

  return(false);
  }

bool fun_DeM (string up_dn, int numb_DeM, int index)
 {
  double DeM = EMPTY_VALUE;
  double DeM_p = EMPTY_VALUE;
  double lev_max;
  double lev_min;

   if(numb_DeM==1) {
                    DeM = iDeMarker(NULL,0,period_DeM1,index);
                    if(type_DeM1==2||type_DeM1==3) DeM_p = iDeMarker(NULL,0,period_DeM1,index+1);
                    lev_max = 1-level_DeM1;
                    lev_min = 0+level_DeM1;
                     if(up_dn=="up")
                        {
                         if((type_DeM1==0&&DeM>lev_min&&DeM<lev_max)||(type_DeM1==1&&DeM<lev_min)||(type_DeM1==2&&DeM_p<lev_min&&DeM>lev_min)||(type_DeM1==3&&DeM_p>lev_min&&DeM<lev_min)) return(true); else return(false);
                         }
                     if(up_dn=="dn")
                        {
                         if((type_DeM1==0&&DeM>lev_min&&DeM<lev_max)||(type_DeM1==1&&DeM>lev_max)||(type_DeM1==2&&DeM_p>lev_max&&DeM<lev_max)||(type_DeM1==3&&DeM_p<lev_max&&DeM>lev_max)) return(true); else return(false);
                         }
                    }
  return(false);
  }

bool fun_Stoch (string up_dn, int index)
 {
  double Stoch_m = EMPTY_VALUE;
  double Stoch_s = EMPTY_VALUE;
  double Stoch_m_p = EMPTY_VALUE;
  double Stoch_s_p = EMPTY_VALUE;
  double lev_max;
  double lev_min;

  if(type_line==0) {
                    Stoch_m = iStochastic(NULL,0,periodK_Stoch,periodD_Stoch,sloving_Stoch,methMA_Stoch,price_Stoch,MODE_MAIN,index);
                    Stoch_s = iStochastic(NULL,0,periodK_Stoch,periodD_Stoch,sloving_Stoch,methMA_Stoch,price_Stoch,MODE_SIGNAL,index);
                     if(type_Stoch==2||type_Stoch==3) {Stoch_m_p = iStochastic(NULL,0,periodK_Stoch,periodD_Stoch,sloving_Stoch,methMA_Stoch,price_Stoch,MODE_MAIN,index+1);
                                                      Stoch_s_p = iStochastic(NULL,0,periodK_Stoch,periodD_Stoch,sloving_Stoch,methMA_Stoch,price_Stoch,MODE_SIGNAL,index+1);}
                    lev_max = 100-level_Stoch;
                    lev_min = 0+level_Stoch;
                     if(up_dn=="up")
                        {
                         if((type_Stoch==0&&Stoch_m>lev_min&&Stoch_m<lev_max&&Stoch_s>lev_min&&Stoch_s<lev_max)
                             ||
                            (type_Stoch==1&&Stoch_m<lev_min&&Stoch_s<lev_min)||(type_Stoch==2&&Stoch_m_p<lev_min&&Stoch_s_p<lev_min&&Stoch_m>lev_min&&Stoch_s>lev_min)||(type_Stoch==3&&Stoch_m_p>lev_min&&Stoch_s_p>lev_min&&Stoch_m<lev_min&&Stoch_s<lev_min)) return(true); else return(false);
                         }
                     if(up_dn=="dn")
                        {
                         if((type_Stoch==0&&Stoch_m>lev_min&&Stoch_m<lev_max&&Stoch_s>lev_min&&Stoch_s<lev_max)
                             ||
                            (type_Stoch==1&&Stoch_m>lev_max&&Stoch_s>lev_max)||(type_Stoch==2&&Stoch_m_p>lev_max&&Stoch_s_p>lev_max&&Stoch_m<lev_max&&Stoch_s<lev_max)||(type_Stoch==3&&Stoch_m_p<lev_max&&Stoch_s_p<lev_max&&Stoch_m>lev_max&&Stoch_s>lev_max)) return(true); else return(false);
                         }
                      }

    if(type_line==1) {
                    Stoch_m = iStochastic(NULL,0,periodK_Stoch,periodD_Stoch,sloving_Stoch,methMA_Stoch,price_Stoch,MODE_MAIN,index);
                    Stoch_s = iStochastic(NULL,0,periodK_Stoch,periodD_Stoch,sloving_Stoch,methMA_Stoch,price_Stoch,MODE_SIGNAL,index);
                     if(type_Stoch==2||type_Stoch==3) {Stoch_m_p = iStochastic(NULL,0,periodK_Stoch,periodD_Stoch,sloving_Stoch,methMA_Stoch,price_Stoch,MODE_MAIN,index+1);
                                                      Stoch_s_p = iStochastic(NULL,0,periodK_Stoch,periodD_Stoch,sloving_Stoch,methMA_Stoch,price_Stoch,MODE_SIGNAL,index+1);}
                    lev_max = 100-level_Stoch;
                    lev_min = 0+level_Stoch;
                     if(up_dn=="up")
                        {
                         if((type_Stoch==0&&((Stoch_m>lev_min&&Stoch_m<lev_max)||(Stoch_s>lev_min&&Stoch_s<lev_max)))
                             ||
                            (type_Stoch==1&&(Stoch_m<lev_min||Stoch_s<lev_min))||(type_Stoch==2&&((Stoch_m_p<lev_min&&Stoch_m>lev_min)||(Stoch_s_p<lev_min&&Stoch_s>lev_min)))||(type_Stoch==3&&((Stoch_m_p>lev_min&&Stoch_m<lev_min)||(Stoch_s_p>lev_min&&Stoch_s<lev_min)))) return(true); else return(false);
                         }
                     if(up_dn=="dn")
                        {
                         if((type_Stoch==0&&((Stoch_m>lev_min&&Stoch_m<lev_max)||(Stoch_s>lev_min&&Stoch_s<lev_max)))
                             ||
                            (type_Stoch==1&&(Stoch_m>lev_max||Stoch_s>lev_max))||(type_Stoch==2&&((Stoch_m_p>lev_max&&Stoch_m<lev_max)||(Stoch_s_p>lev_max&&Stoch_s<lev_max)))||(type_Stoch==3&&((Stoch_m_p<lev_max&&Stoch_m>lev_max)||(Stoch_s_p<lev_max&&Stoch_s>lev_max)))) return(true); else return(false);
                         }
                      }
     return(false);
  }

bool fun_WPR (string up_dn, int numb_WPR, int index)
 {
  double WPR = EMPTY_VALUE;
  double WPR_p = EMPTY_VALUE;
  double lev_max;
  double lev_min;

   if(numb_WPR==1) {
                    WPR = iWPR(NULL,0,period_WPR1,index);
                    if(type_WPR1==2||type_WPR1==3) WPR_p = iWPR(NULL,0,period_WPR1,index+1);
                    lev_max = 0-level_WPR1;
                    lev_min = -100+level_WPR1;
                     if(up_dn=="up")
                        {
                         if((type_WPR1==0&&WPR>lev_min&&WPR<lev_max)||(type_WPR1==1&&WPR<lev_min)||(type_WPR1==2&&WPR_p<lev_min&&WPR>lev_min)||(type_WPR1==3&&WPR_p>lev_min&&WPR<lev_min)) return(true); else return(false);
                         }
                     if(up_dn=="dn")
                        {
                         if((type_WPR1==0&&WPR>lev_min&&WPR<lev_max)||(type_WPR1==1&&WPR>lev_max)||(type_WPR1==2&&WPR_p>lev_max&&WPR<lev_max)||(type_WPR1==3&&WPR_p<lev_max&&WPR>lev_max)) return(true); else return(false);
                         }
                    }
  return(false);
  }

bool fun_BB (string up_dn, int numb_BB, int index)
 {
  double BB_max = EMPTY_VALUE;
  double BB_min = EMPTY_VALUE;

   if(numb_BB==1) {
                    BB_max = iBands(NULL,0,period_BB1,deviat_BB1,shift_BB1,price_BB1,MODE_UPPER,index);
                    BB_min = iBands(NULL,0,period_BB1,deviat_BB1,shift_BB1,price_BB1,MODE_LOWER,index);
                     if(up_dn=="up")
                        {
                         if((type_BB1==0&&Open[index]>BB_min&&Open[index]<BB_max&&Close[index]>BB_min&&Close[index]<BB_max)
                             ||
                            (type_BB1==1&&Open[index]<BB_min&&Close[index]<BB_min)||(type_BB1==2&&Open[index]<BB_min&&Close[index]>BB_min)||(type_BB1==3&&Open[index]>BB_min&&Close[index]<BB_min)) return(true); else return(false);
                         }
                     if(up_dn=="dn")
                        {
                         if((type_BB1==0&&Open[index]>BB_min&&Open[index]<BB_max&&Close[index]>BB_min&&Close[index]<BB_max)
                             ||
                            (type_BB1==1&&Open[index]>BB_max&&Close[index]>BB_max)||(type_BB1==2&&Open[index]>BB_max&&Close[index]<BB_max)||(type_BB1==3&&Open[index]<BB_max&&Close[index]>BB_max)) return(true); else return(false);
                         }
                    }

  return(false);
  }

bool fun_Env (string up_dn, int index)
 {
  double Env_max = EMPTY_VALUE;
  double Env_min = EMPTY_VALUE;

                     Env_max = iEnvelopes(NULL,0,period_Env,methMA_Env,shift_Env,price_Env,deviat_Env,MODE_UPPER,index);
                    Env_min = iEnvelopes(NULL,0,period_Env,methMA_Env,shift_Env,price_Env,deviat_Env,MODE_LOWER,index);
                     if(up_dn=="up")
                        {
                         if((type_Env==0&&Open[index]>Env_min&&Open[index]<Env_max&&Close[index]>Env_min&&Close[index]<Env_max)
                             ||
                            (type_Env==1&&Open[index]<Env_min&&Close[index]<Env_min)||(type_Env==2&&Open[index]<Env_min&&Close[index]>Env_min)||(type_Env==3&&Open[index]>Env_min&&Close[index]<Env_min)) return(true); else return(false);
                         }
                     if(up_dn=="dn")
                        {
                         if((type_Env==0&&Open[index]>Env_min&&Open[index]<Env_max&&Close[index]>Env_min&&Close[index]<Env_max)
                             ||
                            (type_Env==1&&Open[index]>Env_max&&Close[index]>Env_max)||(type_Env==2&&Open[index]>Env_max&&Close[index]<Env_max)||(type_Env==3&&Open[index]<Env_max&&Close[index]>Env_max)) return(true); else return(false);
                    }

  return(false);
  }

bool fun_main1 (string up_dn, int index)
 {
  double _b = EMPTY_VALUE;
  double _s = EMPTY_VALUE;

                    _b = iCustom(NULL, 0, name_ind1, bufferUP1, index);
                    _s = iCustom(NULL, 0, name_ind1, bufferDN1, index);
                     if(up_dn=="up")
                        {
                         if( _b!=EMPTY_VALUE && _b!=0 ) return(true); else return(false);
                         }
                     if(up_dn=="dn")
                        {
                         if( _s!=EMPTY_VALUE && _s!=0 ) return(true); else return(false);
                         }
  return(false);
  }

bool fun_main2 (string up_dn, int index)
 {
  double _b = EMPTY_VALUE;
  double _s = EMPTY_VALUE;

                    _b = iCustom(NULL, 0, name_ind2, bufferUP2, index);
                    _s = iCustom(NULL, 0, name_ind2, bufferDN2, index);
                     if(up_dn=="up")
                        {
                         if( _b!=EMPTY_VALUE && _b!=0 ) return(true); else return(false);
                         }
                     if(up_dn=="dn")
                        {
                         if( _s!=EMPTY_VALUE && _s!=0 ) return(true); else return(false);
                         }
  return(false);
  }

bool fun_main3 (string up_dn, int index)
 {
  double _b = EMPTY_VALUE;
  double _s = EMPTY_VALUE;

                    _b = iCustom(NULL, 0, name_ind3, bufferUP3, index);
                    _s = iCustom(NULL, 0, name_ind3, bufferDN3, index);
                     if(up_dn=="up")
                        {
                         if( _b!=EMPTY_VALUE && _b!=0 ) return(true); else return(false);
                         }
                     if(up_dn=="dn")
                        {
                         if( _s!=EMPTY_VALUE && _s!=0 ) return(true); else return(false);
                         }
  return(false);
  }

bool hour_trade(int index)
 {
   if(h<1) return(true);
   int index_hour;
   for(index_hour=0; index_hour<h; index_hour++)
       {
        if(time_type==0) //если разрешить
           {
            if(TimeHour(Time[index])==StrToInteger(result_hour[index_hour])) return(true);
            }
        if(time_type==1) //если запретить
           {
            if(TimeHour(Time[index])==StrToInteger(result_hour[index_hour])) return(false);
            }
        }
    if(time_type==0) return(false); else return(true);
  }

bool minut_trade(int index)
 {
   if(m<1) return(true);
   int index_minut;
   for(index_minut=0; index_minut<m; index_minut++)
       {
        if(TimeMinute(Time[index])==StrToInteger(result_minut[index_minut])) return(true);
        }
     return(false);
  }


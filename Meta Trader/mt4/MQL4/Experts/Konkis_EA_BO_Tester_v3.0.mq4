//+------------------------------------------------------------------+
//|                 Konkistadorr Empty EA for Binary Option test.mq4 |
//|                            Copyright 2017, Konkistadorr          |
//|                                                                  |
//| This is a Free EA, given to community (BinaryOptionsEdge)        |
//| People can modify it, share it, but never sell it.               |
//| Email : konkistadorr@gmail.com                                   |
//+------------------------------------------------------------------+

/*

v3.0:
   - Fix Hold function bugs (Minimum candle to wait before opening a new trade)
   - Fix Martingale bugs in the win rate calculation
   - Add parameter for Martingale : Next Signal or Next Candle
   - Add Statistics after backtest end in the Expert tab
   - Add simple indicator test by giving the indicator name and buffers (put & call)
   - Fix possible crashes
   
v2.1:
   - Adding multiple trades at the same time
   
v2.0:
   - Adding news library to avoid trading during news release time
   - Fix second candle entry : after a trade, the EA didn't take the next following candle as an entry. Fixed.
   
v1.5: 
   - Fix new bar issue

v 1.4:
   - Adding a line for entry price
   - Add Opening choice : Every Tick, or Candle Open
   - Add time of expiration : End of candle or Fixed time

v 1.3:
   - Time Management : Setting Start and Stop hours

v 1.2 :
   - fix bug on Candle Shift on Higher Time Frame
   - Add Martingale on Next Entry Candle
   - Improve HMI Text informations
   - Improve quick test when no visual mode

v 1.1 :
  - bug fix causing crash when total of trades was 0 : OK
  - Adding any time frame to backtest, not only M1 : OK
  - Journal to log the results instead of using visual mode : OK
  - Displaying the max consecutives wins/loss candles : OK
  
v 1.0 :
   - Simple backtest
   - HMI with : Wins, Losses, Draws and Win Rates
   - Arrows, Stops, and Check on chart
*/

#property copyright "Copyright 2017, Konkistadorr."
#property link      ""
#property version   "3.0"
#property strict

#include <KonkisNewsGrabber_v1.0.mqh>
//+------------------------------------------------------------------+
//| internal variables                           
//+------------------------------------------------------------------+
enum EntryType
  {
   EachTick=0,// Each Tick
   OpenOfCandle=1,// Open of new candle
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ExpirationType
  {
   FixedTime=0,       // Fixed Time (ex: 15 mins)
   EndOfCandle=1,     // End of Candle
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EMartingaleNextEntry
  {
   NextSignal=0,     // Next Signal
   NextCandle=1,     // Next Candle
  };

extern string mAccountTitle="  --== Account parameters ==--  ";
extern double mAccountBalance=100.0;// Account Balance
extern double mPayout=80;           // Binary Option Payout (Percent)
extern double mInvestment=1.0;      // Investment for each trade

extern string  cIndicatorTitle="  --== Simple Arrow Indicator settings ==--  ";
extern bool    cUseSimpleIndicator=false; // Enable use of simple arrow indicator
extern string  cIndicatorName="";  // Name of Indicator (without .mq4)
extern int     cIndicatorUpBuffer  =0;    // Up-buffer (CALL)
extern int     cIndicatorDownBuffer=1;    // Down-buffer (PUT)
extern int     cIndicatorShift=1;    // Indicator Shift

extern string mEntryTitle="  --== Entry & Expiry ==--  ";
input EntryType mEntryType=OpenOfCandle; // Entry type
input ExpirationType mExpirationType=EndOfCandle; // Expiration type
extern bool   mUseMultipleBet=true; // Allow Multiple bet at same time

extern string mCandleExpiryTitle="  --== Candle expiry ==--  ";
extern int    mNbCandlesExpiration=1; // Expiration After X Candles (1:Current for EndOfCandle)
extern int    mMinCandleBetweenTwoBets=0; // Hold: Min Number of Candles between trades

extern string mTimeExpiryTitle="  --== Time expiry (Fixed time) ==--  ";
extern int    mExpirationTime=5; // Expiration Time (Mins and for Fixed Time)

extern string cTimingString=" -------====== Time =======-------";
extern bool   cEnableTiming; // Enable Trading Time
extern double cStartingTime=0.0; // Starting Time (Ex : 16.10)
extern double cStopingTime=24.0; // Ending Time (Ex : 18.45)

extern string mMartingaleTitle="  --== Martingale ==--  ";
extern bool   mUseMartingale=false; // Use Martingale
extern EMartingaleNextEntry mMartingaleNextEntry=NextSignal; // Martingale next entry
extern int    mMartingaleMaxSteps=1;    // Max Consecutives trades
extern double mInvestment1 = 1.0;     // Investment on 1st Trade
extern double mInvestment2 = 3.0;     // Investment on 2nd Trade
extern double mInvestment3 = 8.0;     // Investment on 3rd Trade
extern double mInvestment4 = 18.0;    // Investment on 4th Trade
extern double mInvestment5 = 40.0;    // Investment on 5th Trade

extern string mNewsTimeTitle="  --== News Time ==--  ";
extern bool   cEnableNews; // Enable News Time
extern bool   cAvoidHighNews; // Avoid High News
extern bool   cAvoidMediumNews; // Avoid Medium News
extern bool   cAvoidLowNews; // Avoid Low News

extern int    cTimeZoneOffset=0; // GMT offset (hours)
extern int    cTimeBeforeNews= 15; // Time before news (mins)
extern int    cTimeAfterNews = 30; // Time after news (mins)

extern string mLogTitle="  --== Logs ==--  ";
extern bool   mUseLogs=false; // Enable Logs
extern bool   mEnableStats=true; // Enable Stats

//+------------------------------------------------------------------+
//| Local Variables                                                        |
//+------------------------------------------------------------------+

enum EBetStatus
  {
   eVoid=0,
   ePut=1,
   eCall=2
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct sBet
  {

   bool              mBetPending;
   // Bet Status : Call or Put
/*
    * : 1 Put in progress
    * : 2 Call in progress
   */
   EBetStatus        mBetStatus;
   double            mCallPrice;
   double            mPutPrice;

   datetime          mEntryTime;

   int               mCandleElapsed;

                     sBet () { mBetPending = false; mBetStatus=eVoid; mCallPrice= 0.0; mPutPrice = 0.0; mEntryTime=0; mCandleElapsed=0;}
                    ~sBet()  {  }
   void resetBet() {  mBetPending=false; mBetStatus=eVoid; mCallPrice=0.0; mPutPrice=0.0; mEntryTime=0; mCandleElapsed=0; }
  };

// Price value of the previous break (vbid price)
sBet  mBets[20];

int   mNbBetOpened=0;
bool  mAskForPendingReset=false;

//IHM variables
int   mSellOrderObjectsNumber= 0;
int   mBuyOrderObjectsNumber = 0;
int   mObjectsArrowStopNumber = 0;
int   mObjectsArrowCheckNumber=0;
int   mObjectsThumbUpNumber=0;
int   mLineObjectsNumber=0;

int   mMaxConsecutivesWins=0;
int   mMaxConsecutivesLosses=0;

int   mMaxConsecutivesWinsTemp=0;
int   mMaxConsecutivesLossesTemp=0;

int   mNbWins = 0;
int   mNbLoss = 0;
int   mNbDraws= 0;

// Martingale
int mMartingaleCurrentStep=1;
bool mOpenTradeOnNextCandle=false;
EBetStatus mOpenTradeOnNextCandleDirection=eVoid;

datetime New_Time=0;
datetime mLastTradeOpenTime=0;

double mTradingHoursWin[24];
double mTradingDaysWin[7];
double mTradingHoursLoss[24];
double mTradingDaysLoss[7];
double mTradingHoursDraw[24];
double mTradingDaysDraw[7];


//+------------------------------------------------------------------+
//|                   ENTRY POINTS !                                 |
//| PUT YOUR RULES HERE  :=)                                         |
//+------------------------------------------------------------------+
bool checkEntryPoint(bool  &pIsDirectionUp)
  {

//*****
// Refresh your indicators here
// Ex : double RSI4 = iRSI(NULL, 0, 4, PRICE_CLOSE, 0);
//*****  
   double upper = iBands(NULL, PERIOD_CURRENT, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double lower  =  iBands(NULL, PERIOD_CURRENT, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   
//****
// WRITE HERE THE CONDITION FOR OPENING A PUT Binary Otions
// Ex : if (RSI4<10.0)
//****
   if(Bid > upper)
     {
      pIsDirectionUp=false;
      return true;
     }

//****
// WRITE HERE THE CONDITION FOR OPENING A CALL BO
// Ex : if (RSI4>90.0)
//****
   if(Bid < lower)
     {
      pIsDirectionUp=true;
      return true;
     }

   return false;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   Print("---- Konkistadorr Robot for Binary Options -----");

// Charts customization
   ChartSetInteger(ChartID(),CHART_MODE,CHART_CANDLES);
   ChartSetInteger(ChartID(),CHART_COLOR_GRID,C'27,54,54');
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BEAR,clrDarkGray);
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BULL,clrLimeGreen);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_UP,clrLimeGreen);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_DOWN,clrGray);

   if(!ChartSetInteger(ChartID(),CHART_SCALE,0,4))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

// HUD Text
   displayText("Konkistadorr Binary Options Tester v3.0",0,clrCyan);

   if(mUseMartingale)
      displayTextDownLeft("Martingale : ON ("+IntegerToString(mMartingaleMaxSteps)+"), "+IntegerToString(mNbCandlesExpiration)+" Candle Exp : ",1,clrGray);
   else
      displayTextDownLeft("Martingale : OFF, Candle Exp : "+IntegerToString(mNbCandlesExpiration),1,clrGray);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   displayJournal();

//--- destroy timer
   EventKillTimer();
   Print("---- Konkistadorr Robot to test Binary Options...-----");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

// Check that there is enough data to test
   if(Bars<50)
     {
      return;
     }

// warning : calling twice new_bar in the same tick does not work
   bool lCheckBetResults=false;

   bool lNewBar=New_Bar();

   if(mExpirationType==EndOfCandle && lNewBar)
     {
      lCheckBetResults=true;
     }
   if(mExpirationType==FixedTime)
     {
      lCheckBetResults=true;
     }

// Only start trading at new bar opening
   if(lCheckBetResults)
     {

      int lNbBetToRemove=0;

      for(int i=0; i<mNbBetOpened; i++)
        {
         if(lNewBar)
           {
            mBets[i].mCandleElapsed++;
           }

         lCheckBetResults=false;

         if(mExpirationType==FixedTime && TimeCurrent()-mBets[i].mEntryTime>=(mExpirationTime*60))
           {
            lCheckBetResults=true;
           }

         if(mExpirationType==EndOfCandle && mBets[i].mCandleElapsed>=mNbCandlesExpiration)
           {
            lCheckBetResults=true;
           }

         //Print(" mCandleElapsed of "+i+" is "+mBets[i].mCandleElapsed);

         if(lCheckBetResults)
           {

            //Print(" Checking results "+i);

            //********
            //
            // Start checking Previous candles trade
            //
            //********
            if(mBets[i].mBetPending && mBets[i].mBetStatus==ePut)
              {

               mBets[i].mBetPending=false;
               lNbBetToRemove++;
               drawArrowDown(mBets[i].mCandleElapsed);

               // Now is the result : win or loose ?
               if(Close[1]<mBets[i].mPutPrice)
                 {
                  // Trade Won !
                  if(mUseMartingale)
                    {
                     if(mMartingaleCurrentStep==1) mAccountBalance=mAccountBalance+mInvestment1*(mPayout/100.0+1.0);
                     else if( mMartingaleCurrentStep == 2 ) mAccountBalance = mAccountBalance+mInvestment2*(mPayout/100.0+1.0);
                     else if( mMartingaleCurrentStep == 3 ) mAccountBalance = mAccountBalance+mInvestment3*(mPayout/100.0+1.0);
                     else if( mMartingaleCurrentStep == 4 ) mAccountBalance = mAccountBalance+mInvestment4*(mPayout/100.0+1.0);
                     else if( mMartingaleCurrentStep == 5 ) mAccountBalance = mAccountBalance+mInvestment5*(mPayout/100.0+1.0);
                    }
                  else
                    {
                     mAccountBalance=mAccountBalance+mInvestment*(mPayout/100.0+1.0);
                    }

                  if(mUseLogs) Print("  => Won : Account balance : "+DoubleToStr(mAccountBalance));

                  mNbWins=mNbWins+1;

                  mMartingaleCurrentStep=1;

                  // Stats
                  mTradingHoursWin[TimeHour(TimeCurrent())]=mTradingHoursWin[TimeHour(TimeCurrent())]+1;
                  mTradingDaysWin[TimeDayOfWeek(TimeCurrent())]=mTradingDaysWin[TimeDayOfWeek(TimeCurrent())]+1;

                  // Consecutives Wins
                  mMaxConsecutivesLossesTemp=0;
                  mMaxConsecutivesWinsTemp++;
                  if(mMaxConsecutivesWinsTemp>mMaxConsecutivesWins)
                    {
                     mMaxConsecutivesWins=mMaxConsecutivesWinsTemp;
                    }

                  drawArrowCheck(false);

                 }
               else if(Close[1]>mBets[i].mPutPrice)
                 {
                  //Trade Loss !!
                  if(mUseLogs) Print("  => Loose : Account balance : "+DoubleToStr(mAccountBalance));

                  drawArrowStop(false);

                  // Activate Martinagle on Next Candle
                  if(mUseMartingale && mMartingaleNextEntry==NextCandle && mMartingaleCurrentStep<mMartingaleMaxSteps)
                    {
                     mOpenTradeOnNextCandle=true;
                     mOpenTradeOnNextCandleDirection=ePut;
                    }
                  else
                    {
                     mNbLoss=mNbLoss+1;

                     mMartingaleCurrentStep++;
                     if(mMartingaleCurrentStep>mMartingaleMaxSteps)
                       {
                        mMartingaleCurrentStep=1; // One because we will enter a new trade here
                       }
                       
                     // Stats
                     mTradingHoursLoss[TimeHour(TimeCurrent())]=mTradingHoursLoss[TimeHour(TimeCurrent())]+1;
                     mTradingDaysLoss[TimeDayOfWeek(TimeCurrent())]=mTradingDaysLoss[TimeDayOfWeek(TimeCurrent())]+1;

                     // Consecutives losses
                     mMaxConsecutivesWinsTemp=0;
                     mMaxConsecutivesLossesTemp++;
                     if(mMaxConsecutivesLossesTemp>mMaxConsecutivesLosses)
                       {
                        mMaxConsecutivesLosses=mMaxConsecutivesLossesTemp;
                       }
                    }
                    
                     //Whatever happens : increase martingale step
                     mMartingaleCurrentStep++;
                     if(mMartingaleCurrentStep>mMartingaleMaxSteps)
                       {
                        mMartingaleCurrentStep=1; // One because we will enter a new trade here
                       }
                 }
               else
                 {
                  // Draw HERE : Start Again
                  if(mUseMartingale)
                    {
                     if(mMartingaleCurrentStep==1) mAccountBalance=mAccountBalance+mInvestment1;
                     else if( mMartingaleCurrentStep == 2 ) mAccountBalance = mAccountBalance+mInvestment2;
                     else if( mMartingaleCurrentStep == 3 ) mAccountBalance = mAccountBalance+mInvestment3;
                     else if( mMartingaleCurrentStep == 4 ) mAccountBalance = mAccountBalance+mInvestment4;
                     else if( mMartingaleCurrentStep == 5 ) mAccountBalance = mAccountBalance+mInvestment5;
                    }
                  else
                    {
                     mAccountBalance=mAccountBalance+mInvestment;
                    }

                  mNbDraws=mNbDraws+1;

                  // Stats
                  mTradingHoursDraw[TimeHour(TimeCurrent())]=mTradingHoursDraw[TimeHour(TimeCurrent())]+1;
                  mTradingDaysDraw[TimeDayOfWeek(TimeCurrent())]=mTradingDaysDraw[TimeDayOfWeek(TimeCurrent())]+1;

                  if(mUseLogs) Print("  => Draw : Account balance : "+DoubleToStr(mAccountBalance));

                  drawDraw(false);
                 }
              }
            else if
            (mBets[i].mBetPending && mBets[i].mBetStatus==eCall)
              {

               mBets[i].mBetPending=false;
               lNbBetToRemove++;
               drawArrowUp(mBets[i].mCandleElapsed);

               // Now is the result : win or loose ?
               if(Close[1]>mBets[i].mCallPrice)
                 {
                  // Trade Won !
                  if(mUseMartingale)
                    {
                     if(mMartingaleCurrentStep==1) mAccountBalance=mAccountBalance+mInvestment1*(mPayout/100.0+1.0);
                     else if( mMartingaleCurrentStep == 2 ) mAccountBalance = mAccountBalance+mInvestment2*(mPayout/100.0+1.0);
                     else if( mMartingaleCurrentStep == 3 ) mAccountBalance = mAccountBalance+mInvestment3*(mPayout/100.0+1.0);
                     else if( mMartingaleCurrentStep == 4 ) mAccountBalance = mAccountBalance+mInvestment4*(mPayout/100.0+1.0);
                     else if( mMartingaleCurrentStep == 5 ) mAccountBalance = mAccountBalance+mInvestment5*(mPayout/100.0+1.0);
                    }
                  else
                    {
                     mAccountBalance=mAccountBalance+mInvestment*(mPayout/100.0+1.0);
                    }

                  if(mUseLogs) Print("  => Won : Account balance : "+DoubleToStr(mAccountBalance));

                  mNbWins=mNbWins+1;

                  // Stats
                  mTradingHoursWin[TimeHour(TimeCurrent())]=mTradingHoursWin[TimeHour(TimeCurrent())]+1;
                  mTradingDaysWin[TimeDayOfWeek(TimeCurrent())]=mTradingDaysWin[TimeDayOfWeek(TimeCurrent())]+1;

                  mMartingaleCurrentStep=1;

                  // Consecutives wins
                  mMaxConsecutivesLossesTemp=0;
                  mMaxConsecutivesWinsTemp++;
                  if(mMaxConsecutivesWinsTemp>mMaxConsecutivesWins)
                    {
                     mMaxConsecutivesWins=mMaxConsecutivesWinsTemp;
                    }

                  drawArrowCheck(true);

                 }
               else if(Close[1]<mBets[i].mCallPrice)
                 {
                  // Trade loss !
                  if(mUseLogs) Print("  => Loose : Account balance : "+DoubleToStr(mAccountBalance));

                  drawArrowStop(true);

                  // Activate Martinagle on Next Candle
                  if(mUseMartingale && mMartingaleNextEntry==NextCandle && mMartingaleCurrentStep<mMartingaleMaxSteps)
                    {
                     mOpenTradeOnNextCandle=true;
                     mOpenTradeOnNextCandleDirection=eCall;
                    }
                  else
                    {
                     // Loose !
                     mNbLoss=mNbLoss+1;


                     // Stats
                     mTradingHoursLoss[TimeHour(TimeCurrent())]=mTradingHoursLoss[TimeHour(TimeCurrent())]+1;
                     mTradingDaysLoss[TimeDayOfWeek(TimeCurrent())]=mTradingDaysLoss[TimeDayOfWeek(TimeCurrent())]+1;

                     // Consecutives losses
                     mMaxConsecutivesWinsTemp=0;
                     mMaxConsecutivesLossesTemp++;
                     if(mMaxConsecutivesLossesTemp>mMaxConsecutivesLosses)
                       {
                        mMaxConsecutivesLosses=mMaxConsecutivesLossesTemp;
                       }
                    }
                    
                    //Whatever happens : increase martingale step
                     mMartingaleCurrentStep++;
                     if(mMartingaleCurrentStep>mMartingaleMaxSteps)
                       {
                        mMartingaleCurrentStep=1; // One because we will enter a new trade here
                       }

                 }
               else
                 {
                  // Draw HERE : Start Again
                  if(mUseMartingale)
                    {
                     if(mMartingaleCurrentStep==1) mAccountBalance=mAccountBalance+mInvestment1;
                     else if( mMartingaleCurrentStep == 2 ) mAccountBalance = mAccountBalance+mInvestment2;
                     else if( mMartingaleCurrentStep == 3 ) mAccountBalance = mAccountBalance+mInvestment3;
                     else if( mMartingaleCurrentStep == 4 ) mAccountBalance = mAccountBalance+mInvestment4;
                     else if( mMartingaleCurrentStep == 5 ) mAccountBalance = mAccountBalance+mInvestment5;
                    }
                  else
                    {
                     mAccountBalance=mAccountBalance+mInvestment;
                    }

                  mNbDraws=mNbDraws+1;

                  // Stats
                  mTradingHoursDraw[TimeHour(TimeCurrent())]=mTradingHoursDraw[TimeHour(TimeCurrent())]+1;
                  mTradingDaysDraw[TimeDayOfWeek(TimeCurrent())]=mTradingDaysDraw[TimeDayOfWeek(TimeCurrent())]+1;

                  if(mUseLogs) Print("  => Draw : Account balance : "+DoubleToStr(mAccountBalance));

                  drawDraw(true);
                 }

              }
           }
         else
           {
            //Print(" Skip the candle !");
           }
        }

      // Delete ended bet here
      for(int j=0; j<lNbBetToRemove; j++)
        {
         // Move all bets in array if one bet need to be deleted : first one must be deleted
         moveAllBets();
        }
     }

//
//
//  CHECK NEW ENTRY HERE
//
//

// Martingale entry on next candle does not match with the EachTick option...
   if(mMartingaleNextEntry==NextCandle && mOpenTradeOnNextCandle)
     {
      // Check if there is already an Order in progres..
      bool lCheckEntry=false;
      if(mEntryType==OpenOfCandle && lNewBar)
         lCheckEntry=true;

      if(lCheckEntry)
        {
         mOpenTradeOnNextCandle=false;
         openTrade(mOpenTradeOnNextCandleDirection);
        }
     }
// Entry on Signal only if number of maximum bets is not reached
   else  if((mUseMultipleBet && mNbBetOpened<20) || (!mUseMultipleBet && mNbBetOpened<1))
     {
      // Check if there is already an Order in progres..
      bool lCheckEntry=false;
      if( mEntryType == EachTick )
         lCheckEntry = true;
      else if(mEntryType==OpenOfCandle && lNewBar)
         lCheckEntry=true;

      if(lCheckEntry)
        {

         bool lIsDuringReleaseTime=false;
         if(cEnableNews)
           {
            isItNewsReleaseTime(cAvoidHighNews,cAvoidMediumNews,cAvoidLowNews,cTimeZoneOffset,cTimeBeforeNews,cTimeAfterNews,lIsDuringReleaseTime);
           }

         // Current server time : store it as double ( integer : hours / decimal : minutes)
         double lCurrentTime=Hour()+Minute()/100; // Current time
         if((!cEnableTiming || (lCurrentTime>=cStartingTime && lCurrentTime<=cStopingTime)) && (!lIsDuringReleaseTime))
           {
            bool lIsDirectionUp;
            
            bool lEntryFound=false;
            if (cUseSimpleIndicator)
               lEntryFound = checkEntryOnSimpleIndicator(lIsDirectionUp);
            else
               lEntryFound = checkEntryPoint(lIsDirectionUp);

            if(lEntryFound)
              {

               // Minimum number of candles since last trades
               bool lAllowTrade=false;
               if(TimeCurrent()>mLastTradeOpenTime+(mMinCandleBetweenTwoBets*PeriodSeconds()))
                 {
                  lAllowTrade=true;
                 }

               if(lAllowTrade)
                 {
                  openTrade(lIsDirectionUp ? eCall : ePut);
                 }
              }
           }
         else
           {
            // Print (" Trading out of hours");
           }
        }
     }

   displayHMI();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openTrade(EBetStatus pDirection)
  {

//Reset candle timer
   mBets[mNbBetOpened].resetBet();
   mBets[mNbBetOpened].mCandleElapsed=0;

   mBets[mNbBetOpened].mEntryTime=TimeCurrent();
   mBets[mNbBetOpened].mBetPending=true;

   mBets[mNbBetOpened].mBetStatus=pDirection;

   if
   (pDirection==eCall)
     {
      // Store the "Call" Price : warning don't forget there is a time between NOW and the order proceed time
      mBets[mNbBetOpened].mCallPrice=Bid;

      // Create line on chart when entry is not at the beginning of the candle
      drawEntryLine(true);
     }
   else
     {
      // Store the "Put" Price : warning don't forget there is a time between NOW and the order proceed time
      mBets[mNbBetOpened].mPutPrice=Bid;

      // Create line on chart when entry is not at the beginning of the candle
      drawEntryLine(false);
     }

// Increase number of bets
   mNbBetOpened++;
   mLastTradeOpenTime=iTime(Symbol(),Period(),0);

//*********
//Decrease Account balance : Martingale or not ?
//*********
   if(mUseMartingale)
     {
      if(mMartingaleCurrentStep==1) mAccountBalance=mAccountBalance-mInvestment1;
      else if( mMartingaleCurrentStep == 2 ) mAccountBalance=mAccountBalance-mInvestment2;
      else if( mMartingaleCurrentStep == 3 ) mAccountBalance=mAccountBalance-mInvestment3;
      else if( mMartingaleCurrentStep == 4 ) mAccountBalance=mAccountBalance-mInvestment4;
      else if( mMartingaleCurrentStep == 5 ) mAccountBalance=mAccountBalance-mInvestment5;
     }
   else
     {
      mAccountBalance=mAccountBalance-mInvestment;
     }
  }
//+------------------------------------------------------------------+
//| Display HMI on Chart window                                              |
//+------------------------------------------------------------------+
void displayHMI()
  {
   displayText("Balance  : "+DoubleToStr(mAccountBalance,2),1,clrYellow);
   displayText("Wins     : "+IntegerToString(mNbWins),2,clrYellow);
   displayText("Losses   : "+IntegerToString(mNbLoss),3,clrYellow);
   displayText("Draws    : "+IntegerToString(mNbDraws),4,clrYellow);
   displayText("Consec. W/L : "+IntegerToString(mMaxConsecutivesWins)+"/"+IntegerToString(mMaxConsecutivesLosses),5,clrYellow);

   double ltotal=mNbWins+mNbLoss+mNbDraws;

   if(ltotal-mNbDraws!=0)
     {
      double lWinRate=mNbWins/(ltotal-mNbDraws)*100.0;
      displayText("Win Rate : "+DoubleToStr(lWinRate,2)+" %",6,clrYellow);
     }
   else
     {
      displayText("Win Rate : "+DoubleToStr(0.0,2)+" %",6,clrYellow);
     }
  }
//+------------------------------------------------------------------+
//| Display Journal in the log window to avoid using visual mode     |
//+------------------------------------------------------------------+
void displayJournal()
  {
   double ltotal=mNbWins+mNbLoss+mNbDraws;
   double lWinRate=0.0;

   if(ltotal-mNbDraws!=0)
      lWinRate=mNbWins/(ltotal-mNbDraws)*100.0;
      
   Print(" Balance : "+DoubleToStr(mAccountBalance)+" Wins : "+IntegerToString(mNbWins)+" Losses : "+IntegerToString(mNbLoss)+" Draws : "+IntegerToString(mNbDraws)+" Win Rate : "+DoubleToStr(lWinRate,2));
   if(mEnableStats)
     {
      // Print all stats hours / days
      Print(" Hours stats ");
      int i= 0;
      for(i=0; i < 24; i++)
        {
         double lTotal=mTradingHoursWin[i]+mTradingHoursLoss[i]+mTradingHoursDraw[i];
         if(lTotal>0)
            Print(" Hours "+DoubleToStr(i,0)+" wins : "+DoubleToStr(mTradingHoursWin[i],0)+" loss : "+DoubleToStr(mTradingHoursLoss[i],0)+" draws : "+DoubleToStr(mTradingHoursDraw[i],0)+" winrate : "+DoubleToStr((mTradingHoursWin[i]/(lTotal)*100.0),2));
         else
            Print(" Hours : "+DoubleToStr(i,0)+" : 0 trades");
        }
      // Print all stats hours / days
      Print(" Days stats ");
      i=0;
      for(i=1; i<6; i++)
        {
         double lTotal=mTradingDaysWin[i]+mTradingDaysLoss[i]+mTradingDaysDraw[i];
         if(lTotal>0)
            Print(" Days "+DoubleToStr(i,0)+" wins : "+DoubleToStr(mTradingDaysWin[i],0)+" loss : "+DoubleToStr(mTradingDaysLoss[i],0)+" draws : "+DoubleToStr(mTradingDaysDraw[i],0)+" winrate : "+DoubleToStr((mTradingDaysWin[i]/(lTotal)*100.0),2));
         else
            Print(" Days : "+DoubleToStr(i,0)+" : 0 trades");
        }
     }
  }
//
//*********
// UTILITIES FUNCTIONS
//********
//
bool checkEntryOnSimpleIndicator(bool  &pIsDirectionUp)
{
   
   double call=iCustom(Symbol(),PERIOD_CURRENT,cIndicatorName,cIndicatorUpBuffer,cIndicatorShift);
   double put=iCustom(Symbol(),PERIOD_CURRENT,cIndicatorName,cIndicatorDownBuffer,cIndicatorShift);
   
//****
   if(put != EMPTY_VALUE && put != 0.0)
     {
      pIsDirectionUp=false;
      return true;
     }

//****
   if(call != EMPTY_VALUE && call != 0.0)
     {
      pIsDirectionUp=true;
      return true;
     }

   return false;

}

//+------------------------------------------------------------------+
//| Move all bets -1 to remove first one                          |
//+------------------------------------------------------------------+
void moveAllBets()
  {
   for(int i=1; i<mNbBetOpened; i++)
     {
      mBets[i-1]=mBets[i];
     }
   mNbBetOpened--;
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
bool New_Bar()
  {
   if(New_Time!=iTime(Symbol(),Period(),0))
     {
      New_Time=iTime(Symbol(),Period(),0);
      return(true);
     }
   else return(false);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void drawArrowDown(int pCandleElapsed)
  {
   ObjectCreate("Down"+IntegerToString(mSellOrderObjectsNumber),OBJ_ARROW_DOWN,0,Time[pCandleElapsed],High[pCandleElapsed]+10*Point);
   ObjectSetInteger(ChartID(),"Down"+IntegerToString(mSellOrderObjectsNumber),OBJPROP_COLOR,clrYellow);
   ObjectSet("Down"+IntegerToString(mSellOrderObjectsNumber),OBJPROP_WIDTH,2);
   mSellOrderObjectsNumber++;
  }
//+------------------------------------------------------------------+
void drawArrowUp(int pCandleElapsed)
  {
   ObjectCreate("Up"+IntegerToString(mBuyOrderObjectsNumber),OBJ_ARROW_UP,0,Time[pCandleElapsed],Low[pCandleElapsed]-5*Point);
   ObjectSetInteger(ChartID(),"Up"+IntegerToString(mBuyOrderObjectsNumber),OBJPROP_COLOR,clrTurquoise);
   ObjectSet("Up"+IntegerToString(mBuyOrderObjectsNumber),OBJPROP_WIDTH,2);
   mBuyOrderObjectsNumber++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawArrowStop(bool pDrawTop)
  {
   double lObjectPrice;
   if(pDrawTop) lObjectPrice=High[1]+8.0*Point;
   else lObjectPrice=Low[1]-5.0*Point;

   mObjectsArrowStopNumber++;

   if(!ObjectCreate(ChartID(),"Stop"+IntegerToString(mObjectsArrowStopNumber),OBJ_ARROW_STOP,0,Time[1],lObjectPrice))
     {
      Print("Error: can't create label! code #",GetLastError());
     }
   else
     {
      ObjectSet("Stop"+IntegerToString(mObjectsArrowStopNumber),OBJPROP_COLOR,clrRed);
      ObjectSet("Stop"+IntegerToString(mObjectsArrowStopNumber),OBJPROP_WIDTH,2);
      ObjectSet("Stop"+IntegerToString(mObjectsArrowStopNumber),OBJPROP_BACK,false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawArrowCheck(bool pDrawTop)
  {
   double lObjectPrice;
   if(pDrawTop) lObjectPrice=High[1]+8.0*Point;
   else lObjectPrice=Low[1]-5.0*Point;
   mObjectsArrowCheckNumber++;

   if(!ObjectCreate(ChartID(),"Pouce"+IntegerToString(mObjectsArrowCheckNumber),OBJ_ARROW_CHECK,0,Time[1],lObjectPrice))
     {
      Print("Error: can't create label! code #",GetLastError());
     }
   else
     {
      ObjectSet("Pouce"+IntegerToString(mObjectsArrowCheckNumber),OBJPROP_COLOR,clrGold);
      ObjectSet("Pouce"+IntegerToString(mObjectsArrowCheckNumber),OBJPROP_WIDTH,2);
      ObjectSet("Pouce"+IntegerToString(mObjectsArrowCheckNumber),OBJPROP_BACK,false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawDraw(bool pDrawTop)
  {
   double lObjectPrice;
   if(pDrawTop) lObjectPrice=High[1]+8.0*Point;
   else lObjectPrice=Low[1]-5.0*Point;
   mObjectsArrowCheckNumber++;

   if(!ObjectCreate(ChartID(),"Pouce"+IntegerToString(mObjectsArrowCheckNumber),OBJ_ARROW_STOP,0,Time[1],lObjectPrice))
     {
      Print("Error: can't create label! code #",GetLastError());
     }
   else
     {
      ObjectSet("Pouce"+IntegerToString(mObjectsArrowCheckNumber),OBJPROP_COLOR,clrBlue);
      ObjectSet("Pouce"+IntegerToString(mObjectsArrowCheckNumber),OBJPROP_WIDTH,2);
      ObjectSet("Pouce"+IntegerToString(mObjectsArrowCheckNumber),OBJPROP_BACK,false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+ 
void drawEntryLine(bool pIsCall)
  {
   string objName="Line"+IntegerToString(mLineObjectsNumber);

   if(!ObjectCreate(ChartID(),objName,OBJ_RECTANGLE,0,Time[1],Bid,Time[0],Bid))
     {
      Print(" Creation of line yellow failed : "+IntegerToString(GetLastError()));
     }
   else
     {
      mLineObjectsNumber++;
      if(pIsCall)
        {
         ObjectSetInteger(ChartID(),objName,OBJPROP_COLOR,clrBlue);
         ObjectSetInteger(ChartID(),objName,OBJPROP_BGCOLOR,clrBlue);
        }
      else
        {
         ObjectSetInteger(ChartID(),objName,OBJPROP_COLOR,clrYellow);
         ObjectSetInteger(ChartID(),objName,OBJPROP_BGCOLOR,clrYellow);
        }
      ObjectSetInteger(ChartID(),objName,OBJPROP_BACK,false);
      ObjectSetInteger(ChartID(),objName,OBJPROP_WIDTH,2);

     }
  }
//+------------------------------------------------------------------+
void displayText(string pText,int pPosition,color pColor=clrWhite)
  {
   string obj_name="Text"+IntegerToString(pPosition);

   ObjectCreate(ChartID(),obj_name,OBJ_LABEL,0,0,0);
   ObjectSetString(ChartID(),obj_name,OBJPROP_TEXT,pText);
   ObjectSet(obj_name,OBJPROP_XDISTANCE,10.0);
   ObjectSet(obj_name,OBJPROP_YDISTANCE,pPosition*15.0+30.0);
   ObjectSet(obj_name,OBJPROP_COLOR,pColor);
  }
//+------------------------------------------------------------------+
void displayTextRight(string pText,int pRightPosition,color pColor=clrWhite)
  {
   string obj_name="TextRight"+IntegerToString(pRightPosition);

   ObjectCreate(ChartID(),obj_name,OBJ_LABEL,0,0,0);
   ObjectSetString(ChartID(),obj_name,OBJPROP_TEXT,pText);
   ObjectSetInteger(ChartID(),obj_name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSet(obj_name,OBJPROP_XDISTANCE,-50.0);
   ObjectSet(obj_name,OBJPROP_YDISTANCE,pRightPosition*20.0);
   ObjectSet(obj_name,OBJPROP_COLOR,pColor);
  }
//+------------------------------------------------------------------+
void displayTextDownLeft(string pText,int pPosition,color pColor=clrWhite)
  {
   string obj_name="TextDown"+IntegerToString(pPosition);

   ObjectCreate(ChartID(),obj_name,OBJ_LABEL,0,0,0);
   ObjectSetString(ChartID(),obj_name,OBJPROP_TEXT,pText);
   ObjectSet(obj_name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSet(obj_name,OBJPROP_XDISTANCE,10.0);
   ObjectSet(obj_name,OBJPROP_YDISTANCE,pPosition*20.0);
   ObjectSet(obj_name,OBJPROP_COLOR,pColor);
  }
//+------------------------------------------------------------------+

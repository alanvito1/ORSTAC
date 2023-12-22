//+------------------------------------------------------------------+
//|                                       KonkisNewsGrabber_v1.0.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+----------------------------------------------------------------+
#import "KonkisNewsGrabber_v1.0.ex4"

/* 
* Description : isItNewsReleaseTime
*
*  news :
*  newsToTrade :
*  grabHigh :
*  grabMedium :
*  grabLow :
*  symbol :
*/
bool isItNewsReleaseTime(bool pTradeHighNews,bool pTradeMediumNews,bool pTradeLowNews,int pTimeZoneGMT,int pTimeBeforeNews,int pTimeAfterNews,bool  &pIsDuringReleaseTime);

#import 
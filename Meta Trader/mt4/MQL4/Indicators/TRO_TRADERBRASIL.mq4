//+------------------------------------------------------------------+ 
//|   TRO_WATERMARK                                                  | 
//|                                                                  | 
//|   Copyright © 2011, Avery T. Horton, Jr. aka TheRumpledOne       |
//|                                                                  |
//|   PO BOX 43575, TUCSON, AZ 85733                                 |
//|                                                                  |
//|   GIFTS AND DONATIONS ACCEPTED                                   | 
//|   All my indicators should be considered donationware. That is   |
//|   you are free to use them for your personal use, and are        |
//|   under no obligation to pay for them. However, if you do find   |
//|   this or any of my other indicators help you with your trading  |
//|   then any Gift or Donation as a show of appreciation is         |
//|   gratefully accepted.                                           |
//|                                                                  |
//|   Gifts or Donations also keep me motivated in producing more    |
//|   great free indicators. :-)                                     |
//|                                                                  |
//|   PayPal - THERUMPLEDONE@GMAIL.COM                               |  
//+------------------------------------------------------------------+ 
//| Use http://therumpledone.mbtrading.com/forex.aspx                |  
//| as your forex broker...tell them therumpledone sent you!         |  
//+------------------------------------------------------------------+ 

#property  copyright "Copyright © 2011, Avery T. Horton, Jr. aka TRO" 
#property  link      "http://www.therumpledone.com/" 


#property indicator_chart_window
 
 
extern int    myChartX   = 250 ;
extern int    myChartY   = 180 ;
extern int    myCorner   = 0 ;
extern string myFont     = "Impact" ;
extern int    myFontSize = 180 ;
extern color  myColor    = C'30,33,36' ;  


   string tObjName04   = "TROWMTAG2"  ;
   string tObjName03    = "TROTAG"  ;  
    
//+------------------------------------------------------------------+
int init()
  { 
  
    
            

   ObjectDelete(tObjName04);  
   ObjectCreate(tObjName04, OBJ_LABEL, 0, 0, 0); 
   ObjectSetText(tObjName04, Symbol() , myFontSize ,myFont  ,  myColor );
   ObjectSet(tObjName04, OBJPROP_CORNER, myCorner);
   ObjectSet(tObjName04, OBJPROP_XDISTANCE, myChartX);
   ObjectSet(tObjName04, OBJPROP_YDISTANCE, myChartY ); 
   ObjectSet(tObjName04, OBJPROP_BACK,true);   
   


   ObjectCreate(tObjName03, OBJ_LABEL, 0, 0, 0);//HiLow LABEL
   ObjectSetText(tObjName03, CharToStr(78) , 12 ,  "Wingdings",  DimGray );
   ObjectSet(tObjName03, OBJPROP_CORNER, 3);
   ObjectSet(tObjName03, OBJPROP_XDISTANCE, 5 );
   ObjectSet(tObjName03, OBJPROP_YDISTANCE, 5 );     
   
   
   return(0);
  } 
//+------------------------------------------------------------------+
int deinit()
  {
        
   ObjectDelete(tObjName04);  
  
   return(0);
  }

//+------------------------------------------------------------------+  
  
int start()
  {
   
 

   return(0);
  }
 

//+------------------------------------------------------------------+
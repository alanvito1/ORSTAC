#property copyright "CatturaPip <info@catturapip.com>"
#property link      "http://www.catturapip.com"

#property indicator_chart_window

#import "Cerbero.dll"
   double aaa(int a0, double a1, double a2);
// double aaaa(int a0, double a1, double a2, double a3);
// double aaaaa(int a0, double a1, double a2, double a3, double a4);
   double bbb(int a0, double a1, double a2);
   double ccc(int a0, double a1, double a2);
// double cccc(int a0, double a1, double a2, double a3);
// double ccccc(int a0, double a1, double a2, double a3, double a4);
   double ddd(int a0, double a1, double a2);
// string eee(int a0, string a1, string a2);
// string eeee(int a0, string a1, string a2, string a3);
   string eeeee(int a0, string a1, string a2, string a3, string a4);
// int xxx(int a0);
// double test_aaa(int a0, double a1, double a2);
#import

int gi_84;
bool gi_100 = FALSE;
double gd_104 = 0.0;
string gs_116 = "update.html";
int g_str2int_200 = 1024;
int g_str2int_204 = 768;
double gda_216[];
double gda_220[];
double gda_224[];
int gia_228[];
double gd_232 = 0.0;
double gd_240 = 0.0;
double gd_248 = 0.0;
double gd_256 = 0.0;
double gd_264 = 0.0;
double gd_272 = 0.0;
int g_arr_size_280 = 0;
extern string look_back = "120";
int g_str2int_292 = WHOLE_ARRAY;
extern int look_forward = 24;
int gi_300 = 0;
extern int max_history = 1440;
extern string correlation_data = "OHLC";
extern double cor_threshold = 75.0;
bool gi_324 = FALSE;
extern int select_best_correlations = 50;
bool gi_332 = TRUE;
double gd_336 = 0.2;
int gi_344 = 1;
extern string display_options = "TABR";
extern color avg_projection_color = Tomato;
extern color best_projection_color = Yellow;
extern int text_size = 10;
extern string text_font = "Segoe UI";
bool gi_376 = FALSE;
extern string window_screenshot = "0";
int g_str2int_388 = -1;
int g_count_392 = -1;
int g_str2int_396 = -1;
bool gi_400 = FALSE;
bool gi_404 = FALSE;
bool gi_408 = FALSE;
bool gi_412 = FALSE;
bool gi_416 = FALSE;
bool gi_420 = FALSE;
bool gi_424 = FALSE;
bool gi_428 = FALSE;
bool gi_432 = FALSE;
int gi_436 = 0;
int g_datetime_440 = 0;
int g_timeframe_444;
double gda_452[][7];
double gda_456[][7];
int g_count_460 = 0;
int g_count_464 = 0;
int g_count_468 = 0;
int g_count_472 = 0;
bool gba_476[7] = {0, 0, 0, 0, 0, 0, 0};
double gd_480 = -100.0;
double gd_488 = 0.0;
double gd_496 = -100.0;
double gd_504 = -100.0;
double gd_512 = -100.0;
double gd_520 = 0.0;
int g_count_528 = 0;
int gi_532;
int gi_536;
int gi_540 = 1;
double gda_544[];
double gda_548[];
double gda_552[];
double gda_556[];
double gda_560[];
double gda_564[];
double gda_568[];
double gda_572[];
double gda_576[];
double gda_580[];
double gda_584[][1000];
double gda_588[][1000];
double gda_592[];
double gda_596[];
double gda_600[];
int gi_604 = 0;
double gd_608;
double gd_616;
double gd_624 = 1.0;
double gd_632 = 1.0;
bool gi_640 = FALSE;
int g_count_644 = 0;
double gd_648 = 0.0;
double gd_656 = 0.0;
double gd_664 = 0.0;
double gd_672 = 0.0;
double gd_680 = 0.0;
double g_point_688 = 0.0;
double gda_696[4];
double gd_700 = 0.0;
string gs_708;
bool gi_716 = FALSE;
bool gi_720 = TRUE;
int gi_724;
double gd_728 = 0.0;
double gd_736 = 0.0;

double f0_22(double ad_0, double ad_8) {
   return (aaa(gi_84, ad_0, ad_8));
}

double f0_37(double ad_0, double ad_8) {
   return (bbb(gi_84, ad_0, ad_8));
}

double f0_25(double ad_0, double ad_8) {
   return (ccc(gi_84, ad_0, ad_8));
}

double f0_15(double ad_0, double ad_8) {
   return (ddd(gi_84, ad_0, ad_8));
}

string f0_12(string as_0, string as_8, string as_16, string as_24) {
   return (eeeee(gi_84, as_0, as_8, as_16, as_24));
}

int f0_31(string as_0, string as_8, string &asa_16[], int ai_20 = 0) {
   int li_24;
   int li_28;
   int li_32;
   if (StringFind(as_0, as_8) < 0) {
      ArrayResize(asa_16, 1);
      asa_16[0] = as_0;
   } else {
      li_24 = 0;
      li_28 = 0;
      li_32 = 0;
      while (li_28 > -1) {
         li_32++;
         li_28 = StringFind(as_0, as_8, li_24);
         ArrayResize(asa_16, li_32);
         if (li_28 > -1) {
            if (li_28 - li_24 > 0) asa_16[li_32 - 1] = StringSubstr(as_0, li_24, li_28 - li_24);
         } else asa_16[li_32 - 1] = StringSubstr(as_0, li_24, 0);
         li_24 = li_28 + 1;
      }
   }
   if (ai_20 == 0 || ai_20 == ArraySize(asa_16)) return (1);
   return (0);
}

void f0_13(double ad_0, string as_8 = "update.html") {
   gd_104 = ad_0;
   gs_116 = as_8;
}

int f0_20() {
   string lsa_0[];
   string lsa_16[];
   gi_720 = TRUE;
   gi_724 = Bars;
   if (Point > 0.0) {
      g_point_688 = Point;
      if (g_point_688 == 0.001) {
         g_point_688 = 0.01;
         Print("Init: my_pip_value = ", DoubleToStr(g_point_688, 2));
      }
      if (g_point_688 == 0.00001) {
         g_point_688 = 0.0001;
         Print("Init: my_pip_value = ", DoubleToStr(g_point_688, 4));
      }
   } else {
      if (StringFind(Symbol(), "JPY") == -1) {
         g_point_688 = 0.0001;
         Print("Init: my_pip_value = ", DoubleToStr(g_point_688, 4));
      } else {
         g_point_688 = 0.01;
         Print("Init: my_pip_value = ", DoubleToStr(g_point_688, 2));
      }
   }
   if (f0_31(look_back, ";", lsa_0, 0)) {
      g_arr_size_280 = ArraySize(lsa_0);
      if (g_arr_size_280 == 1) g_str2int_292 = StrToInteger(lsa_0[0]);
      if (g_arr_size_280 > 1) {
         ArrayResize(gia_228, g_arr_size_280);
         ArrayResize(gda_216, g_arr_size_280);
         ArrayResize(gda_220, g_arr_size_280);
         ArrayResize(gda_224, g_arr_size_280);
         for (int li_4 = 0; li_4 < g_arr_size_280; li_4++) {
            gia_228[li_4] = StrToInteger(lsa_0[li_4]);
            Print("lookback_array[i] = ", gia_228[li_4]);
         }
         ObjectCreate("FuturoFX_LONG", OBJ_HLINE, 0, 0, 0);
         ObjectCreate("FuturoFX_SHORT", OBJ_HLINE, 0, 0, 0);
      }
   }
   if (g_str2int_292 <= WHOLE_ARRAY) g_str2int_292 = 10;
   if (look_forward <= 0) look_forward = 1;
   gi_540 = 1;
   if (gi_300 > 0) gi_540 = 0;
   if (cor_threshold < 0.0) {
      gi_404 = TRUE;
      cor_threshold = MathAbs(cor_threshold);
      Print("Init: Specular Correlation is enabled");
   }
   g_timeframe_444 = Period();
   
   gi_436 = 0;
   g_datetime_440 = TimeCurrent();
   while (gi_436 <= g_datetime_440) gi_436 += 60 * g_timeframe_444;
   gi_436 -= 60 * g_timeframe_444;
   ArrayResize(gda_544, look_forward);
   ArrayResize(gda_548, look_forward);
   ArrayResize(gda_552, look_forward);
   ArrayResize(gda_556, look_forward);
   ArrayResize(gda_560, look_forward);
   ArrayResize(gda_564, look_forward);
   ArrayResize(gda_568, look_forward);
   ArrayResize(gda_572, look_forward);
   ArrayResize(gda_576, look_forward);
   ArrayResize(gda_580, look_forward);
   if (select_best_correlations > 0) {
      if (select_best_correlations > 1000) {
         select_best_correlations = 1000;
         Alert("FuturoFX: max value for select_best_correlations is ", 1000);
      }
      ArrayResize(gda_584, look_forward);
      ArrayResize(gda_588, look_forward);
      ArrayResize(gda_592, select_best_correlations);
      f0_16();
      ArrayResize(gda_596, look_forward);
      ArrayResize(gda_600, look_forward);
   }
   for (li_4 = 0; li_4 < StringLen(display_options); li_4++) {
      switch (StringGetChar(display_options, li_4)) {
      case 'A':
         Print("Init: Average Correlation enabled on screen [A]");
         gi_412 = TRUE;
         break;
      case 'B':
         Print("Init: Best Correlation enabled on screen [B]");
         gi_416 = TRUE;
         break;
      case 'C':
         Print("Init: Centers of Mass enabled on screen [C]");
         gi_428 = TRUE;
         break;
      case 'O':
         Print("Init: Outliers enabled on screen [0]");
         gi_420 = TRUE;
         break;
      case 'S':
         Print("Init: Standard Deviation enabled on screen [S]");
         gi_432 = TRUE;
         break;
      case 'T':
         Print("Init: Textual Interface enabled on screen [T]");
         gi_408 = TRUE;
         break;
      case 'R':
         Print("Init: Rectangles enabled on screen [R]");
         gi_424 = TRUE;
         break;
      default:
         Alert("FuturoFX: display option [", StringSubstr(display_options, li_4, 1), "] is not supported");
      }
   }
   for (li_4 = 0; li_4 < look_forward; li_4++) {
      if (gi_412) {
         if (gi_344 == 0) {
            ObjectCreate("FuturoFX_H" + li_4, OBJ_ARROW, 0, 0, 0);
            ObjectSet("FuturoFX_H" + li_4, OBJPROP_ARROWCODE, 159);
            ObjectSet("FuturoFX_H" + li_4, OBJPROP_COLOR, Green);
            ObjectSet("FuturoFX_H" + li_4, OBJPROP_WIDTH, 3);
            ObjectCreate("FuturoFX_L" + li_4, OBJ_ARROW, 0, 0, 0);
            ObjectSet("FuturoFX_L" + li_4, OBJPROP_ARROWCODE, 159);
            ObjectSet("FuturoFX_L" + li_4, OBJPROP_COLOR, Red);
            ObjectSet("FuturoFX_L" + li_4, OBJPROP_WIDTH, 3);
         }
         if (gi_344 == 1) {
            ObjectCreate("FuturoFX_HL" + li_4, OBJ_RECTANGLE, 0, 0, 0);
            ObjectSet("FuturoFX_HL" + li_4, OBJPROP_BACK, TRUE);
            ObjectSet("FuturoFX_HL" + li_4, OBJPROP_COLOR, avg_projection_color);
         }
      }
      if (gi_420) {
         ObjectCreate("FuturoFX_HH" + li_4, OBJ_ARROW, 0, 0, 0);
         ObjectSet("FuturoFX_HH" + li_4, OBJPROP_ARROWCODE, SYMBOL_STOPSIGN);
         ObjectSet("FuturoFX_HH" + li_4, OBJPROP_COLOR, Green);
         ObjectSet("FuturoFX_HH" + li_4, OBJPROP_WIDTH, 1);
         ObjectCreate("FuturoFX_LL" + li_4, OBJ_ARROW, 0, 0, 0);
         ObjectSet("FuturoFX_LL" + li_4, OBJPROP_ARROWCODE, SYMBOL_STOPSIGN);
         ObjectSet("FuturoFX_LL" + li_4, OBJPROP_COLOR, Red);
         ObjectSet("FuturoFX_LL" + li_4, OBJPROP_WIDTH, 1);
      }
      if (gi_416) {
         if (gi_344 == 0) {
            ObjectCreate("FuturoFX_BB" + li_4, OBJ_TREND, 0, 0, 0);
            ObjectSet("FuturoFX_BB" + li_4, OBJPROP_RAY, FALSE);
            ObjectSet("FuturoFX_BB" + li_4, OBJPROP_COLOR, best_projection_color);
            ObjectSet("FuturoFX_BB" + li_4, OBJPROP_WIDTH, 2);
         }
         if (gi_344 == 1) {
            ObjectCreate("FuturoFX_BB" + li_4, OBJ_RECTANGLE, 0, 0, 0);
            ObjectSet("FuturoFX_BB" + li_4, OBJPROP_BACK, FALSE);
            ObjectSet("FuturoFX_BB" + li_4, OBJPROP_COLOR, best_projection_color);
         }
      }
      if (gi_424) {
         if (ObjectCreate("FuturoFX_REC", OBJ_RECTANGLE, 0, 0, 0)) {
            if (gi_344 == 0) {
               ObjectSet("FuturoFX_REC", OBJPROP_BACK, TRUE);
               ObjectSet("FuturoFX_REC", OBJPROP_COLOR, CadetBlue);
            }
            if (gi_344 == 1) {
               ObjectSet("FuturoFX_REC", OBJPROP_BACK, FALSE);
               ObjectSet("FuturoFX_REC", OBJPROP_COLOR, Red);
            }
         }
         if (ObjectCreate("FuturoFX_REC2", OBJ_RECTANGLE, 0, 0, 0)) {
            if (gi_344 == 0) {
               ObjectSet("FuturoFX_REC2", OBJPROP_BACK, TRUE);
               ObjectSet("FuturoFX_REC2", OBJPROP_COLOR, CornflowerBlue);
            }
            if (gi_344 == 1) {
               ObjectSet("FuturoFX_REC2", OBJPROP_BACK, FALSE);
               ObjectSet("FuturoFX_REC2", OBJPROP_COLOR, Red);
            }
         }
      }
      if (gi_428) {
         if (ObjectCreate("FuturoFX_BAR", OBJ_TREND, 0, 0, 0)) {
            ObjectSet("FuturoFX_BAR", OBJPROP_RAY, FALSE);
            ObjectSet("FuturoFX_BAR", OBJPROP_COLOR, Violet);
            ObjectSet("FuturoFX_BAR", OBJPROP_WIDTH, 2);
         }
         if (ObjectCreate("FuturoFX_BAR2", OBJ_TREND, 0, 0, 0)) {
            ObjectSet("FuturoFX_BAR2", OBJPROP_RAY, FALSE);
            ObjectSet("FuturoFX_BAR2", OBJPROP_COLOR, best_projection_color);
            ObjectSet("FuturoFX_BAR2", OBJPROP_WIDTH, 2);
         }
         if (ObjectCreate("FuturoFX_BAR3", OBJ_TREND, 0, 0, 0)) {
            ObjectSet("FuturoFX_BAR3", OBJPROP_RAY, FALSE);
            ObjectSet("FuturoFX_BAR3", OBJPROP_COLOR, Violet);
            ObjectSet("FuturoFX_BAR3", OBJPROP_STYLE, STYLE_DASH);
         }
      }
      if (gi_432) {
         ObjectCreate("FuturoFX_SH" + li_4, OBJ_ARROW, 0, 0, 0);
         ObjectSet("FuturoFX_SH" + li_4, OBJPROP_ARROWCODE, 159);
         ObjectSet("FuturoFX_SH" + li_4, OBJPROP_COLOR, Green);
         ObjectSet("FuturoFX_SH" + li_4, OBJPROP_WIDTH, 1);
         ObjectCreate("FuturoFX_SL" + li_4, OBJ_ARROW, 0, 0, 0);
         ObjectSet("FuturoFX_SL" + li_4, OBJPROP_ARROWCODE, 159);
         ObjectSet("FuturoFX_SL" + li_4, OBJPROP_COLOR, Red);
         ObjectSet("FuturoFX_SL" + li_4, OBJPROP_WIDTH, 1);
      }
   }
   g_count_472 = 0;
   for (li_4 = 0; li_4 < StringLen(correlation_data); li_4++) {
      switch (StringGetChar(correlation_data, li_4)) {
      case 'O':
         Print("Init: Correlation performed on Open data [O]");
         g_count_472++;
         gba_476[1] = 1;
         break;
      case 'H':
         Print("Init: Correlation performed on High data [H]");
         g_count_472++;
         gba_476[2] = 1;
         break;
      case 'L':
         Print("Init: Correlation performed on Low data [L]");
         g_count_472++;
         gba_476[3] = 1;
         break;
      case 'C':
         Print("Init: Correlation performed on Close data [C]");
         g_count_472++;
         gba_476[0] = 1;
         break;
      case 'M':
         Print("Init: Correlation performed on Median data [M]");
         g_count_472++;
         gba_476[4] = 1;
         break;
      case 'T':
         Print("Init: Correlation performed on Typical data [T]");
         g_count_472++;
         gba_476[5] = 1;
         break;
      case 'W':
         Print("Init: Correlation performed on Weighted data [W]");
         g_count_472++;
         gba_476[6] = 1;
         break;
      default:
         Alert("FuturoFX: correlation data [", StringSubstr(correlation_data, li_4, 1), "] is not supported");
      }
   }
   if (select_best_correlations <= 0) {
      gi_432 = FALSE;
      Print("Init: Standard Deviation disabled on screen (select_best_correlations=0)");
   }
   if (max_history > 0) gi_724 = max_history;
   if (g_arr_size_280 == 1) {
      for (li_4 = gi_724; li_4 > g_str2int_292 * 2; li_4--) gi_604++;
      Print("Init: correlations_performed = ", gi_604);
   }
   if (gd_336 < 0.0) gd_336 = 0;
   if (gi_332 || gd_336 > 0.0) gi_640 = TRUE;
   f0_31(window_screenshot, ";", lsa_16);
   if (ArraySize(lsa_16) == 3) {
      g_str2int_200 = StrToInteger(lsa_16[1]);
      g_str2int_204 = StrToInteger(lsa_16[2]);
   }
   if (ArraySize(lsa_16) >= 1) {
      if (StringSubstr(lsa_16[0], 0, 1) == "H") {
         g_str2int_396 = StrToInteger(StringSubstr(lsa_16[0], 1, 0));
         if (g_str2int_396 >= 0 && g_str2int_396 <= 23) {
            gi_400 = TRUE;
            Print("Init: screenshot_hour = ", g_str2int_396);
         }
      } else {
         g_str2int_388 = StrToInteger(lsa_16[0]);
         if (g_str2int_388 > 0) {
            gi_400 = TRUE;
            Print("Init: screenshot_bars = ", g_str2int_388);
         }
      }
      if (gi_400) {
         Print("Init: screenshot_size_x = ", g_str2int_200);
         Print("Init: screenshot_size_y = ", g_str2int_204);
      }
   }
   if (g_arr_size_280 == 1) {
      f0_26();
      f0_3();
      f0_14();
   }
   if (g_arr_size_280 > 1) {
      f0_28();
      f0_0();
   }
   return (0);
}

int f0_30() {
   bool li_0 = TRUE;
   if (li_0) {
      for (int count_4 = 0; count_4 < look_forward; count_4++) {
         ObjectDelete("FuturoFX_H" + count_4);
         ObjectDelete("FuturoFX_L" + count_4);
         ObjectDelete("FuturoFX_HH" + count_4);
         ObjectDelete("FuturoFX_SH" + count_4);
         ObjectDelete("FuturoFX_LL" + count_4);
         ObjectDelete("FuturoFX_SL" + count_4);
         ObjectDelete("FuturoFX_BB" + count_4);
         ObjectDelete("FuturoFX_HL" + count_4);
      }
      ObjectDelete("FuturoFX_REC");
      ObjectDelete("FuturoFX_REC2");
      ObjectDelete("FuturoFX_BAR");
      ObjectDelete("FuturoFX_BAR2");
      ObjectDelete("FuturoFX_BAR3");
      ObjectDelete("FuturoFX_BestMatches_Score");
      ObjectDelete("FuturoFX_BestMatches_Num");
      ObjectDelete("FuturoFX_Average_Score");
      ObjectDelete("FuturoFX_Average_Num");
      ObjectDelete("FuturoFX_Best_Score");
      ObjectDelete("FuturoFX_Avg_Confidence");
      ObjectDelete("FuturoFX_Channel_Width");
      ObjectDelete("FuturoFX_LONG");
      ObjectDelete("FuturoFX_SHORT");
      for (int count_8 = 0; count_8 < 10; count_8++) {
         for (int count_12 = 0; count_12 < 100; count_12++) {
            ObjectDelete("FuturoFX_BKG" + count_8 + count_12);
            ObjectDelete("FuturoFX_BKG" + count_8 + ((count_12 + 1)));
            ObjectDelete("FuturoFX_BKG" + count_8 + ((count_12 + 2)));
         }
      }
      Comment("");
   }
   return (0);
}

int f0_2() {
   g_count_644++;
   g_datetime_440 = TimeCurrent();
   gi_724 = Bars;
   if (max_history > 0) gi_724 = max_history;
   bool li_0 = FALSE;
   if (g_datetime_440 >= gi_436) {
      li_0 = TRUE;
      while (gi_436 <= g_datetime_440) gi_436 += 60 * g_timeframe_444;
   }
   if (li_0 || (gi_300 > 0 && g_count_644 == gi_300)) {
      if (g_arr_size_280 == 1) {
         f0_26();
         f0_3();
         f0_14();
         g_count_644 = 0;
      }
      if (g_arr_size_280 > 1) {
         f0_27();
         f0_28();
         f0_0();
         g_count_644 = 0;
      }
   }
   if (li_0 && g_str2int_388 > 0) {
      g_count_392++;
      if (g_count_392 % g_str2int_388 == FALSE) {
         g_count_392 = 0;
         f0_4();
      }
   }
   if (li_0 && g_str2int_396 >= 0)
      if (g_str2int_396 == Hour()) f0_4();
   return (0);
}

void f0_26() {
   double lda_0[] = {0};
   f0_29(lda_0, g_str2int_292);
}

void f0_27() {
   for (int index_0 = 0; index_0 < g_arr_size_280; index_0++) {
      double lda_4[] = {0, 0, 0};
      f0_29(lda_4, gia_228[index_0]);
      gda_216[index_0] = lda_4[0];
      gda_220[index_0] = lda_4[1];
      gda_224[index_0] = lda_4[2];
   }
   double ld_8 = 0;
   double ld_16 = 0;
   double ld_24 = 0;
   for (index_0 = 0; index_0 < g_arr_size_280; index_0++) {
      ld_8 += gda_216[index_0];
      ld_16 += gda_220[index_0] * gda_216[index_0];
      ld_24 += gda_224[index_0] * gda_216[index_0];
   }
   gd_232 = ld_16 / ld_8;
   gd_240 = ld_24 / ld_8;
   gd_248 = gd_232 - gd_240;
   gd_272 = ld_8 / g_arr_size_280;
   gd_256 = Open[0] + gd_232 * g_point_688;
   gd_264 = Open[0] + gd_240 * g_point_688;
}

void f0_28() {
   ObjectSet("FuturoFX_LONG", OBJPROP_PRICE1, gd_256);
   ObjectSet("FuturoFX_SHORT", OBJPROP_PRICE1, gd_264);
   ObjectDelete("FuturoFX_Avg_Confidence");
   ObjectCreate("FuturoFX_Avg_Confidence", OBJ_TEXT, 0, Time[0], gd_256);
   ObjectSetText("FuturoFX_Avg_Confidence", "                          " + DoubleToStr(gd_272, 1) + "% confidence", 10, text_font, Red);
   ObjectDelete("FuturoFX_Channel_Width");
   ObjectCreate("FuturoFX_Channel_Width", OBJ_TEXT, 0, Time[0], gd_264);
   ObjectSetText("FuturoFX_Channel_Width", "               " + DoubleToStr(gd_248, 1) + " pips", 10, text_font, Red);
}

void f0_4() {
   if (WindowScreenShot(f0_34() + ".gif", g_str2int_200, g_str2int_204) == FALSE) Print("WindowScreenShot Failed: ", GetLastError());
}

string f0_34() {
   string ls_0 = Year();
   ls_0 = ls_0 + "-";
   if (Month() < 10) ls_0 = ls_0 + "0";
   ls_0 = ls_0 + Month() + "-";
   if (Day() < 10) ls_0 = ls_0 + "0";
   ls_0 = ls_0 + Day() + "_";
   if (Hour() < 10) ls_0 = ls_0 + "0";
   ls_0 = ls_0 + Hour();
   if (Minute() < 10) ls_0 = ls_0 + "0";
   ls_0 = ls_0 + Minute();
   string ls_8 = "NA";
   switch (Period()) {
   case PERIOD_M1:
      ls_8 = "M1";
      break;
   case PERIOD_M5:
      ls_8 = "M5";
      break;
   case PERIOD_M15:
      ls_8 = "M15";
      break;
   case PERIOD_M30:
      ls_8 = "M30";
      break;
   case PERIOD_H1:
      ls_8 = "H1";
      break;
   case PERIOD_H4:
      ls_8 = "H4";
      break;
   case PERIOD_D1:
      ls_8 = "D1";
      break;
   case PERIOD_W1:
      ls_8 = "W1";
      break;
   case PERIOD_MN1:
      ls_8 = "MN1";
   }
   return ("FuturoFX\\" + Symbol() + "_" + ls_8 + "\\" + Symbol() + "_" + ls_8 + "_" + ls_0);
}

void f0_29(double &ada_0[], int ai_4) {
   double ld_92;
   int li_100;
   bool li_104;
   double ld_unused_108;
   ArrayResize(gda_452, ai_4);
   ArrayResize(gda_456, ai_4);
   double ld_8 = 0.0;
   double ld_16 = 0.0;
   double ld_24 = 0.0;
   double ld_32 = 0.0;
   double ld_40 = 0.0;
   double ld_48 = 0.0;
   double ld_56 = 0.0;
   gd_480 = -100;
   gd_488 = 0;
   gi_536 = 0;
   gd_496 = -100;
   g_count_460 = 0;
   g_count_464 = 0;
   g_count_468 = 0;
   double ld_64 = 0.0;
   double ld_72 = 0.0;
   for (int index_80 = 0; index_80 <= 6; index_80++)
      if (gba_476[index_80]) f0_23(index_80, ai_4);
   if (gi_640) gd_608 = f0_37(High[iHighest(Symbol(), 0, MODE_HIGH, ai_4, gi_540)], Low[iLowest(Symbol(), 0, MODE_LOW, ai_4, gi_540)]);
   for (int index_84 = 0; index_84 < look_forward; index_84++) {
      gda_544[index_84] = 0.0;
      gda_548[index_84] = 0.0;
      gda_552[index_84] = 0.0;
      gda_556[index_84] = 0.0;
      gda_560[index_84] = 0.0;
      gda_564[index_84] = 0.0;
      gda_596[index_84] = 0.0;
      gda_600[index_84] = 0.0;
   }
   f0_16();
   if (Bars >= gi_724) {
      for (int index_88 = gi_724; index_88 > ai_4 * 2; index_88--) {
         ld_64 = 0.0;
         for (index_80 = 0; index_80 <= 6; index_80++) {
            if (gba_476[index_80]) {
               f0_33(index_80, index_88, ai_4);
               ld_92 = f0_7(index_80, ai_4);
               if (gi_324) {
                  if (f0_32(ld_92)) {
                     ld_64 += ld_92;
                     continue;
                  }
                  ld_64 = 0;
                  break;
               }
               ld_64 += ld_92;
            }
         }
         f0_38(g_count_472, "num_correlations_data");
         ld_64 /= g_count_472;
         if (gi_640) {
            gd_616 = High[iHighest(Symbol(), 0, MODE_HIGH, ai_4, index_88 - ai_4 + 1)] - Low[iLowest(Symbol(), 0, MODE_LOW, ai_4, index_88 - ai_4 + 1)];
            if (gi_332) {
               f0_38(gd_616, "old_range");
               gd_624 = f0_15(gd_608, gd_616);
            }
            if (gd_336 > 0.0) {
               f0_38(gd_616, "old_range");
               gd_632 = f0_22(1.0, f0_25(gd_336, MathAbs(f0_17(f0_15(gd_608, gd_616)))));
            }
         }
         f0_38(gd_632, "volatility_quotient");
         ld_64 = f0_15(ld_64, gd_632);
         ld_72 = MathAbs(ld_64 / 100.0);
         if (f0_32(ld_64)) {
            g_count_460++;
            ld_8 += ld_72;
            if (ld_64 > 0.0) {
               g_count_464++;
               ld_16 += ld_72;
            } else {
               g_count_468++;
               ld_24 -= ld_72;
            }
            if (gi_376) Print("Correlation = ", DoubleToStr(ld_64, 2), " at index i = ", index_88, " [", TimeToStr(Time[index_88], TIME_DATE|TIME_MINUTES), "]");
            li_100 = -1;
            if (select_best_correlations > 0) li_100 = f0_10(MathAbs(ld_64));
            li_104 = FALSE;
            if (MathAbs(ld_64) > gd_480) {
               gd_488 = ld_64;
               gd_480 = MathAbs(ld_64);
               gi_536 = index_88;
               gi_532 = Time[index_88];
               li_104 = TRUE;
            }
            for (index_84 = 0; index_84 < look_forward; index_84++) {
               ld_48 = f0_25(gd_624, f0_37(High[index_88 - ai_4 - index_84], Close[index_88 - ai_4 + 1]));
               ld_56 = f0_25(gd_624, f0_37(Low[index_88 - ai_4 - index_84], Close[index_88 - ai_4 + 1]));
               if (ld_64 > 0.0) {
                  ld_32 = ld_48;
                  ld_40 = ld_56;
               } else {
                  ld_32 = -ld_56;
                  ld_40 = -ld_48;
               }
               if (li_104) {
                  gda_560[index_84] = ld_32;
                  gda_564[index_84] = ld_40;
               }
               if (select_best_correlations > 0) {
                  if (li_100 >= 0) {
                     gda_584[index_84][li_100] = ld_32;
                     gda_588[index_84][li_100] = ld_40;
                  }
               } else {
                  gda_544[index_84] += ld_72 * ld_32;
                  gda_548[index_84] += ld_72 * ld_40;
               }
               gda_552[index_84] = MathMax(gda_552[index_84], ld_32);
               gda_556[index_84] = MathMin(gda_556[index_84], ld_40);
            }
         }
      }
   }
   gd_700 = 0.0;
   gd_648 = 0.0;
   gd_656 = 0.0;
   gd_664 = 0.0;
   gd_672 = 1000000.0;
   gd_680 = 1000000.0;
   gd_728 = 0.0;
   gd_736 = 0.0;
   gd_700 = 0.0;
   if (g_count_460 > 0) {
      if (select_best_correlations > 0) f0_19();
      else {
         for (index_84 = 0; index_84 < look_forward; index_84++) {
            f0_38(ld_8, "cor_matches_over_threshold_sum");
            gda_544[index_84] = f0_15(gda_544[index_84], ld_8);
            gda_548[index_84] = f0_15(gda_548[index_84], ld_8);
         }
      }
      for (index_84 = 0; index_84 < look_forward; index_84++) {
         if (gda_560[index_84] > gd_728) gd_728 = gda_560[index_84];
         if (gda_564[index_84] < gd_736) gd_736 = gda_564[index_84];
      }
      gd_728 /= g_point_688;
      gd_736 /= g_point_688;
      ada_0[1] = gd_728;
      ada_0[2] = gd_736;
      f0_38(g_count_460, "cor_matches_over_threshold");
      gd_496 = 100.0 * f0_15(ld_8, g_count_460);
      if (g_count_464 > 0) gd_504 = 100.0 * f0_15(ld_16, g_count_464);
      if (g_count_468 > 0) gd_512 = 100.0 * f0_15(ld_24, g_count_468);
      ld_unused_108 = 0.0;
      for (index_84 = 0; index_84 < look_forward; index_84++) {
         gd_648 += f0_22(gda_544[index_84], gda_548[index_84]) / 2.0;
         gd_656 += f0_22(gda_560[index_84], gda_564[index_84]) / 2.0;
      }
      f0_38(look_forward, "look_forward");
      gd_648 = f0_15(gd_648, look_forward);
      gd_656 = f0_15(gd_656, look_forward);
      gd_664 = f0_22(gd_648, gd_656) / 2.0;
      gda_696[0] = gd_520;
      gda_696[1] = gd_480;
      gda_696[2] = g_count_460;
      if (gda_696[2] > 100.0) gda_696[2] = 100;
      gda_696[3] = f0_8();
      for (index_88 = 0; index_88 < 4; index_88++) gd_700 += gda_696[index_88];
      gd_700 /= 4.0;
      ada_0[0] = gd_700;
   }
}

int f0_10(double ad_0) {
   for (int index_8 = 0; index_8 < select_best_correlations; index_8++) {
      if (gda_592[index_8] == -100.0) {
         gda_592[index_8] = ad_0;
         return (index_8);
      }
   }
   int li_ret_12 = ArrayMinimum(gda_592);
   double ld_16 = gda_592[li_ret_12];
   if (ad_0 > ld_16) {
      gda_592[li_ret_12] = ad_0;
      return (li_ret_12);
   }
   return (-1);
}

void f0_16() {
   g_count_528 = 0;
   for (int index_0 = 0; index_0 < select_best_correlations; index_0++) gda_592[index_0] = -100.0;
}

void f0_19() {
   double lda_32[];
   double lda_36[];
   double ld_0 = 0.0;
   double ld_8 = 0.0;
   double ld_16 = 0.0;
   for (int index_24 = 0; index_24 < select_best_correlations; index_24++) {
      ld_8 = gda_592[index_24];
      ld_16 = ld_8 / 100.0;
      if (f0_32(ld_8)) {
         ld_0 += ld_16;
         g_count_528++;
      }
   }
   if (g_count_528 > 0) {
      f0_38(g_count_528, "bestmatches_number");
      gd_520 = 100.0 * ld_0 / g_count_528;
      for (int index_28 = 0; index_28 < look_forward; index_28++) {
         gda_544[index_28] = 0.0;
         gda_548[index_28] = 0.0;
         for (index_24 = 0; index_24 < select_best_correlations; index_24++) {
            ld_8 = gda_592[index_24];
            ld_16 = ld_8 / 100.0;
            if (f0_32(ld_8)) {
               gda_544[index_28] += ld_16 * gda_584[index_28][index_24];
               gda_548[index_28] += ld_16 * gda_588[index_28][index_24];
            }
         }
         f0_38(ld_0, "cor_bestmatches_sum");
         gda_544[index_28] = f0_15(gda_544[index_28], ld_0);
         gda_548[index_28] = f0_15(gda_548[index_28], ld_0);
      }
      ArrayResize(lda_32, look_forward);
      ArrayResize(lda_36, look_forward);
      for (index_28 = 0; index_28 < look_forward; index_28++) {
         lda_32[index_28] = 0.0;
         lda_36[index_28] = 0.0;
         for (index_24 = 0; index_24 < select_best_correlations; index_24++) {
            ld_8 = gda_592[index_24];
            if (f0_32(ld_8)) {
               lda_32[index_28] += gda_584[index_28][index_24];
               lda_36[index_28] += gda_588[index_28][index_24];
            }
         }
         f0_38(g_count_528, "bestmatches_number");
         lda_32[index_28] = lda_32[index_28] / g_count_528;
         lda_36[index_28] = lda_36[index_28] / g_count_528;
      }
      for (index_28 = 0; index_28 < look_forward; index_28++) {
         gda_596[index_28] = 0.0;
         gda_600[index_28] = 0.0;
         for (index_24 = 0; index_24 < select_best_correlations; index_24++) {
            ld_8 = gda_592[index_24];
            ld_16 = ld_8 / 100.0;
            if (f0_32(ld_8)) {
               gda_596[index_28] += MathPow(gda_584[index_28][index_24] - lda_32[index_28], 2);
               gda_600[index_28] += MathPow(gda_588[index_28][index_24] - lda_36[index_28], 2);
            }
         }
         f0_38(g_count_528, "bestmatches_number");
         gda_596[index_28] = MathSqrt(gda_596[index_28] / g_count_528);
         gda_600[index_28] = MathSqrt(gda_600[index_28] / g_count_528);
      }
      gd_672 = 0.0;
      gd_680 = 0.0;
      for (index_28 = 0; index_28 < look_forward; index_28++) {
         gd_672 += gda_596[index_28];
         gd_680 += gda_600[index_28];
      }
      f0_38(g_point_688 * look_forward, "my_pip_value*look_forward");
      gd_672 /= g_point_688 * look_forward;
      gd_680 /= g_point_688 * look_forward;
   }
}

int f0_32(double ad_0) {
   if (ad_0 >= cor_threshold) return (1);
   if (gi_404 && ad_0 <= (-cor_threshold)) return (1);
   return (0);
}

void f0_23(int ai_0, int ai_4) {
   for (int index_8 = 0; index_8 < ai_4; index_8++) {
      switch (ai_0) {
      case 0:
         gda_452[index_8][ai_0] = Close[index_8 + gi_540];
         break;
      case 1:
         gda_452[index_8][ai_0] = Open[index_8 + gi_540];
         break;
      case 2:
         gda_452[index_8][ai_0] = High[index_8 + gi_540];
         break;
      case 3:
         gda_452[index_8][ai_0] = Low[index_8 + gi_540];
         break;
      case 4:
         gda_452[index_8][ai_0] = (High[index_8 + gi_540] + (Low[index_8 + gi_540])) / 2.0;
         break;
      case 5:
         gda_452[index_8][ai_0] = (High[index_8 + gi_540] + (Low[index_8 + gi_540]) + (Close[index_8 + gi_540])) / 3.0;
         break;
      case 6:
         gda_452[index_8][ai_0] = (High[index_8 + gi_540] + (Open[index_8 + gi_540]) + (Low[index_8 + gi_540]) + (Close[index_8 + gi_540])) / 4.0;
         break;
      default:
         gda_452[index_8][ai_0] = 0.0;
      }
   }
}

void f0_33(int ai_0, int ai_4, int ai_8) {
   int li_12 = 0;
   for (int index_16 = 0; index_16 < ai_8; index_16++) {
      li_12 = index_16 + ai_4 - ai_8 + 1;
      switch (ai_0) {
      case 0:
         gda_456[index_16][ai_0] = Close[li_12];
         break;
      case 1:
         gda_456[index_16][ai_0] = Open[li_12];
         break;
      case 2:
         gda_456[index_16][ai_0] = High[li_12];
         break;
      case 3:
         gda_456[index_16][ai_0] = Low[li_12];
         break;
      case 4:
         gda_456[index_16][ai_0] = (High[li_12] + Low[li_12]) / 2.0;
         break;
      case 5:
         gda_456[index_16][ai_0] = (High[li_12] + Low[li_12] + Close[li_12]) / 3.0;
         break;
      case 6:
         gda_456[index_16][ai_0] = (High[li_12] + Open[li_12] + Low[li_12] + Close[li_12]) / 4.0;
         break;
      default:
         gda_456[index_16][ai_0] = 0.0;
      }
   }
}

void f0_3() {
   string ls_12;
   string ls_20;
   string dbl2str_28;
   string ls_36;
   int li_44;
   double ld_0 = Open[0];
   if (gi_540 == 0) ld_0 = Close[0];
   for (int index_8 = 0; index_8 < look_forward; index_8++) {
      if (gi_412) {
         if (gi_344 == 0) {
            ObjectSet("FuturoFX_H" + index_8, OBJPROP_TIME1, Time[0] + 60 * ((index_8 + 1 - gi_540) * g_timeframe_444));
            ObjectSet("FuturoFX_H" + index_8, OBJPROP_PRICE1, ld_0 + gda_544[index_8]);
            ObjectSet("FuturoFX_L" + index_8, OBJPROP_TIME1, Time[0] + 60 * ((index_8 + 1 - gi_540) * g_timeframe_444));
            ObjectSet("FuturoFX_L" + index_8, OBJPROP_PRICE1, ld_0 + gda_548[index_8]);
         }
         if (gi_344 == 1) {
            ObjectSet("FuturoFX_HL" + index_8, OBJPROP_TIME1, Time[0] + 60 * (index_8 * g_timeframe_444));
            ObjectSet("FuturoFX_HL" + index_8, OBJPROP_PRICE1, ld_0 + gda_544[index_8]);
            ObjectSet("FuturoFX_HL" + index_8, OBJPROP_TIME2, Time[0] + 60 * ((index_8 + 1) * g_timeframe_444));
            ObjectSet("FuturoFX_HL" + index_8, OBJPROP_PRICE2, ld_0 + gda_548[index_8]);
            ObjectSet("FuturoFX_HL" + index_8, OBJPROP_COLOR, avg_projection_color - 7 * index_8);
         }
         if (index_8 == look_forward - 1) {
            ls_12 = "";
            if (gi_536 > 0) ls_12 = DoubleToStr(gd_488, 2) + "%";
            if (select_best_correlations > 0) {
               ls_20 = "N/A";
               dbl2str_28 = "";
               if (g_count_528 > 0) {
                  ls_20 = DoubleToStr(gd_520, 2) + "%";
                  dbl2str_28 = DoubleToStr(g_count_528, 0);
               }
               ObjectDelete("FuturoFX_BestMatches_Score");
               ObjectCreate("FuturoFX_BestMatches_Score", OBJ_TEXT, 0, Time[0] + 60 * ((index_8 + 2) * g_timeframe_444), Close[1] + gda_544[index_8] / 2.0 + gda_548[index_8] / 2.0);
               ObjectSetText("FuturoFX_BestMatches_Score", "        " + ls_20, text_size, text_font, avg_projection_color);
               ObjectDelete("FuturoFX_BestMatches_Num");
               ObjectCreate("FuturoFX_BestMatches_Num", OBJ_TEXT, 0, Time[0] + 60 * ((index_8 + 2) * g_timeframe_444), Close[1] + gda_544[index_8]);
               ObjectSetText("FuturoFX_BestMatches_Num", "        " + dbl2str_28, text_size, text_font, avg_projection_color);
            } else {
               ls_36 = "N/A";
               li_44 = g_count_468 + g_count_464;
               if (li_44 > 0) ls_36 = DoubleToStr(gd_496, 2) + "%";
               ObjectDelete("FuturoFX_Average_Score");
               ObjectCreate("FuturoFX_Average_Score", OBJ_TEXT, 0, Time[0] + 60 * ((index_8 + 2) * g_timeframe_444), Close[1] + gda_544[index_8] / 2.0 + gda_548[index_8] / 2.0);
               ObjectSetText("FuturoFX_Average_Score", "        " + ls_36, text_size, text_font, avg_projection_color);
               ObjectDelete("FuturoFX_Average_Num");
               ObjectCreate("FuturoFX_Average_Num", OBJ_TEXT, 0, Time[0] + 60 * ((index_8 + 2) * g_timeframe_444), Close[1] + gda_544[index_8]);
               ObjectSetText("FuturoFX_Average_Num", "        " + li_44, text_size, text_font, avg_projection_color);
            }
            ObjectDelete("FuturoFX_Best_Score");
            ObjectCreate("FuturoFX_Best_Score", OBJ_TEXT, 0, Time[0] + 60 * ((index_8 + 2) * g_timeframe_444), Close[1] + gda_560[index_8] / 2.0 + gda_564[index_8] / 2.0);
            ObjectSetText("FuturoFX_Best_Score", "        " + ls_12, text_size, text_font, best_projection_color);
         }
      }
      if (gi_420) {
         ObjectSet("FuturoFX_HH" + index_8, OBJPROP_TIME1, Time[0] + 60 * ((index_8 + 1 - gi_540) * g_timeframe_444));
         ObjectSet("FuturoFX_HH" + index_8, OBJPROP_PRICE1, ld_0 + gda_552[index_8]);
         ObjectSet("FuturoFX_LL" + index_8, OBJPROP_TIME1, Time[0] + 60 * ((index_8 + 1 - gi_540) * g_timeframe_444));
         ObjectSet("FuturoFX_LL" + index_8, OBJPROP_PRICE1, ld_0 + gda_556[index_8]);
      }
      if (gi_416) {
         ObjectSet("FuturoFX_BB" + index_8, OBJPROP_TIME1, Time[0] + 60 * ((index_8 + 1 - gi_540) * g_timeframe_444));
         ObjectSet("FuturoFX_BB" + index_8, OBJPROP_TIME2, Time[0] + 60 * ((index_8 + 1 - gi_540) * g_timeframe_444));
         ObjectSet("FuturoFX_BB" + index_8, OBJPROP_PRICE1, Close[gi_540] + gda_564[index_8]);
         ObjectSet("FuturoFX_BB" + index_8, OBJPROP_PRICE2, Close[gi_540] + gda_560[index_8]);
      }
      if (gi_432) {
         ObjectSet("FuturoFX_SH" + index_8, OBJPROP_TIME1, Time[0] + 60 * ((index_8 + 1 - gi_540) * g_timeframe_444));
         ObjectSet("FuturoFX_SH" + index_8, OBJPROP_PRICE1, ld_0 + gda_544[index_8] + gda_596[index_8]);
         ObjectSet("FuturoFX_SL" + index_8, OBJPROP_TIME1, Time[0] + 60 * ((index_8 + 1 - gi_540) * g_timeframe_444));
         ObjectSet("FuturoFX_SL" + index_8, OBJPROP_PRICE1, ld_0 + gda_548[index_8] - gda_600[index_8]);
      }
   }
   if (gi_424) {
      ObjectSet("FuturoFX_REC", OBJPROP_TIME1, Time[g_str2int_292 - 1 + gi_540]);
      ObjectSet("FuturoFX_REC", OBJPROP_TIME2, Time[gi_540]);
      ObjectSet("FuturoFX_REC", OBJPROP_PRICE1, Low[iLowest(Symbol(), 0, MODE_LOW, g_str2int_292, gi_540)]);
      ObjectSet("FuturoFX_REC", OBJPROP_PRICE2, High[iHighest(Symbol(), 0, MODE_HIGH, g_str2int_292, gi_540)]);
      if (gi_536 > 0) {
         ObjectSet("FuturoFX_REC2", OBJPROP_TIME1, Time[gi_536]);
         ObjectSet("FuturoFX_REC2", OBJPROP_TIME2, Time[gi_536 - g_str2int_292 + 1]);
         ObjectSet("FuturoFX_REC2", OBJPROP_PRICE1, Low[iLowest(Symbol(), 0, MODE_LOW, g_str2int_292, gi_536 - g_str2int_292 + 1)]);
         ObjectSet("FuturoFX_REC2", OBJPROP_PRICE2, High[iHighest(Symbol(), 0, MODE_HIGH, g_str2int_292, gi_536 - g_str2int_292 + 1)]);
      } else {
         ObjectSet("FuturoFX_REC2", OBJPROP_TIME1, Time[g_str2int_292]);
         ObjectSet("FuturoFX_REC2", OBJPROP_TIME2, Time[g_str2int_292]);
         ObjectSet("FuturoFX_REC2", OBJPROP_PRICE1, Close[g_str2int_292]);
         ObjectSet("FuturoFX_REC2", OBJPROP_PRICE2, Close[g_str2int_292]);
      }
   }
   if (gi_428) {
      ObjectSet("FuturoFX_BAR", OBJPROP_TIME1, Time[0] + 60 * ((1 - gi_540) * g_timeframe_444));
      ObjectSet("FuturoFX_BAR", OBJPROP_TIME2, Time[0] + 60 * ((look_forward - gi_540) * g_timeframe_444));
      ObjectSet("FuturoFX_BAR", OBJPROP_PRICE1, ld_0 + gd_648);
      ObjectSet("FuturoFX_BAR", OBJPROP_PRICE2, ld_0 + gd_648);
      ObjectSet("FuturoFX_BAR2", OBJPROP_TIME1, Time[0] + 60 * ((1 - gi_540) * g_timeframe_444));
      ObjectSet("FuturoFX_BAR2", OBJPROP_TIME2, Time[0] + 60 * ((look_forward - gi_540) * g_timeframe_444));
      ObjectSet("FuturoFX_BAR2", OBJPROP_PRICE1, ld_0 + gd_656);
      ObjectSet("FuturoFX_BAR2", OBJPROP_PRICE2, ld_0 + gd_656);
      ObjectSet("FuturoFX_BAR3", OBJPROP_TIME1, Time[0] + 60 * ((1 - gi_540) * g_timeframe_444));
      ObjectSet("FuturoFX_BAR3", OBJPROP_TIME2, Time[0] + 60 * ((look_forward - gi_540) * g_timeframe_444));
      ObjectSet("FuturoFX_BAR3", OBJPROP_PRICE1, ld_0 + gd_664);
      ObjectSet("FuturoFX_BAR3", OBJPROP_PRICE2, ld_0 + gd_664);
   }
}

double f0_7(int ai_0, int ai_4) {
   double ld_8 = 0.0;
   double ld_16 = 0.0;
   double ld_24 = 0.0;
   double ld_32 = 0.0;
   double ld_40 = 0.0;
   double ld_48 = 0.0;
   double ld_56 = 0.0;
   double ld_64 = 0.0;
   for (int index_72 = 0; index_72 < ai_4; index_72++) {
      ld_16 = gda_452[index_72][ai_0];
      ld_24 = gda_456[index_72][ai_0];
      ld_32 += ld_16;
      ld_40 += ld_24;
      ld_56 += ld_16 * ld_16;
      ld_64 += ld_24 * ld_24;
      ld_48 += ld_16 * ld_24;
   }
   double ld_76 = (ai_4 * ld_56 - MathPow(ld_32, 2)) * (ai_4 * ld_64 - MathPow(ld_40, 2));
   f0_38(ld_76, "temp_quotient");
   ld_8 = (ai_4 * ld_48 - ld_32 * ld_40) / MathSqrt(ld_76);
   return (100.0 * ld_8);
}

double f0_8() {
   int li_0 = look_forward;
   double ld_4 = 0.0;
   double ld_12 = 0.0;
   double ld_20 = 0.0;
   double ld_28 = 0.0;
   double ld_36 = 0.0;
   double ld_44 = 0.0;
   double ld_52 = 0.0;
   double ld_60 = 0.0;
   for (int index_68 = 0; index_68 < li_0; index_68++) {
      ld_12 = (gda_560[index_68] + gda_564[index_68]) / 2.0;
      ld_20 = (gda_544[index_68] + gda_548[index_68]) / 2.0;
      ld_28 += ld_12;
      ld_36 += ld_20;
      ld_52 += ld_12 * ld_12;
      ld_60 += ld_20 * ld_20;
      ld_44 += ld_12 * ld_20;
   }
   double ld_72 = (li_0 * ld_52 - MathPow(ld_28, 2)) * (li_0 * ld_60 - MathPow(ld_36, 2));
   f0_38(ld_72, "temp_quotient");
   ld_4 = (li_0 * ld_44 - ld_28 * ld_36) / MathSqrt(ld_72);
   return (100.0 * ld_4);
}

void f0_14() {
   string ls_0;
   string str_concat_8;
   string ls_16;
   string ls_24;
   string ls_32;
   string ls_40;
   string ls_unused_48;
   string ls_unused_56;
   string ls_64;
   double color_72;
   int li_88;
   if (gi_408) {
      ls_0 = "";
      str_concat_8 = "N/A";
      ls_16 = "";
      ls_24 = "";
      ls_32 = "";
      ls_40 = "";
      ls_unused_48 = "";
      ls_unused_56 = "";
      if (gi_536 > 0) {
         str_concat_8 = StringConcatenate(DoubleToStr(gd_488, 2), "% [", TimeToStr(gi_532, TIME_DATE|TIME_MINUTES), "]");
         if (gi_404) {
            ls_16 = " (" + DoubleToStr(gd_504, 2) + "%)";
            ls_24 = " (" + DoubleToStr(gd_512, 2) + "%)";
         } else ls_16 = " (" + DoubleToStr(gd_496, 2) + "%)";
      }
      if (gi_404) ls_32 = "\n  Correlation <= -" + DoubleToStr(cor_threshold, 1) + " : " + g_count_468 + " matches" + ls_24;
      if (gi_432 && g_count_528 > 0) ls_40 = "\n  Std Dev (pips) = " + DoubleToStr(gd_672, 1) + " on Highs, " + DoubleToStr(gd_680, 1) + " on Lows";
      ls_64 = "\n  Potential (pips): Long " + DoubleToStr(gd_728, 1) + " -- Short " + DoubleToStr(-gd_736, 1);
      f0_38(gi_604, "correlations_performed");
      ls_0 = ls_0 
         + "\n                 " + gs_708 
         + "\n                by www.pimpmyea.com" 
         + "\n -----------------------------------------------------------------" 
         + "\n  Current Open Time: " + TimeToStr(Time[0]) 
         + "\n  Candles analyzed: " + gi_724 + " out of " + Bars 
         + "\n  Correlations[" + g_str2int_292 + "] performed: " + gi_604 
         + "\n  Correlation >= " + DoubleToStr(cor_threshold, 1) + "% : " + g_count_464 + " matches" + ls_16 + ls_32 
         + "\n  Best correlation = " + str_concat_8 + ls_40 + ls_64 
         + "\n  CONFIDENCE SCORE = " + DoubleToStr(gd_700, 1) + "%" 
      + "\n -----------------------------------------------------------------";
      Comment(ls_0);
      if (select_best_correlations > 0) color_72 = f0_1(0, 0, 255, 0, 0, 0, 0, 100, gd_520);
      else color_72 = f0_1(0, 0, 255, 0, 0, 0, 0, 100, gd_496);
      if (gi_720 || Seconds() % 5 == 0) {
         for (int count_80 = 0; count_80 < 10; count_80++) {
            for (int count_84 = 0; count_84 < 100; count_84++) {
               ObjectDelete("FuturoFX_BKG" + count_80 + count_84);
               ObjectDelete("FuturoFX_BKG" + count_80 + ((count_84 + 1)));
               ObjectDelete("FuturoFX_BKG" + count_80 + ((count_84 + 2)));
            }
         }
      }
      if (gi_720 || Seconds() % 5 == 0) {
         gi_720 = FALSE;
         li_88 = 0;
         if (gi_432) li_88 = 1;
         for (count_80 = 0; count_80 < 10; count_80++) {
            for (count_84 = 0; count_84 < li_88 + 6; count_84++) {
               ObjectCreate("FuturoFX_BKG" + count_80 + count_84, OBJ_LABEL, 0, 0, 0);
               ObjectSetText("FuturoFX_BKG" + count_80 + count_84, "n", 30, "Wingdings", color_72);
               ObjectSet("FuturoFX_BKG" + count_80 + count_84, OBJPROP_XDISTANCE, 20 * count_80);
               ObjectSet("FuturoFX_BKG" + count_80 + count_84, OBJPROP_YDISTANCE, 23 * count_84 + 9);
            }
         }
      }
   }
}

void f0_0() {
   string ls_0;
   string str_concat_8;
   string ls_16;
   string ls_24;
   string ls_32;
   string ls_40;
   string ls_unused_48;
   string ls_unused_56;
   string ls_64;
   if (gi_408) {
      ls_0 = "";
      str_concat_8 = "N/A";
      ls_16 = "";
      ls_24 = "";
      ls_32 = "";
      ls_40 = "";
      ls_unused_48 = "";
      ls_unused_56 = "";
      if (gi_536 > 0) {
         str_concat_8 = StringConcatenate(DoubleToStr(gd_488, 2), "% [", TimeToStr(gi_532, TIME_DATE|TIME_MINUTES), "]");
         if (gi_404) {
            ls_16 = " (" + DoubleToStr(gd_504, 2) + "%)";
            ls_24 = " (" + DoubleToStr(gd_512, 2) + "%)";
         } else ls_16 = " (" + DoubleToStr(gd_496, 2) + "%)";
      }
      if (gi_404) ls_32 = "\n  Correlation <= -" + DoubleToStr(cor_threshold, 1) + " : " + g_count_468 + " matches" + ls_24;
      if (gi_432 && g_count_528 > 0) ls_40 = "\n  Std Dev (pips) = " + DoubleToStr(gd_672, 1) + " on Highs, " + DoubleToStr(gd_680, 1) + " on Lows";
      ls_64 = "\n  Potential (pips): Long " + DoubleToStr(gd_728, 1) + " -- Short " + DoubleToStr(-gd_736, 1);
      f0_38(gi_604, "correlations_performed");
      ls_0 = ls_0 
         + "\n                 " + gs_708 
         + "\n                by www.pimpmyea.com" 
         + "\n -----------------------------------------------------------------" 
      + "\n  Current Open Time: " + TimeToStr(Time[0]);
      for (int index_72 = 0; index_72 < g_arr_size_280; index_72++) {
         ls_0 = ls_0 
         + "\n  " + gia_228[index_72] + " (" + DoubleToStr(gda_216[index_72], 1) + "%) : Long " + DoubleToStr(gda_220[index_72], 1) + " -- Short " + DoubleToStr(-gda_224[index_72],
            1);
      }
      ls_0 = ls_0 
         + "\n  AVERAGE Potential: Long " + DoubleToStr(gd_232, 1) + " -- Short " + DoubleToStr(-gd_240, 1) 
         + "\n  TARGETS: Long " + DoubleToStr(gd_256, 5) + " -- Short " + DoubleToStr(gd_264, 5) 
      + "\n -----------------------------------------------------------------";
      Comment(ls_0);
      if (gi_720 || Seconds() % 5 == 0) {
         for (int count_76 = 0; count_76 < 10; count_76++) {
            for (int count_80 = 0; count_80 < 100; count_80++) {
               ObjectDelete("FuturoFX_BKG" + count_76 + count_80);
               ObjectDelete("FuturoFX_BKG" + count_76 + ((count_80 + 1)));
               ObjectDelete("FuturoFX_BKG" + count_76 + ((count_80 + 2)));
            }
         }
      }
      if (gi_720 || Seconds() % 5 == 0) {
         gi_720 = FALSE;
         for (count_76 = 0; count_76 < 10; count_76++) {
            for (count_80 = 0; count_80 < 7; count_80++) {
               ObjectCreate("FuturoFX_BKG" + count_76 + count_80, OBJ_LABEL, 0, 0, 0);
               ObjectSetText("FuturoFX_BKG" + count_76 + count_80, "n", 30, "Wingdings", Blue);
               ObjectSet("FuturoFX_BKG" + count_76 + count_80, OBJPROP_XDISTANCE, 20 * count_76);
               ObjectSet("FuturoFX_BKG" + count_76 + count_80, OBJPROP_YDISTANCE, 23 * count_80 + 9);
            }
         }
      }
   }
}

int f0_24(int ai_0, int ai_4, int ai_8) {
   int li_ret_12 = MathMin(255, MathAbs(ai_0)) + 256.0 * MathMin(255, MathAbs(ai_4)) + 65536.0 * MathMin(255, MathAbs(ai_8));
   return (li_ret_12);
}

int f0_1(int ai_0, int ai_4, int ai_8, int ai_12, int ai_16, int ai_20, double ad_24, double ad_32, double ad_40) {
   double ld_48 = ad_32 - ad_24;
   ad_40 = ad_32 - ad_40;
   double ld_56 = f0_15(f0_37(ai_0, ai_12), f0_37(ld_48, 1));
   double ld_64 = f0_15(f0_37(ai_4, ai_16), f0_37(ld_48, 1));
   double ld_72 = f0_15(f0_37(ai_8, ai_20), f0_37(ld_48, 1));
   return (f0_24(f0_37(ai_0, f0_25(ld_56, ad_40)), f0_37(ai_4, f0_25(ld_64, ad_40)), f0_37(ai_8, f0_25(ld_72, ad_40))));
}

void f0_38(double ad_0, string as_8) {
   if (gi_716)
      if (ad_0 == 0.0) Alert("zero divide: ", as_8, " = 0");
}

double f0_17(double ad_0) {
   return (MathLog(ad_0) / MathLog(10));
}

int init() {
   f0_13(2.0);
   gs_708 = f0_12("     ", "FuturoFX", " ", "v2.00");
   f0_20();
   gi_100 = TRUE;
   return (0);
}

int deinit() {
   f0_30();
   return (0);
}

int start() {
   if (!gi_100) {
      gs_708 = f0_12("     ", "FuturoFX", " ", "v2.00");
      f0_20();
      gi_100 = TRUE;
   }
   f0_2();
   return (0);
}
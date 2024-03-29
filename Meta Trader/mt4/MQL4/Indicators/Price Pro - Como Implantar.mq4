//+------------------------------------------------------------------+
//|                                        PriceProComoImplantar.mq4 |
//|                                    Copyright 2021, Action Codes. |
//|                                             https://action.codes |
//+------------------------------------------------------------------+

//**************************** GUIA DE IMPLANTAÇÃO DA BIBLIOTECA DO BOT PRICE PRO ****************************//

//OLÁ CARO DESENVOLVEDOR, SAUDAÇÕES. DE PROGRAMADOR PARA PROGRAMADOR, QUEREMOS FACILITAR SUA VIDA.
//ABAIXO, EM SIMPLES PASSOS VOCÊ CONSEGUE IMPLANTAR OS GATILHOS PARA O ENVIO DE SINAIS PARA O BOT PRICE PRO.
//EM CASO DE DÚVIDAS CONTATE VIA TELEGRAM: @actioninvestimentos

#property copyright "Copyright 2021, Action Codes."
#property link      "https://action.codes"
#property version   "1.00"
#property strict
#property indicator_chart_window

//CORRETORAS DISPONÍVEIS
enum corretora_price_pro
  {
   EmTodas = 1, //Todas
   EmIQOption = 2, //IQ Option
   EmSpectre = 3, //Spectre
   EmBinary = 4, //Binary
   EmGC = 5, //Grand Capital
   EmBinomo = 6, //Binomo
   EmOlymp = 7 //Olymp Trade
  };

//VARIÁVEL EXTERNA PARA SELEÇÃO DE CORRETORA
extern corretora_price_pro Corretora = EmTodas;       //Corretora
 
//PRIMEIRAMENTE FAÇA A CHAMADA PARA A BIBLIOTECA QUE VIRÁ DA PASTA LIBRARIES DO MT4

#import "PriceProLib.ex4"
   void TradePricePro(string ativo, string direcao, int expiracao, string nomedosinal, int martingales, int martingale_em, int data_atual, int corretora);
#import

///////////////////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---

   //Symbol() = Atido do gráfico em andamento
   //CALL ou PUT: Define a direção do trade
   //Period() = Aqui no formato de números inteiros você define o tempo de operação
   //PRICE PRO = É o nome do sinal que aparecerá no bot
   //3 martingale = Ignore este parâmetro, snao planos para o futuro para não haver a necessidade de atualização da biblioteca
   //1 martingale em = Ignore este parâmetro, snao planos para o futuro para não haver a necessidade de atualização da biblioteca
   //TimeLocal() = Registra a hora em que o sinal chega no BOT
   //Corretora corretora = Chamada para a seleção de corretora

   //DENTRO DO LOOP, ONDE DESEJAR FAÇA A CHAMADA DA FUNÇÃO PARA CALL
      TradePricePro(Symbol(), "CALL", Period(), "PRICE PRO", 3, 1, TimeLocal(), Corretora);
      
   //DENTRO DO LOOP, ONDE DESEJAR FAÇA A CHAMADA DA FUNÇÃO PARA PUT
      TradePricePro(Symbol(), "PUT", Period(), "PRICE PRO", 3, 1, TimeLocal(), Corretora);
      
   //NOTA, COMO PODE PERCEBER, NEM TODOS OS PARÂMETROS PRECISAM SER CONFIGURADOS. 
   //NA MAIORIA DOS CASOS, BASTA SOMENTE A DIREÇÃO E O TEMPO DE OPERAÇÃO
      
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

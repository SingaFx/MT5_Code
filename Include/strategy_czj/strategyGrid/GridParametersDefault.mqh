//+------------------------------------------------------------------+
//|                                        GridParametersDefault.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <strategy_czj\common\strategy_common.mqh>

enum ParameterType
  {
   ENUM_GRID_PARAMETER_200_380_12, // 200_380_12
   ENUM_GRID_PARAMETER_200_500_15, // 200_500_15
   ENUM_GRID_PARAMETER_200_700_20, // 200_700_20
   ENUM_GRID_PARAMETER_300_440_10, // 300_440_10
   ENUM_GRID_PARAMETER_300_750_15, // 300_750_15
   ENUM_GRID_PARAMETER_300_930_20 // 300_930_20
  };
struct GridParameters
  {
   int points_add;
   int points_win;
   int pos_max;
   void Init(int add, int win, int max);
   void Init(ParameterType pt);
  };
 
void GridParameters::Init(int add,int win,int max)
   {
      points_add=add;
      points_win=win;
      pos_max=max;   
   }
void GridParameters::Init(ParameterType pt)
   {
    switch(pt)
      {
       case ENUM_GRID_PARAMETER_200_380_12 :
         Init(200,380,12);
         break;
       case ENUM_GRID_PARAMETER_200_500_15:
          Init(200,500,15);
          break;  
       case ENUM_GRID_PARAMETER_200_700_20:
          Init(200,700,20);
          break;
       case ENUM_GRID_PARAMETER_300_440_10:
          Init(300,440,10);
          break;
       case ENUM_GRID_PARAMETER_300_750_15:
          Init(300,750,15);
          break;
       case ENUM_GRID_PARAMETER_300_930_20:
          Init(300,930,20);
          break;
       default:
         break;
      }
   }   
   
class CGridParametersDefault
  {
private:
   GridParameters p[28];
public:
                     CGridParametersDefault(void);
                    ~CGridParametersDefault(void){};
                    void GetDefaultParameter(string symbol, GridParameters &par);
  };  
CGridParametersDefault::CGridParametersDefault(void)
   {
    p[0].Init(350,750,10); // EURGBP
    p[1].Init(450,750,10); // EURAUD
    p[2].Init(250,730,19); // EURNZD
    p[3].Init(350,790,11); // EURUSD
    p[4].Init(350,750,12); // EURCAD
    p[5].Init(200,530,11); // EURCHF
    p[6].Init(500,630,10); // EURJPY
    
    p[7].Init(350,750,10); // GBPAUD
    p[8].Init(350,750,10); // GBPNZD
    p[9].Init(350,750,10); // GBPUSD
    
    p[10].Init(450,530,10);   // GBPCAD
    p[11].Init(500,490,11);   // GBPCHF
    p[12].Init(500,590,10);   // GBPJPY
    p[13].Init(200,750,14);   // AUDNZD
    p[14].Init(450,750,10);   // AUDUSD
    p[15].Init(200,650,15);   // AUDCAD
    p[16].Init(500,470,19);   // AUDCHF
    p[17].Init(300,790,10);   // AUDJPY
    p[18].Init(450,490,10);   // NZDUSD
    p[19].Init(200,730,15);   // NZDCAD
    p[20].Init(300,610,10);   // NZDCHF
    
    p[21].Init(300,750,10);   // NZDJPY
    p[22].Init(500,630,10);   // USDCAD
    p[23].Init(400,770,10);   // USDCHF
    p[24].Init(200,510,10);   // USDJPY
    p[25].Init(200,670,11);   // CADCHF
    p[26].Init(200,590,14);   // CADJPY
    p[27].Init(400,490,10);   // CHFJPY
   }
void CGridParametersDefault::GetDefaultParameter(string symbol,GridParameters &par)
   {
    for(int i=0;i<28;i++)
      {
       if(symbol==SYMBOLS_28[i])
         {
          par=p[i];
          return;
         }
      }
   }
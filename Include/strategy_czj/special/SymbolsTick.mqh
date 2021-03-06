//+------------------------------------------------------------------+
//|                                                  SymbolsTick.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSymbolsTick
  {
protected:
   int               num_symbol;
   string            symbols[];
   double            points[];
   MqlTick           tick[];
   bool              tick_copied[];
   int               operators[];
   int               operator_res[];

protected:
   void              RefreshTickData(void);
   void              EA_operation(void);

public:
                     CSymbolsTick(void);
                    ~CSymbolsTick(void);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSymbolsTick::CSymbolsTick(void)
  {
   num_symbol=7;
   string symbols_default[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
   ArrayCopy(symbols,symbols_default);
   ArrayResize(points,7);
   ArrayResize(tick,7);
   ArrayResize(tick_copied,7);
   ArrayResize(operators,num_symbol);
   ArrayResize(operator_res,num_symbol);
   for(int i=0;i<num_symbol;i++)
     {
      SymbolInfoDouble(symbols[i],SYMBOL_POINT);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSymbolsTick::RefreshTickData(void)
  {
   for(int i=0;i<num_symbol;i++)
     {
      if(SymbolInfoTick(symbols[i],tick[i])) tick_copied[i]=true;
      else tick_copied[i]=false;
     }
  }
void CSymbolsTick::EA_operation(void)
   {
    for(int i=0;i<num_symbol;i++)
      {
       switch(operators[i])
         {
          case 1: // 开多 平空
            
            break;
          case -1: // 开空 平多
             
             break;
          default:
            break;
         }
      }
   }
//+------------------------------------------------------------------+

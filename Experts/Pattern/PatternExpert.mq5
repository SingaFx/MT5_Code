//+------------------------------------------------------------------+
//|                                                PatternExpert.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com/en/users/alex2356"
#property version   "1.00"
#include <Pattern/Pattern.mqh>
#include "Trade.mqh" 
CTradeBase Trade;
CPattern Pat;
//+------------------------------------------------------------------+
//| Pattern search mode                                              |
//+------------------------------------------------------------------+
enum PATTERN_MODE
  {
   EXISTING,
   GENERATED
  };
//+------------------------------------------------------------------+
//| Expert Advisor input parameters                                  |
//+------------------------------------------------------------------+
input    string               Inp_EaComment="Pattern Strategy";         // EA Comment
input    double               Inp_Lot=0.01;                             // Lot
input    MarginMode           Inp_MMode=LOT;                            // Money Management

//--- EA parameters
input    string               Inp_Str_label="===EA parameters===";      // Label
input    int                  Inp_MagicNum=1111;                        // Magic number
input    int                  Inp_StopLoss=40;                          // Stop Loss(points)
input    int                  Inp_TakeProfit=30;                        // Take Profit(points)
//--- Trading parameters
input ENUM_TIMEFRAMES         Timeframe=PERIOD_CURRENT;                 // Current Timeframe
input PATTERN_MODE            PatternMode=0;                            // Pattern Mode
input TYPE_PATTERN            BuyPatternType=ENGULFING_BULL;            // Buy Pattern Type
input TYPE_PATTERN            SellPatternType=ENGULFING_BEAR;           // Sell Pattern Type
input uint                    BuyIndex1=1;                              // BuyIndex of simple candle1
input uint                    BuyIndex2=0;                              // BuyIndex of simple candle2
input uint                    BuyIndex3=0;                              // BuyIndex of simple candle3
input uint                    SellIndex1=1;                             // SellIndex of simple candle1
input uint                    SellIndex2=0;                             // SellIndex of simple candle2
input uint                    SellIndex3=0;                             // SellIndex of simple candle3
input double                  LongCoef=1.3;                             // Long candle coef
input double                  ShortCoef=0.5;                            // Short candle coef
input double                  DojiCoef=0.04;                            // Doji candle coef
input double                  MaribozuCoef=0.01;                        // Maribozu candle coef
input double                  SpinCoef=1;                               // Spin candle coef
input double                  HummerCoef1=0.1;                          // Hummer candle coef1
input double                  HummerCoef2=2;                            // Hummer candle coef2
input int                     TrendPeriod=5;                            // Trend Period
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Checking connection to the trade server
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      Print(Inp_EaComment,": No Connection!");
      return(INIT_FAILED);
     }
//--- Checking automated trading permission
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Print(Inp_EaComment,": Trade is not allowed!");
      return(INIT_FAILED);
     }
//---
   Pat.TrendPeriod(TrendPeriod);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!Trade.IsOpenedByMagic(Inp_MagicNum))
     {
      //--- Opening an order if there is a buy signal
      if(BuySignal())
         Trade.BuyPositionOpen(Symbol(),Inp_Lot,Inp_StopLoss,Inp_TakeProfit,Inp_MagicNum,Inp_EaComment);
      //--- Opening an order if there is a sell signal
      if(SellSignal())
         Trade.SellPositionOpen(Symbol(),Inp_Lot,Inp_StopLoss,Inp_TakeProfit,Inp_MagicNum,Inp_EaComment);
     }
  }
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   if(PatternMode==0)
     {
      if(BuyPatternType==NONE)
         return(false);
      if(Pat.PatternType(_Symbol,Timeframe,BuyPatternType,1))
         return(true);
     }
   else if(PatternMode==1)
     {
      if(BuyIndex1>0 && BuyIndex2==0 && BuyIndex3==0)
        {
         if(Pat.PatternType(_Symbol,Timeframe,BuyIndex1,1))
            return(true);
        }
      else if(BuyIndex1>0 && BuyIndex2>0 && BuyIndex3==0)
        {
         if(Pat.PatternType(_Symbol,Timeframe,BuyIndex1,BuyIndex2,1))
            return(true);
        }
      else if(BuyIndex1>0 && BuyIndex2>0 && BuyIndex3>0)
        {
         if(Pat.PatternType(_Symbol,Timeframe,BuyIndex1,BuyIndex2,BuyIndex3,1))
            return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   if(PatternMode==0)
     {
      if(SellPatternType==NONE)
         return(false);
      if(Pat.PatternType(_Symbol,Timeframe,SellPatternType,1))
         return(true);
     }
   else if(PatternMode==1)
     {
      if(SellIndex1>0 && SellIndex2==0 && SellIndex3==0)
        {
         if(Pat.PatternType(_Symbol,Timeframe,SellIndex1,1))
            return(true);
        }
      else if(SellIndex1>0 && SellIndex2>0 && SellIndex3==0)
        {
         if(Pat.PatternType(_Symbol,Timeframe,SellIndex1,SellIndex2,1))
            return(true);
        }
      else if(SellIndex1>0 && SellIndex2>0 && SellIndex3>0)
        {
         if(Pat.PatternType(_Symbol,Timeframe,SellIndex1,SellIndex2,SellIndex3,1))
            return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+

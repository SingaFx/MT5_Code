//+------------------------------------------------------------------+
//|                                               SimpleDoubleMA.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CAddDoubleMA:public CStrategy
  {
private:
   int               period_ma_long;
   int               period_ma_short;
   int               handle_ma_long;
   int               handle_ma_short;
   double            ma_long[];
   double            ma_short[];
   MqlTick           latest_price;
   double            order_lots;
   int               points_add;
   PositionInfor     pos_state;
   double last_buy_price;
   double last_sell_price;

private:
private:
   void              RefreshPositionState(void);
   void              CloseAllBuyPosition(void);
   void              CloseAllSellPosition(void);
   void              OpenBuyPosition(void);
   void              OpenSellPosition(void);
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual bool      close_buy_condition(void);
   virtual bool      close_sell_condition(void);
   //virtual bool      open_buy_condition(void);
   //virtual bool      open_sell_condition(void);

public:
                     CAddDoubleMA(void){};
                    ~CAddDoubleMA(void){};
   void              InitStrategy(int tau_ma_long,int tau_ma_short, int add_points, double order_lots);
   void              SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frames);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAddDoubleMA::InitStrategy(int tau_ma_long,int tau_ma_short, int add_points, double order_lots)
  {
   period_ma_long=tau_ma_long;
   period_ma_short=tau_ma_short;
   handle_ma_long=iMA(ExpertSymbol(),Timeframe(),period_ma_long,0,MODE_SMA,PRICE_CLOSE);
   handle_ma_short=iMA(ExpertSymbol(),Timeframe(),period_ma_short,0,MODE_SMA,PRICE_CLOSE);
   order_lots=order_lots;
   points_add=add_points;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAddDoubleMA::SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frames)
  {
   AddBarOpenEvent(symbol,time_frames);
   AddTickEvent(symbol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAddDoubleMA::RefreshPositionState(void)
  {
   pos_state.Init();
//计算buy总盈利、buy总手数，sell总盈利，sell总手数
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()!=ExpertSymbol())continue;
      if(cpos.Direction()==POSITION_TYPE_BUY)
        {
         pos_state.profits_buy+=cpos.Profit();
         pos_state.lots_buy+=cpos.Volume();
         pos_state.num_buy+=1;
        }
      if(cpos.Direction()==POSITION_TYPE_SELL)
        {
         pos_state.profits_sell+=cpos.Profit();
         pos_state.lots_sell+=cpos.Volume();
         pos_state.num_sell+=1;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAddDoubleMA::CloseAllBuyPosition(void)
  {
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==ExpertSymbol() && cpos.Direction()==POSITION_TYPE_BUY)
         Trade.PositionClose(cpos.ID());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAddDoubleMA::CloseAllSellPosition(void)
  {
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==ExpertSymbol() && cpos.Direction()==POSITION_TYPE_SELL)
         Trade.PositionClose(cpos.ID());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAddDoubleMA::OnEvent(const MarketEvent &event)
  {
// 品种的tick事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      CopyBuffer(handle_ma_long,0,0,3,ma_long);
      CopyBuffer(handle_ma_short,0,0,3,ma_short);
      SymbolInfoTick(ExpertSymbol(),latest_price);
      RefreshPositionState();
      if(close_buy_condition())
         CloseAllBuyPosition();
      if(close_sell_condition())
         CloseAllSellPosition();
     }
//---品种的BAR事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.period==Timeframe() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      RefreshPositionState();
      CopyBuffer(handle_ma_long,0,0,3,ma_long);
      CopyBuffer(handle_ma_short,0,0,3,ma_short);
      OpenBuyPosition();
      OpenSellPosition();   
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAddDoubleMA::close_buy_condition(void)
  {
   
   //bool condition1=false;
   //bool condition2=false;
   //bool condition3=false;
   bool condition1=ma_short[0]>ma_long[0] && ma_short[1]<ma_long[1];//短均线下穿长均线
   bool condition2=last_buy_price-latest_price.bid>points_add*2*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   bool condition3=latest_price.bid<ma_long[1];
   if(condition1||condition2||condition3)
      return true;
   else
      return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAddDoubleMA::close_sell_condition(void)
  {
  
   //bool condition1=false;
   //bool condition2=false;
   //bool condition3=false;
    bool condition1=ma_short[0]<ma_long[0] && ma_short[1]>ma_long[1];//短均线上穿长均线
   bool condition2=latest_price.ask-last_sell_price>points_add*2*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   bool condition3=latest_price.ask>ma_long[1];
   if(condition1||condition2||condition3)
      return true;
   else
      return false;
  }
//bool CAddDoubleMA::open_buy_condition(void)
//   {
//    bool condition1=ma_short[0]>ma_long[0] && ma_short[1]<ma_long[1];//短均线下穿长均线
//    bool condition2=latest_price.ask-last_buy_price>points_add*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);//价格又涨了一定点数
//    if(pos_state.num_buy==0)//首仓
//      {
//       if(condition1) return true; //短均线上穿长均线
//      }
//    else//加仓
//      {
//       if(condition2) return true;
//      }
//    return false;
//   }
void CAddDoubleMA::OpenBuyPosition(void)
   {
    bool condition1=ma_short[0]<ma_long[0] && ma_short[1]>ma_long[1];//短均线上穿长均线
    bool condition2=latest_price.ask-last_buy_price>points_add*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);//价格又涨了一定点数
    if(pos_state.num_buy==0)//首仓
      {
       if(condition1)
         {
          Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,order_lots,latest_price.ask,0,0,"MA BUY-"+string(pos_state.num_buy+1)+"短均线上穿长均线");
          Print("SHORT MA: ", ma_short[0]," ", ma_short[1]);
          Print("LONG MA: ",ma_long[0]," ", ma_long[1]);
         }
      }
    else//加仓
      {
       if(condition2)
         {
          Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,order_lots,latest_price.ask,0,0,"MA BUY-"+string(pos_state.num_buy+1)+"points:"+string(latest_price.ask-last_buy_price));
          Print("SHORT MA: ", ma_short[0]," ", ma_short[1]);
          Print("LONG MA: ",ma_long[0]," ", ma_long[1]);
          Print(latest_price.ask," ",last_buy_price);
         }
      }
    last_buy_price=latest_price.ask;
   }

void CAddDoubleMA::OpenSellPosition(void)
   {
    bool condition1=ma_short[0]>ma_long[0] && ma_short[1]<ma_long[1];//短均线下穿长均线
    bool condition2=last_sell_price-latest_price.bid>points_add*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);//价格又跌了一定点数
    if(pos_state.num_sell==0)//首仓
      {
       if(condition1)
         {
          Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,order_lots,latest_price.bid,0,0,"MA SELL-"+string(pos_state.num_sell+1)+"短均线下穿长均线"); 
          Print("SHORT MA: ", ma_short[0]," ", ma_short[1]);
          Print("LONG MA: ",ma_long[0]," ", ma_long[1]);
         }
      }
    else//加仓
      {
       if(condition2)
         {
          Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,order_lots,latest_price.bid,0,0,"MA SELL-"+string(pos_state.num_sell+1)+"points:"+string(last_sell_price-latest_price.bid)); 
          Print("SHORT MA: ", ma_short[0]," ", ma_short[1]);
          Print("LONG MA: ",ma_long[0]," ", ma_long[1]);
         }
      }
    
    last_sell_price=latest_price.bid;
   }
//+------------------------------------------------------------------+

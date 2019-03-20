//+------------------------------------------------------------------+
//|                                            SignalRsiStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PosState
  {
   POS_EMPTY,
   POS_BUY,
   POS_SELL

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct PosStruct
  {
   long              pid;
   PosState          pstate;
                     PosStruct() {pid=0;pstate=POS_EMPTY;}
   void              BuildPos(long pid_new,PosState p_state);
   void              DestroyPos();
   double            GetProfitsPerLots();
   long              GetTicket();
   void              Init() {pid=0;pstate=POS_EMPTY;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PosStruct::BuildPos(long pid_new,PosState p_state)
  {
   pid=pid_new;
   pstate=p_state;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PosStruct::DestroyPos(void)
  {
   pid=0;
   pstate=POS_EMPTY;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PosStruct::GetProfitsPerLots(void)
  {
   PositionSelectByTicket(pid);
   return PositionGetDouble(POSITION_PROFIT)/PositionGetDouble(POSITION_VOLUME);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long PosStruct::GetTicket(void)
  {
   return pid;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSignalRsiStrategy:public CStrategy
  {
protected:
   double            rsi_open_long;
   double            rsi_open_short;
   double            rsi_close_long;
   double            rsi_close_short;
   double            tp_points;
   double            base_lots;
   PosStruct         pos;
   int               h_rsi;
   double            rsi_value[];
   MqlTick           latest_price;
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CheckPositionOpen();
   virtual void      CheckPositionClose();
   void              ClosePosition();
public:
                     CSignalRsiStrategy(void){};
                    ~CSignalRsiStrategy(void){};
   void              Init(double rol=30,double ros=70,double rcl=70,double rcs=30,double tp=200,double l=0.01);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSignalRsiStrategy::Init(double rol=30,double ros=70,double rcl=70,double rcs=30,double tp=200,double l=0.01)
  {
   rsi_open_long=rol;
   rsi_open_short=ros;
   rsi_close_long=rcl;
   rsi_close_short=rcs;
   tp_points=tp;
   base_lots=l;
   h_rsi=iRSI(ExpertSymbol(),Timeframe(),12,PRICE_CLOSE);
   AddBarOpenEvent(ExpertSymbol(),Timeframe());
   pos.Init();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiStrategy::OnEvent(const MarketEvent &event)
  {
   if(event.type==MARKET_EVENT_TICK)
     {
      //Print("Tick");
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CheckPositionClose();
     }
   if(event.type==MARKET_EVENT_BAR_OPEN)
     {
     // Print("BarOpen");
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiStrategy::ClosePosition(void)
  {
   Trade.PositionClose(pos.GetTicket(),"TP");
   pos.DestroyPos();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiStrategy::CheckPositionClose(void)
  {
   if(pos.pstate==POS_EMPTY) return;
   if(pos.GetProfitsPerLots()>tp_points||pos.GetProfitsPerLots()<-tp_points)
     {
      ClosePosition();
      return;
     }
   if(rsi_value[0]>rsi_open_short && pos.pstate==POS_BUY)
     {
      ClosePosition();
     }
   if(rsi_value[0]<rsi_open_long && pos.pstate==POS_SELL)
     {
      ClosePosition();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiStrategy::CheckPositionOpen(void)
  {
   CopyBuffer(h_rsi,0,0,2,rsi_value);
   if(pos.pstate==POS_EMPTY)
     {
      //Print("CheckOpen");
      if(rsi_value[0]>rsi_open_short)
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,base_lots,latest_price.bid,0,0);
         pos.BuildPos(Trade.ResultOrder(),POS_SELL);
        }
      if(rsi_value[0]<rsi_open_long)
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,base_lots,latest_price.ask,0,0);
         pos.BuildPos(Trade.ResultOrder(),POS_BUY);
        }
     }
  }
//+------------------------------------------------------------------+

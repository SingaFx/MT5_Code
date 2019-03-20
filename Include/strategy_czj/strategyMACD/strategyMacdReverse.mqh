//+------------------------------------------------------------------+
//|                                          strategyMacdReverse.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "strategyMACDBase.mqh"
#include <Arrays\ArrayLong.mqh>

class CMACDReverse:public CMACDBase
  {
private:  
   CArrayLong        pos_id_long;
   CArrayLong        pos_id_short;
   int               delta_hours;
   int               delta_points;  
   datetime          time_last;
   double            price_last;
public:
                     CMACDReverse(void){};
                    ~CMACDReverse(void){};
                    void SetParametersNewPosition(int d_hours=4,int d_points=500);
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CheckPositionOpen();
   virtual void      CheckPositionClose();
   void              GetIndicators();
  };
void CMACDReverse::SetParametersNewPosition(int d_hours=4,int d_points=500)
   {
    delta_hours=d_hours;
    delta_points=d_points;
   }
void CMACDReverse::OnEvent(const MarketEvent &event)
   {
    if(event.symbol==ExpertSymbol()&&event.type==MARKET_EVENT_BAR_OPEN)
      {
       GetIndicators();
       CheckPositionClose();
       CheckPositionOpen();
      }
    if(event.symbol==ExpertSymbol()&&event.type==MARKET_EVENT_TICK)
      {
       SymbolInfoTick(ExpertSymbol(),latest_price);
      }
   }
void CMACDReverse::GetIndicators(void)
   {
    CopyBuffer(h_macd_detector,2,0,1,value_signal);
   }
void CMACDReverse::CheckPositionClose(void)
   {
    if(value_signal[0]==1)
      {
       for(int i=pos_id_short.Total()-1;i>=0;i--) Trade.PositionClose(pos_id_short.At(i));
       pos_id_short.Clear();
      }
    else if(value_signal[0]==-1)
           {
             for(int i=pos_id_long.Total()-1;i>=0;i--) Trade.PositionClose(pos_id_long.At(i));
             pos_id_long.Clear();           
           }
   }
void CMACDReverse::CheckPositionOpen(void)
   {
    if(value_signal[0]==1)
      {
       if(pos_id_long.Total()==0)
         {
          Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,base_lots,latest_price.ask,0,0);
          pos_id_long.Add(Trade.ResultOrder());
         }
       else
         {
          PositionSelectByTicket(pos_id_long.At(pos_id_long.Total()-1));
          time_last=(datetime)PositionGetInteger(POSITION_TIME);
          price_last=PositionGetDouble(POSITION_PRICE_OPEN);
          if(MathAbs(price_last-latest_price.ask)/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>delta_points)
            {
             Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,base_lots,latest_price.ask,0,0);
             pos_id_long.Add(Trade.ResultOrder());
            }
          
         }   
      }
    else if(value_signal[0]==-1)
           {
            if(pos_id_short.Total()==0)
              {
               Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,base_lots,latest_price.bid,0,0);
               pos_id_short.Add(Trade.ResultOrder());
              }      
            else
              {
               PositionSelectByTicket(pos_id_short.At(pos_id_short.Total()-1));
                time_last=(datetime)PositionGetInteger(POSITION_TIME);
                price_last=PositionGetDouble(POSITION_PRICE_OPEN);
                if(MathAbs(price_last-latest_price.ask)/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>delta_points)
                  {
                     Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,base_lots,latest_price.bid,0,0);
                     pos_id_short.Add(Trade.ResultOrder());
                  }
              }
           }
   }
//+------------------------------------------------------------------+
//|                                                      LockPos.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayDouble.mqh>
#include "MLMA.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLockPos:public CStrategy
  {
protected:
   CArrayLong        pos_arr;
   CArrayDouble      pos_max;
   CArrayDouble      pos_min;
   MqlTick           latest_price;
   CMLMA             ml;
   int               signal;
public:
                     CLockPos(void){};
                    ~CLockPos(void){};
   virtual void      OnEvent(const MarketEvent &event);
   void              Init();
   void              SetAlpha(double &a[]);
protected:
   void              CheckPositionOpen();
   void              OpenLongPosition(double lots,int tp_points,int sl_points,string comment="Long");
   void              OpenShortPosition(double lots,int tp_points,int sl_points,string comment="Short");
  };
void CLockPos::Init(void)
  {
   int t[]={1,5,12,24,48,96,240};
   ml.SetMaParameters(PERIOD_M5,ExpertSymbol(),t);
   signal=0;
  }
void CLockPos::SetAlpha(double &a[])
   {
    ml.SetAlpha(a);
   }    
//+------------------------------------------------------------------+
void CLockPos::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CheckPositionOpen();
     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      ml.GetXValue();
      double op=ml.OutPut();
      if(op>0) signal=1;
      else if(op<0) signal=-1;
      else signal=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLockPos::CheckPositionOpen(void)
  {
   int total=pos_arr.Total();
   if(total==0) 
      {
       if(signal==1) OpenLongPosition(0.01,500,500,"First");
       else if(signal==-1) OpenShortPosition(0.01,500,500,"First");
      }
   else
     {
     for(int i=total-1;i>=0;i--)
       {
        if(!PositionSelectByTicket(pos_arr.At(i)))
         {
          pos_arr.Delete(i);
          pos_max.Delete(i);
          pos_min.Delete(i);
         }
        else
          {
           double current_price=PositionGetDouble(POSITION_PRICE_CURRENT);
           double open_price=PositionGetDouble(POSITION_PRICE_OPEN);
           if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
             {
              if(latest_price.ask<pos_min.At(i)) pos_min.Update(i,latest_price.ask);
              if(current_price-pos_min.At(i)>SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)*300) OpenShortPosition(0.01,500,500,"SL-LOCK BUY");//SL Lock
              if(current_price-open_price>SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)*300) OpenShortPosition(0.01,500,500,"TP-LOCK BUY");//TP Lock
             }
           else
             {
              if(latest_price.bid>pos_max.At(i)) pos_max.Update(i,latest_price.bid);
              if(pos_max.At(i)-current_price>SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)*300) OpenLongPosition(0.01,500,500,"SL-LOCK SELL"); // SL Lock
              if(open_price-current_price>SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)*300) OpenLongPosition(0.01,500,500,"TP-LOCK SELL"); // TP Lock
             }
            break;             
          }
       }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLockPos::OpenLongPosition(double lots,int tp_points,int sl_points,string comment="Long")
  {
   double tp_price=latest_price.ask+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   double sl_price=latest_price.ask-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots,latest_price.ask,sl_price,tp_price,comment);
   pos_arr.Add(Trade.ResultOrder());
   pos_max.Add(DBL_MIN);
   pos_min.Add(DBL_MAX);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLockPos::OpenShortPosition(double lots,int tp_points,int sl_points,string comment="Short")
  {
   double tp_price=latest_price.bid-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   double sl_price=latest_price.bid+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots,latest_price.bid,sl_price,tp_price,comment);
   pos_arr.Add(Trade.ResultOrder());
   pos_max.Add(DBL_MIN);
   pos_min.Add(DBL_MAX);
  }
//+------------------------------------------------------------------+

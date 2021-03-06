//+------------------------------------------------------------------+
//|                                                        LSRE3.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "LSRotationElasticStrategy2.mqh"

class CLSRE3:public CLSRE2
  {
protected:
      virtual void      CheckPositionOpen();    // 开仓检测
public:
                     CLSRE3(void){};
                    ~CLSRE3(void){};
  };
void CLSRE3::CheckPositionOpen(void)
   {
    //  设置第一个网格为多头
   if(pr.Total()==0)
     {
      OpenNewLongGridPosition(1,"NewLong");
      //OpenNewShortGridPosition(1,"NewLong");
      return;
     }
   if(pr.Total()==1)
     {
      CGridPosition *gp=pr.grid_pos.At(0);
      switch(gp.GetPosType())
        {
         case POSITION_TYPE_BUY :
           if(gp.Total()>=5) OpenNewShortGridPosition(1,"NS");
           else if((gp.LastPrice()-latest_price.ask)/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>gap_small) AddLongPosition(0,gp.LastLevel()+1,"FA-BIG");
           break;
         default:
           if(gp.Total()>=5) OpenNewLongGridPosition(1,"NL");
           else if((latest_price.bid-gp.LastPrice())/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>gap_small) AddShortPosition(0,gp.LastLevel()+1,"FA-BIG");
           break;
        }
     }
    if(pr.Total()==2)
      {
       CGridPosition *gp0=pr.grid_pos.At(0);
       CGridPosition *gp1=pr.grid_pos.At(1);
       if(gp0.GetLotsTotal()>gp1.GetLotsTotal())
         {
          AllGridAddCheck(gp1.GetPosType(),gap_small);
         }
       else
         {
          AllGridAddCheck(gp0.GetPosType(),gap_small);
         }
      }
   }
//+------------------------------------------------------------------+
//|                                           LSRotationStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include "PositionRotation.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLSRotationStrategy:public CStrategy
  {
protected:
   CPositionRotation pr;   // 多空轮转网格仓位对象
   MqlTick           latest_price;   // 最新报价
   int               pos_max[];
   double            last_equity;
   double            latest_equity;
public:
                     CLSRotationStrategy(void);
                    ~CLSRotationStrategy(void){};
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CheckPositionClose();   // 平仓检测
   virtual void      CheckPositionOpen(); // 开仓检测
   void              PartialClosePosition(int index_grid,double p_total=500,double p_per=200,string comment="PartClose");
   void              CloseRiskTPGrid();
   void              CloseGridAt(int index_grid,string comment);
   void              CloseAllGrid();
   void              OpenNewLongGridPosition(int level,string comment=" ");
   void              AddLongPosition(int index_grid,int level,string comment=" ");
   void              OpenNewShortGridPosition(int level,string comment=" ");
   void              AddShortPosition(int index_grid,int level,string comment=" ");
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLSRotationStrategy::CLSRotationStrategy(void)
  {
   //AddBarOpenEvent(ExpertSymbol(),PERIOD_M1);
   //AddBarOpenEvent(ExpertSymbol(),PERIOD_H4);
   int pos_max_default[]={5,10,15,20,25,30,35,40};
   ArrayCopy(pos_max,pos_max_default);
   last_equity=AccountInfoDouble(ACCOUNT_EQUITY);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationStrategy::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CheckPositionClose();
     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      CheckPositionOpen();
      if(event.period==PERIOD_H4)
        {
         Print("Infor on H4: grid_num-",pr.Total());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationStrategy::CheckPositionClose(void)
  {
   for(int i=0;i<pr.Total();i++)
     {
      PartialClosePosition(i);
     }
//PartialClosePosition(pr.Total()-1);
   CloseRiskTPGrid();
//latest_equity=AccountInfoDouble(ACCOUNT_EQUITY);
//if(latest_equity>last_equity+50)
//  {
//   CloseAllGrid();
//   last_equity=latest_equity;
//  }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationStrategy::CheckPositionOpen(void)
  {
   if(pr.Total()==0)
     {
      OpenNewLongGridPosition(1,"FIRST");
      return;
     }
   CGridPosition *gp=pr.grid_pos.At(pr.Total()-1);
   if(gp.Total()<pos_max[pr.Total()-1])
     {
      if(gp.GetPosType()==POSITION_TYPE_BUY)
        {
         if((gp.LastPrice()-latest_price.ask)/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>150)
           {
            AddLongPosition(pr.Total()-1,gp.LastLevel()+1,"Add");
            //AddLongPosition(pr.Total()-1,gp.LastLevel(),"Add");
           }
        }
      else
        {
         if((latest_price.bid-gp.LastPrice())/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>150)
           {
            AddShortPosition(pr.Total()-1,gp.LastLevel()+1,"Add");
            //AddShortPosition(pr.Total()-1,gp.LastLevel(),"Add");
           }
        }
     }
   else
     {
      if(gp.GetPosType()==POSITION_TYPE_BUY)
        {
         if((gp.LastPrice()-latest_price.ask)/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>300)
           {
            //OpenNewShortGridPosition(pr.Total()+1,"New");
            OpenNewShortGridPosition(1,"New");
            //OpenNewShortGridPosition(gp.LastLevel()+1,"New");
            //OpenNewShortGridPosition(gp.LastLevel()*2,"New");
            //OpenNewShortGridPosition(int(gp.GetLotsTotal()/0.01),"New");
           }
        }
      else
        {
         if((latest_price.bid-gp.LastPrice())/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>300)
           {
            //OpenNewLongGridPosition(pr.Total()+1,"New");
            OpenNewLongGridPosition(1,"New");
            //OpenNewLongGridPosition(gp.LastLevel()+1,"New");
            //OpenNewLongGridPosition(gp.LastLevel()*2,"New");
            //OpenNewLongGridPosition(int(gp.GetLotsTotal()/0.01),"New");
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationStrategy::PartialClosePosition(int index_grid,double p_total=500,double p_per=200,string comment="PartClose")
  {
   if(index_grid>pr.Total()-1) return;
   CGridPosition *gp=pr.grid_pos.At(index_grid);
   CArrayInt pos_ids;
   double part_p=0,part_l=0;
   gp.GetPartialInfor(part_p,part_l,pos_ids);
   if(part_p>p_total || (part_l>0 && part_p/part_l>p_per))
     {
      for(int j=0;j<pos_ids.Total();j++)
        {
         Trade.PositionClose(gp.GetPosId(pos_ids.At(j)),comment);
        }
      gp.DeletePosition(pos_ids);
     }
   if(gp.Total()==0) pr.grid_pos.Delete(index_grid);

//for(int i=0;i<pr.Total();i++)
//  {
//   CGridPosition *gp=pr.grid_pos.At(i);
//   CArrayInt pos_ids;
//   double part_p=0,part_l=0;
//   gp.GetPartialInfor(part_p,part_l,pos_ids);
//   if(part_p>p_total || (part_l>0 && part_p/part_l>p_per))
//     {
//      for(int j=0;j<pos_ids.Total();j++) 
//         {
//          Trade.PositionClose(gp.GetPosId(pos_ids.At(j)),comment);
//         }
//      gp.DeletePosition(pos_ids);
//     }
//    if(gp.Total()==0) pr.grid_pos.Delete(i);
//  }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationStrategy::OpenNewLongGridPosition(int level,string comment=" ")
  {
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01*level,latest_price.ask,0,0,comment);
   CGridPosition *gp=new CGridPosition(Trade.ResultOrder(),level);
   gp.SetPositionType(POSITION_TYPE_BUY);
   pr.grid_pos.Add(gp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationStrategy::AddLongPosition(int index_grid,int level,string comment=" ")
  {

   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01*level,latest_price.ask,0,0,comment);
   CGridPosition *gp=pr.grid_pos.At(index_grid);
   gp.AddPosition(Trade.ResultOrder(),level);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationStrategy::OpenNewShortGridPosition(int level,string comment=" ")
  {
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01*level,latest_price.bid,0,0,comment);
   CGridPosition *gp=new CGridPosition(Trade.ResultOrder(),level);
   gp.SetPositionType(POSITION_TYPE_SELL);
   pr.grid_pos.Add(gp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationStrategy::AddShortPosition(int index_grid,int level,string comment=" ")
  {
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01*level,latest_price.bid,0,0,comment);
   CGridPosition *gp=pr.grid_pos.At(index_grid);
   gp.AddPosition(Trade.ResultOrder(),level);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationStrategy::CloseRiskTPGrid(void)
  {
   int i_grid;
   double p_grid;
   if(pr.GetBuyLots()>=pr.GetSellLots())
     {
      pr.GetLongGridMaxProfits(i_grid,p_grid);
      if(p_grid>50)
        {
         Print("RiskCloseLongTP:",pr.GetBuyLots()," ",pr.GetSellLots());
         CloseGridAt(i_grid,"RiskCloseTP");
        }
     }
   else
     {
      pr.GetShortGridMaxProfits(i_grid,p_grid);
      if(p_grid>10)
        {
         Print("RiskCloseLongTP:",pr.GetBuyLots()," ",pr.GetSellLots());
         CloseGridAt(i_grid,"RiskCloseTP");
         Print("RiskCloseLongTP:",pr.GetBuyLots()," ",pr.GetSellLots());
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationStrategy::CloseGridAt(int index_grid,string comment)
  {
   CGridPosition *gp=pr.grid_pos.At(index_grid);
   for(int i=0;i<gp.Total();i++) Trade.PositionClose(gp.GetPosId(i),comment);
   pr.grid_pos.Delete(index_grid);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationStrategy::CloseAllGrid(void)
  {
   for(int i=pr.Total()-1;i>=0;i--)
     {
      CloseGridAt(i,"CloseAll");
     }
  }
//+------------------------------------------------------------------+

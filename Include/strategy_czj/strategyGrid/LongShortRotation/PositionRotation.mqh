//+------------------------------------------------------------------+
//|                                             PositionRotation.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayInt.mqh>
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridPosition:public CObject
  {
private:
   CArrayLong        id_arr; // 网格的仓位列表
   CArrayInt         level_arr;
   ENUM_POSITION_TYPE p_type;
public:
                     CGridPosition(void){};
                     CGridPosition(long id,int level);
                    ~CGridPosition(void){};
   void              GetPartialInfor(double &profits,double &l,CArrayInt &i_pos_arr);
   void              DeletePosition(CArrayInt &i_pos_arr);
   void              AddPosition(long id,int level);
   void              SetPositionType(ENUM_POSITION_TYPE type_p){p_type=type_p;};
   int               Total(){return id_arr.Total();};
   double            LastPrice();
   int               LastLevel();
   long              GetPosId(int index_arr){return id_arr.At(index_arr);};
   ENUM_POSITION_TYPE GetPosType(){return p_type;}
   double            GetProfitsTotal();
   double            GetLotsTotal();
  };
CGridPosition::CGridPosition(long id,int level)
   {
    id_arr.Clear();
    level_arr.Clear();
    AddPosition(id,level);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPosition::GetPartialInfor(double &profits,double &l,CArrayInt &i_pos_arr)
  {
   double temp_p=0;
   profits=0;l=0;
   i_pos_arr.Clear();
   for(int i=0;i<id_arr.Total();i++)
     {
      PositionSelectByTicket(id_arr.At(i));
      temp_p=PositionGetDouble(POSITION_PROFIT);
      if(i==0 || temp_p>0)
        {
         l+=PositionGetDouble(POSITION_VOLUME);
         profits+=temp_p;
         i_pos_arr.Add(i);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPosition::DeletePosition(CArrayInt &i_pos_arr)
  {
   for(int i=i_pos_arr.Total()-1;i>=0;i--)
     {
      id_arr.Delete(i_pos_arr.At(i));
      level_arr.Delete(i_pos_arr.At(i));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPosition::AddPosition(long id,int level)
  {
   id_arr.Add(id);
   level_arr.Add(level);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridPosition::LastPrice(void)
  {
   PositionSelectByTicket(id_arr.At(id_arr.Total()-1));
   return PositionGetDouble(POSITION_PRICE_OPEN);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGridPosition::LastLevel(void)
  {
   return level_arr.At(level_arr.Total()-1);
  }
double CGridPosition::GetProfitsTotal(void)
   {
    double sum_profits=0;
    for(int i=0;i<id_arr.Total();i++)
     {
      PositionSelectByTicket(id_arr.At(i));
      sum_profits+=PositionGetDouble(POSITION_PROFIT);
     }
    return sum_profits;
   }
double CGridPosition::GetLotsTotal(void)
   {
    double sum_lots=0;
    for(int i=0;i<id_arr.Total();i++)
     {
      PositionSelectByTicket(id_arr.At(i));
      sum_lots+=PositionGetDouble(POSITION_VOLUME);
     }
    return sum_lots;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPositionRotation:public CObject
  {
public:
   CArrayObj         grid_pos;
   double            buy_lots;
   double            sell_lots;
public:
                     CPositionRotation(void){};
                    ~CPositionRotation(void){};
   int Total() {return grid_pos.Total();};
   double            GetBuyLots();
   double            GetSellLots();
   void              GetLongGridMaxProfits(int &index,double &profits);
   void              GetShortGridMaxProfits(int &index,double &profits);
   double            GetProfitsTotal();
  };
double CPositionRotation::GetBuyLots(void)
   {
    double sum_lots=0;
    for(int i=0;i<grid_pos.Total();i++)
      {
       CGridPosition *gp=grid_pos.At(i);
       if(gp.GetPosType()==POSITION_TYPE_BUY)
         {
          for(int j=0;j<gp.Total();j++)
            {
             PositionSelectByTicket(gp.GetPosId(j));
             sum_lots+=PositionGetDouble(POSITION_VOLUME);
            }
         }
      }
     return sum_lots;
   }
double CPositionRotation::GetSellLots(void)
   {
    double sum_lots=0;
    for(int i=0;i<grid_pos.Total();i++)
      {
       CGridPosition *gp=grid_pos.At(i);
       if(gp.GetPosType()==POSITION_TYPE_SELL)
         {
          for(int j=0;j<gp.Total();j++)
            {
             PositionSelectByTicket(gp.GetPosId(j));
             sum_lots+=PositionGetDouble(POSITION_VOLUME);
            }
         }
      }
     return sum_lots;
   }
void CPositionRotation::GetLongGridMaxProfits(int &index,double &profits)
   {
    profits=DBL_MIN;
    index=-1;
    for(int i=0;i<grid_pos.Total();i++)
      {
       CGridPosition *gp=grid_pos.At(i);
       if(gp.GetPosType()==POSITION_TYPE_BUY)
         {
          if(profits<gp.GetProfitsTotal())
            {
             profits=gp.GetProfitsTotal();
             index=i;
            }
         }
      }
   }
void CPositionRotation::GetShortGridMaxProfits(int &index,double &profits)
   {
    profits=DBL_MIN;
    index=-1;
    for(int i=0;i<grid_pos.Total();i++)
      {
       CGridPosition *gp=grid_pos.At(i);
       if(gp.GetPosType()==POSITION_TYPE_SELL)
         {
          if(profits<gp.GetProfitsTotal())
            {
             profits=gp.GetProfitsTotal();
             index=i;
            }
         }
      }
   }
double CPositionRotation::GetProfitsTotal(void)
   {
    double sum_profits=0;
    for(int i=0;i<grid_pos.Total();i++)
      {
       CGridPosition *gp=grid_pos.At(i);
       sum_profits+=gp.GetProfitsTotal();
      }
    return sum_profits;
   }
//+------------------------------------------------------------------+

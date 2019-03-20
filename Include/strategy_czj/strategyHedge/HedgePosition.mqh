//+------------------------------------------------------------------+
//|                                                HedgePosition.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class HedgePairPosition:public CObject
  {
private:
   long              pid_x;
   long              pid_y;
public:
                     HedgePairPosition(void){};
                    ~HedgePairPosition(void){};
   void              Init(long x_pid,long y_pid);
   double            GetProfits();
   double            GetLots();
   long              GetPidX(){return pid_x;};
   long              GetPidY(){return pid_y;};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgePairPosition::Init(long x_pid,long y_pid)
  {
   pid_x=x_pid;
   pid_y=y_pid;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double HedgePairPosition::GetProfits(void)
  {
   double sum_p=0;
   PositionSelectByTicket(pid_x);
   sum_p+=PositionGetDouble(POSITION_PROFIT);
   PositionSelectByTicket(pid_y);
   sum_p+=PositionGetDouble(POSITION_PROFIT);
   return sum_p;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double HedgePairPosition::GetLots(void)
  {
   double sum_l=0;
   PositionSelectByTicket(pid_x);
   sum_l+=PositionGetDouble(POSITION_VOLUME);
   PositionSelectByTicket(pid_y);
   sum_l+=PositionGetDouble(POSITION_VOLUME);
   return sum_l;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHedgePositionList
  {
protected:
   CArrayObj         hpos_list;
public:
                     CHedgePositionList(void){};
                    ~CHedgePositionList(void){};
   void              AddPairPos(long x_pid,long y_pid);
   void              DeletePairPos(int index);
   double            GetPairProfits(int index);
   double            GetPairLots(int index);
   long              GetPairPosXId(int index);
   long              GetPairPosYId(int index);
   int               PosTotal();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgePositionList::AddPairPos(long x_pid,long y_pid)
  {
   HedgePairPosition *hpos=new HedgePairPosition();
   hpos.Init(x_pid,y_pid);
   hpos_list.Add(hpos);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgePositionList::DeletePairPos(int index)
  {
   hpos_list.Delete(index);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CHedgePositionList::GetPairProfits(int index)
  {
   HedgePairPosition *hpos=hpos_list.At(index);
   return hpos.GetProfits();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CHedgePositionList::GetPairLots(int index)
  {
   HedgePairPosition *hpos=hpos_list.At(index);
   return hpos.GetLots();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CHedgePositionList::PosTotal(void)
  {
   return hpos_list.Total();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CHedgePositionList::GetPairPosXId(int index)
  {
   HedgePairPosition *hpos=hpos_list.At(index);
   return hpos.GetPidX();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CHedgePositionList::GetPairPosYId(int index)
  {
   HedgePairPosition *hpos=hpos_list.At(index);
   return hpos.GetPidY();
  }
//+------------------------------------------------------------------+

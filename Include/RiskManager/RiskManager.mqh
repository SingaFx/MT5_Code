//+------------------------------------------------------------------+
//|                                           AccountInformation.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct AccountInfor
  {
   double            balance;
   double            equity;
   double            margin_used;
   double            margin_percent;
   long              lever;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPositionInfor:public CObject
  {
public:
   datetime          open_time;
   datetime          close_time;
   string            symbol;
   double            open_price;
   double            close_price;
   ENUM_POSITION_TYPE position_type;
   double            open_volume;
   double            close_volume;
   double            profits;
   long              id;
   long              ea_magic;
   long              close_type;
   double            hold_time;
   double            swap;
   double            commission;
   double tp;
   double sl;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDealInfor:public CObject
  {
public:
   datetime          deal_time;
   long              deal_ticket;
   long              order_id;
   string            symbol;
   long              deal_type;
   long              deal_entry;
   double            deal_volume;
   double            deal_price;
   double            deal_swap;
   double            deal_commission;
   double            deal_profit;
   long              deal_magic_id;
   long              deal_position_id;
   double            order_sl;
   double            order_tp;
   string            deal_comment;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CRiskManager
  {
private:
   AccountInfor      account;
   CArrayObj         orders;
public:
                     CRiskManager(void){};
                    ~CRiskManager(void);
   void              RefreshInfor(void);
   void              ToFile(string dir_path="AccountAnalysis\\");
   CArrayObj         history_position;
   CArrayObj         current_position;
   CArrayObj         deals;   
   CArrayObj         deals_force;   
protected:
   void              RefreshDealsInfor(void);
   void              RefreshOrdersInfor(void);
   void              RefreshHistoryPositionInfor(void);//获取历史仓位
   void              RefreshCurrentPosition(void);//获取未平仓的仓位
   void              ModifyHistoryPositionInfor(void);//更新历史仓位=>当前未平的仓位强平
   void              GetForceDealsInfor(void);//针对当前的持仓订单进行强平，并记录信息

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CRiskManager::~CRiskManager(void)
  {
   history_position.Shutdown();
   current_position.Shutdown();
   deals.Shutdown();
   deals_force.Shutdown();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRiskManager::RefreshInfor(void)
  {
   RefreshDealsInfor();
   RefreshCurrentPosition();
   GetForceDealsInfor();
   RefreshHistoryPositionInfor();
   ModifyHistoryPositionInfor();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRiskManager::RefreshDealsInfor(void)
  {
   HistorySelect(0,D'3000.01.01');
   for(int i=0;i<HistoryDealsTotal();i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      CDealInfor *deal=new CDealInfor();
      deal.deal_time=HistoryDealGetInteger(ticket,DEAL_TIME);
      deal.deal_ticket=HistoryDealGetInteger(ticket,DEAL_TICKET);
      deal.order_id=HistoryDealGetInteger(ticket,DEAL_ORDER);
      deal.symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
      deal.deal_type=HistoryDealGetInteger(ticket,DEAL_TYPE);
      deal.deal_entry=HistoryDealGetInteger(ticket,DEAL_ENTRY);
      deal.deal_volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
      deal.deal_price=HistoryDealGetDouble(ticket,DEAL_PRICE);
      deal.deal_commission=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
      deal.deal_swap=HistoryDealGetDouble(ticket,DEAL_SWAP);
      deal.deal_profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
      deal.deal_magic_id=HistoryDealGetInteger(ticket,DEAL_MAGIC);
      deal.deal_position_id=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
      deal.order_sl = HistoryOrderGetDouble(deal.order_id, ORDER_SL);
      deal.order_tp = HistoryOrderGetDouble(deal.order_id, ORDER_TP);
      deal.deal_comment=HistoryDealGetString(ticket,DEAL_COMMENT);
      deals.Add(deal);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRiskManager::RefreshHistoryPositionInfor(void)
  {
//    获取账户信息
   account.balance=AccountInfoDouble(ACCOUNT_BALANCE);
   account.equity=AccountInfoDouble(ACCOUNT_EQUITY);
   account.margin_used=AccountInfoDouble(ACCOUNT_MARGIN);
   account.margin_percent=AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE);
   account.lever=AccountInfoInteger(ACCOUNT_LEVERAGE);
//    计算仓位情况
   HistorySelect(0,D'3000.01.01');
   for(int i=0;i<HistoryDealsTotal();i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(HistoryDealGetInteger(ticket,DEAL_ENTRY)==DEAL_ENTRY_IN)
        {
         CPositionInfor *pos=new CPositionInfor();
         pos.id=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
         pos.symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         pos.open_time=HistoryDealGetInteger(ticket,DEAL_TIME);
         pos.open_price=HistoryDealGetDouble(ticket,DEAL_PRICE);
         pos.position_type=HistoryDealGetInteger(ticket,DEAL_TYPE);
         pos.open_volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
         pos.ea_magic=HistoryDealGetInteger(ticket,DEAL_MAGIC);
         pos.swap=HistoryDealGetDouble(ticket,DEAL_SWAP);
         pos.commission=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         double close_volume_sum=0.0;
         double close_price_sum=0.0;
         double profits=0.0;
         double swap=0;
         double commision=0;
         long close_time=0;
         //          寻找对应的平仓交易
         for(int j=0;j<HistoryDealsTotal();j++)
           {
            ulong ticket2=HistoryDealGetTicket(j);
            if(HistoryDealGetInteger(ticket2,DEAL_ENTRY)==DEAL_ENTRY_OUT && HistoryDealGetInteger(ticket2,DEAL_POSITION_ID)==pos.id)
              {
               close_volume_sum+=HistoryDealGetDouble(ticket2,DEAL_VOLUME);
               close_price_sum+=HistoryDealGetDouble(ticket2,DEAL_VOLUME)*HistoryDealGetDouble(ticket2,DEAL_PRICE);
               profits+=HistoryDealGetDouble(ticket2,DEAL_PROFIT);
               close_time=close_time<HistoryDealGetInteger(ticket2,DEAL_TIME)?HistoryDealGetInteger(ticket2,DEAL_TIME):close_time;
               //close_time=HistoryDealGetInteger(ticket2,DEAL_TIME);
               swap+=HistoryDealGetDouble(ticket2,DEAL_SWAP);
               commision+=HistoryDealGetDouble(ticket2,DEAL_COMMISSION);
              }
           }
         pos.close_time=close_time;
         pos.close_price=close_volume_sum==0?0:close_price_sum/close_volume_sum;
         pos.profits=profits;
         pos.close_volume=close_volume_sum;
         pos.swap+=swap;
         pos.commission+=commision;
         if(close_volume_sum==pos.open_volume)
           {
            pos.close_type=0;
            pos.hold_time=(double)(pos.close_time-pos.open_time)/(60*60);
           }
         else if(close_volume_sum==0)
           {
            pos.close_type=1;
            pos.hold_time=(double)(TimeCurrent()-pos.open_time)/(60*60);
           }

         else
           {
            pos.close_type=2;
            pos.hold_time=(double)(TimeCurrent()-pos.open_time)/(60*60);
           }
         history_position.Add(pos);
        }
     }
  }
void CRiskManager::ModifyHistoryPositionInfor(void)
   {
    for(int i=0;i<history_position.Total();i++)
      {
       CPositionInfor *pos = history_position.At(i);
       if(pos.close_type==0) continue;
       for(int j=0;j<current_position.Total();j++)
         {
          CPositionInfor *pos_current = current_position.At(j);
          if(pos_current.id==pos.id)
            {
             pos.close_time=pos_current.close_time;
             pos.close_volume=pos_current.open_volume;
             pos.close_price = pos_current.close_price;
             pos.profits=pos_current.profits;
             pos.swap=pos_current.swap;
             pos.commission = pos.commission*2;
            }
         }
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRiskManager::RefreshCurrentPosition(void)
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      CPositionInfor *pos=new CPositionInfor();
      ulong ticket=PositionGetTicket(i);
      PositionSelectByTicket(ticket);
      pos.id=PositionGetInteger(POSITION_TICKET);
      pos.symbol=PositionGetString(POSITION_SYMBOL);
      pos.open_time=PositionGetInteger(POSITION_TIME);
      pos.open_price=PositionGetDouble(POSITION_PRICE_OPEN);
      pos.position_type=PositionGetInteger(POSITION_TYPE);
      pos.open_volume=PositionGetDouble(POSITION_VOLUME);
      pos.ea_magic=PositionGetInteger(POSITION_MAGIC);
      pos.swap=PositionGetDouble(POSITION_SWAP);
      pos.commission=0;
      
      pos.close_time=TimeCurrent();
      pos.close_price=PositionGetDouble(POSITION_PRICE_CURRENT);
      pos.tp=PositionGetDouble(POSITION_TP);
      pos.sl=PositionGetDouble(POSITION_SL);
      pos.profits=PositionGetDouble(POSITION_PROFIT);
      pos.hold_time=(double)(pos.close_time-pos.open_time)/(60*60);
      current_position.Add(pos);
     }

  }
void CRiskManager::GetForceDealsInfor(void)
   {
    for(int i=0;i<current_position.Total();i++)
      {
      CPositionInfor *pos = current_position.At(i);
      CDealInfor *deal = new CDealInfor();
      deal.deal_time=pos.close_time;
      deal.deal_ticket=-1;
      deal.order_id=-1;
      deal.symbol=pos.symbol;
      deal.deal_type=1-pos.position_type;//买或卖
      deal.deal_entry=-1;//代表将持仓订单强平
      deal.deal_volume=pos.open_volume;
      deal.deal_price=pos.close_price;
      deal.deal_commission=0;
      deal.deal_swap=0;
      deal.deal_profit=pos.profits;
      deal.deal_magic_id=pos.ea_magic;
      deal.deal_position_id=pos.id;
      deal.order_sl=pos.sl;
      deal.order_tp=pos.tp;
      deal.deal_comment="持仓订单强平";
      deals_force.Add(deal);
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRiskManager::ToFile(string dir_path)
  {
   string path_deal=dir_path+"deal.csv";
   string path_position=dir_path+"position_history.csv";
   string path_current_position=dir_path+"position_current.csv";
   int file_position_handle=FileOpen(path_position,FILE_CSV|FILE_WRITE|FILE_UNICODE, ','); 
   
   if(file_position_handle!=INVALID_HANDLE)
     {
      FileWrite(file_position_handle,
                "开仓时间",
                "类型",
                "交易量(开)",
                "交易量(平)",
                "交易品种",
                "开仓价格",
                "平仓时间(最后)",
                "平仓价格(均价)",
                "利润",
                "是否完全平仓",
                "手续费",
                "库存费",
                "策略",
                "持仓时间",
                "仓位号"
                );               
      for(int i=0;i<history_position.Total();i++)
        {
         CPositionInfor *pos=history_position.At(i);
         FileWrite(file_position_handle,
                   pos.open_time,
                   pos.position_type,
                   pos.open_volume,
                   pos.close_volume,
                   pos.symbol,
                   pos.open_price,
                   pos.close_time,
                   pos.close_price,
                   pos.profits,
                   pos.close_type,
                   pos.commission,
                   pos.swap,
                   pos.ea_magic,
                   pos.hold_time,
                   pos.id);
        }
      FileClose(file_position_handle);
      Print("Write position data OK!");
     }
   else
      Print("打开文件错误",GetLastError());
      
   int file_current_position_handle=FileOpen(path_current_position,FILE_CSV|FILE_WRITE|FILE_UNICODE, ',');
   if(file_current_position_handle!=INVALID_HANDLE)
     {
      FileWrite(file_current_position_handle,
                "开仓时间",
                "类型",
                "交易量(开)",
                "交易量(平)",
                "交易品种",
                "开仓价格",
                "平仓时间(最后)",
                "平仓价格(均价)",
                "利润",
                "是否完全平仓",
                "手续费",
                "库存费",
                "策略",
                "持仓时间",
                "仓位号"
                );
      for(int i=0;i<current_position.Total();i++)
        {
         CPositionInfor *pos=current_position.At(i);
         FileWrite(file_current_position_handle,
                   pos.open_time,
                   pos.position_type,
                   pos.open_volume,
                   pos.close_volume,
                   pos.symbol,
                   pos.open_price,
                   pos.close_time,
                   pos.close_price,
                   pos.profits,
                   pos.close_type,
                   pos.commission,
                   pos.swap,
                   pos.ea_magic,
                   pos.hold_time,
                   pos.id);
        }
      FileClose(file_current_position_handle);
      Print("Write current position data OK!");
     }
   else
      Print("打开文件错误",GetLastError());
      
      
   int file_deal_handle=FileOpen(path_deal,FILE_CSV|FILE_WRITE|FILE_UNICODE, ',');
   if(file_deal_handle!=INVALID_HANDLE)
     {
      FileWrite(file_deal_handle,
                "成交时间",
                "成交ID",
                "订单ID",
                "交易品种",
                "交易类型",
                "进/出场",
                "交易量",
                "成交价格",
                "手续费",
                "库存费",
                "利润",
                "策略",
                "仓位号"
                );
      //历史订单写入
      for(int i=0;i<deals.Total();i++)
        {
         CDealInfor *deal=deals.At(i);
         FileWrite(file_deal_handle,
                   deal.deal_time,
                   deal.deal_ticket,
                   deal.order_id,
                   deal.symbol,
                   deal.deal_type,
                   deal.deal_entry,
                   deal.deal_volume,
                   deal.deal_price,
                   deal.deal_commission,
                   deal.deal_swap,
                   deal.deal_profit,
                   deal.deal_magic_id,
                   deal.deal_position_id
                   );
        }
      //强制平仓订单写入
      for(int i=0;i<deals_force.Total();i++)
        {
         CDealInfor *deal=deals_force.At(i);
         FileWrite(file_deal_handle,
                   deal.deal_time,
                   deal.deal_ticket,
                   deal.order_id,
                   deal.symbol,
                   deal.deal_type,
                   deal.deal_entry,
                   deal.deal_volume,
                   deal.deal_price,
                   deal.deal_commission,
                   deal.deal_swap,
                   deal.deal_profit,
                   deal.deal_magic_id,
                   deal.deal_position_id
                   );
        }
      FileClose(file_deal_handle);
      Print("Write deal data OK!");
     }
   else
      Print("打开文件错误",GetLastError());
  }
//+------------------------------------------------------------------+

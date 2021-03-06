//+------------------------------------------------------------------+
//|                                                     socketEA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <RiskManager\RiskManager.mqh>
input string InpAdd="127.0.0.1";
input int InpPort=9090;

int socket;
long account=AccountInfoInteger(ACCOUNT_LOGIN);
//+------------------------------------------------------------------+
//|EA初始化                                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   socket=SocketCreate();
   Print("本机账户号：",account);
   Print("等待下一次请求...");
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   SocketClose(socket);
  }
//+------------------------------------------------------------------+
//|计时器函数                                                        |
//|每秒向服务器请求一次连接                                          |
//+------------------------------------------------------------------+
void OnTimer()
  {
   socket=SocketCreate();
   if(socket!=INVALID_HANDLE)
     {
      if(SocketConnect(socket,InpAdd,InpPort,100))
        {
         Print("连接上服务器"+InpAdd+IntegerToString(InpPort));
         send_package(socket,string(account));
         string received=socketreceive(socket,100);
         Print("本机账户号：",account,",从服务器接收的消息：",received);
         if(received=="start")
           {
            Print("开始发送账户信息...");
            send_history(socket);
            Print("账户信息发送完毕");
            send_package(socket,"over");
           }
         else
           {
            Print("没有收到消息，关闭socket");
           }

         Print("等待下一次请求...");
        }
      SocketClose(socket);
     }
  }
//+------------------------------------------------------------------+
//|封装发送信息,在字符串前面加上其长度，格式化为3位                  |
//+------------------------------------------------------------------+
bool send_package(int sock,string tosend_string)
  {
   char req[];
   int  len=StringToCharArray(tosend_string,req,0,-1,CP_UTF8)-1;
   string temp=IntegerToString(len,4);
   string tosend=temp+tosend_string;
   return socksend(socket,tosend);
  }
//+------------------------------------------------------------------+
//|发送账户信息                                                      |
//+------------------------------------------------------------------+
void send_history(int sock)
  {
//获取账户信息
   CRiskManager *rm=new CRiskManager();
   rm.RefreshInfor();

   bool flag=false;
   int num=0;

//获取全部的历史交易记录
   for(int i=0; i<rm.deals.Total(); i++)
     {
      string tosend;
      CDealInfor *deal=rm.deals.At(i);
      tosend += (string)deal.deal_time + ",";
      tosend += (string)deal.deal_ticket + ",";
      tosend += (string)deal.order_id + ",";
      tosend += (string)deal.symbol + ",";
      tosend += (string)deal.deal_type + ",";
      tosend += (string)deal.deal_entry + ",";
      tosend += (string)deal.deal_volume + ",";
      tosend += (string)deal.deal_price + ",";
      tosend += (string)deal.deal_commission + ",";
      tosend += (string)deal.deal_swap + ",";
      tosend += (string)deal.deal_profit + ",";
      tosend += (string)deal.deal_magic_id + ",";
      tosend += (string)deal.deal_position_id + ",";
      tosend += (string)deal.order_sl + ",";
      tosend += (string)deal.order_tp + ",";
      tosend += (string)deal.deal_comment + "\n";

      if(send_package(sock,tosend)==false)
        {
         //Print("第", i, "行信息发送失败, error ",GetLastError());
         flag=true;
         num++;
        }
     }

//获取强平的交易记录
   for(int i=0; i<rm.deals_force.Total(); i++)
     {
      string tosend;
      CDealInfor *deal=rm.deals_force.At(i);
      tosend += (string)deal.deal_time + ",";
      tosend += (string)deal.deal_ticket + ",";
      tosend += (string)deal.order_id + ",";
      tosend += (string)deal.symbol + ",";
      tosend += (string)deal.deal_type + ",";
      tosend += (string)deal.deal_entry + ",";
      tosend += (string)deal.deal_volume + ",";
      tosend += (string)deal.deal_price + ",";
      tosend += (string)deal.deal_commission + ",";
      tosend += (string)deal.deal_swap + ",";
      tosend += (string)deal.deal_profit + ",";
      tosend += (string)deal.deal_magic_id + ",";
      tosend += (string)deal.deal_position_id + ",";
      tosend += (string)deal.order_sl + ",";
      tosend += (string)deal.order_tp + ",";
      tosend += (string)deal.deal_comment + "\n";

      if(send_package(sock,tosend)==false)
        {
         //Print("第", i, "行信息发送失败, error ",GetLastError());
         flag=true;
         num++;
        }
     }

   if(flag==true)
     {
      int n=rm.deals.Total()+rm.deals_force.Total();
      Print("总共有",n,"行信息，","其中有",num,"行信息发送失败!");
     }

   delete rm;
  }
//+------------------------------------------------------------------+
//|向服务器传输信息，传输成功返回true，失败返回false                 |
//+------------------------------------------------------------------+
bool socksend(int sock,string request)
  {
   char req[];
   int  len=StringToCharArray(request,req,0,-1,CP_UTF8)-1;
   if(len<0) return(false);
   return(SocketSend(sock,req,len)==len);
  }
//+------------------------------------------------------------------+
//|接受服务器信息（账户号数据），并转化成字符串后返回。              |
//+------------------------------------------------------------------+
string socketreceive(int sock,int timeout)
  {
   char rsp[];
   char rsp_r[];
   ArrayResize(rsp_r,0,'a');
   uint start=0;
   string result="";
   uint len;
   uint timeout_check=GetTickCount()+timeout;
   do
     {
      len=SocketIsReadable(sock);
      if(len)
        {
         int rsp_len;
         rsp_len=SocketRead(sock,rsp,len,timeout);
         if(rsp_len>0)
           {
            ArrayInsert(rsp_r,rsp,start);
            start+=rsp_len;
           }
        }
     }
   while((GetTickCount()<timeout_check) && !IsStopped());

   result=CharArrayToString(rsp_r,0,-1,CP_UTF8);

   return result;
  }
//+------------------------------------------------------------------+
